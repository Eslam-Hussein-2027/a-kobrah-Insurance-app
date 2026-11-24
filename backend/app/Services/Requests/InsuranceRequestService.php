<?php

namespace App\Services\Requests;

use App\Enums\InsuranceProduct;
use App\Enums\InsuranceRequestKind;
use App\Enums\InsuranceRequestStatus;
use App\Exceptions\BusinessRuleException;
use App\Models\InsuranceRequest;
use App\Models\InsuranceRequestDocument;
use App\Models\User;
use App\Models\Vehicle;
use App\Services\Catalog\ProductCatalog;
use App\Services\DocumentNumberGenerator;
use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;
use Throwable;

/**
 * Requests for products that staff price and issue manually.
 */
class InsuranceRequestService
{
    public function __construct(
        private readonly ProductCatalog $catalog,
        private readonly DocumentNumberGenerator $numbers,
    ) {}

    /**
     * @param  array<string, mixed>  $answers  validated answers keyed by field key
     * @param  array<string, UploadedFile>  $documents  keyed by document key
     */
    public function submit(
        User $customer,
        InsuranceProduct $product,
        InsuranceRequestKind $kind,
        array $answers,
        ?string $notes = null,
        array $documents = [],
    ): InsuranceRequest {
        if ($product->isInstant()) {
            throw new BusinessRuleException(__('messages.request.instant_product'));
        }

        $details = $this->normalizeAnswers($customer, $product, $answers);
        $storedPaths = [];

        try {
            return DB::transaction(function () use ($customer, $product, $kind, $details, $notes, $documents, &$storedPaths) {
                /** @var InsuranceRequest $request */
                $request = $customer->insuranceRequests()->create([
                    'request_no' => $this->numbers->next((string) config('products.request.number_prefix')),
                    'product' => $product,
                    'kind' => $kind,
                    'status' => InsuranceRequestStatus::Submitted,
                    'details' => $details,
                    'notes' => $notes,
                ]);

                foreach ($documents as $key => $file) {
                    $path = $file->store("requests/{$request->id}", ['disk' => $this->diskName()]);
                    $storedPaths[] = $path;

                    $request->documents()->create([
                        'document_key' => $key,
                        'path' => $path,
                        'original_name' => mb_substr($file->getClientOriginalName(), 0, 255),
                        'mime_type' => (string) $file->getMimeType(),
                        'size' => (int) $file->getSize(),
                    ]);
                }

                return $request;
            });
        } catch (Throwable $exception) {
            // Nothing was saved: don't leave orphan files behind.
            $this->disk()->delete($storedPaths);

            throw $exception;
        }
    }

    public function cancel(InsuranceRequest $request): InsuranceRequest
    {
        if (! $request->status->canBeCancelledByCustomer()) {
            throw new BusinessRuleException(__('messages.request.closed'));
        }

        $request->update(['status' => InsuranceRequestStatus::Cancelled]);

        return $request;
    }

    /**
     * Staff reply: move the request forward and/or send a price offer.
     */
    public function respond(
        InsuranceRequest $request,
        User $staff,
        InsuranceRequestStatus $status,
        ?string $reply = null,
        ?string $quotedAmount = null,
    ): InsuranceRequest {
        return DB::transaction(function () use ($request, $staff, $status, $reply, $quotedAmount) {
            /** @var InsuranceRequest $locked */
            $locked = InsuranceRequest::query()->whereKey($request->id)->lockForUpdate()->firstOrFail();

            if (! $locked->status->isOpen()) {
                throw new BusinessRuleException(__('messages.request.closed'));
            }

            if (! in_array($status, InsuranceRequestStatus::staffTargets(), true)) {
                throw new BusinessRuleException(__('messages.request.invalid_status'));
            }

            $locked->update(array_filter([
                'status' => $status,
                'staff_reply' => $reply,
                'quoted_amount' => $quotedAmount,
                'handled_by' => $staff->id,
                'replied_at' => now(),
            ], fn ($value) => $value !== null));

            return $locked;
        });
    }

    public function documentUrl(InsuranceRequestDocument $document): string
    {
        return URL::temporarySignedRoute(
            'api.v1.files.request-document',
            now()->addMinutes((int) config('insurance.uploads.signed_url_ttl_minutes')),
            ['document' => $document->id],
        );
    }

    public function disk(): Filesystem
    {
        return Storage::disk($this->diskName());
    }

    /**
     * Keep only the product's fields, typed, with vehicles stored as a readable snapshot
     * (the request must stay readable even if the vehicle is edited later).
     *
     * @param  array<string, mixed>  $answers
     * @return array<string, int|string>
     */
    private function normalizeAnswers(User $customer, InsuranceProduct $product, array $answers): array
    {
        $details = [];

        foreach ($this->catalog->fields($product) as $field) {
            $value = $answers[$field['key']] ?? null;

            if ($value === null || $value === '') {
                continue;
            }

            $details[$field['key']] = match ($field['type']) {
                'vehicle' => $this->vehicleSnapshot($customer, (int) $value),
                'integer' => (int) $value,
                default => trim((string) $value),
            };
        }

        return $details;
    }

    private function vehicleSnapshot(User $customer, int $vehicleId): string
    {
        /** @var Vehicle $vehicle */
        $vehicle = $customer->vehicles()->findOrFail($vehicleId);

        return "{$vehicle->make} {$vehicle->model} {$vehicle->year} · {$vehicle->plate_no}";
    }

    private function diskName(): string
    {
        return (string) config('insurance.uploads.disk');
    }
}
