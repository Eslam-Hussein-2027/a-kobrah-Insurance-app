<?php

namespace App\Http\Resources;

use App\Models\InsuranceRequest;
use App\Models\InsuranceRequestDocument;
use App\Services\Catalog\ProductCatalog;
use App\Services\Requests\InsuranceRequestService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin InsuranceRequest */
class InsuranceRequestResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $catalog = app(ProductCatalog::class);

        return [
            'id' => $this->id,
            'request_no' => $this->request_no,
            'product' => $this->product->toArray(),
            'kind' => $this->kind->toArray(),
            'status' => $this->status->toArray(),
            // Ordered like the product's form, with translated labels.
            'details' => array_values(array_map(
                fn (string $key) => [
                    'key' => $key,
                    'label' => $catalog->fieldLabel($key),
                    'value' => (string) $this->details[$key],
                ],
                array_keys($this->details ?? []),
            )),
            'notes' => $this->notes,
            'staff_reply' => $this->staff_reply,
            'quoted_amount' => $this->quoted_amount,
            'currency' => config('insurance.currency'),
            'replied_at' => $this->replied_at?->toIso8601String(),
            'can_cancel' => $this->status->canBeCancelledByCustomer(),
            'documents' => $this->whenLoaded('documents', fn () => $this->documents
                ->map(fn (InsuranceRequestDocument $document) => $this->documentData($document, $request, $catalog))
                ->values()
                ->all()),
            'customer' => $this->when(
                $request->user()?->isAdmin() === true && $this->relationLoaded('user'),
                fn () => [
                    'id' => $this->user->id,
                    'name' => $this->user->name,
                    'phone' => $this->user->phone,
                ],
            ),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function documentData(InsuranceRequestDocument $document, Request $request, ProductCatalog $catalog): array
    {
        $data = [
            'id' => $document->id,
            'key' => $document->document_key,
            'label' => $catalog->documentLabel($document->document_key),
            'name' => $document->original_name,
        ];

        // Signed download links are for staff only.
        if ($request->user()?->isAdmin() === true) {
            $data['url'] = app(InsuranceRequestService::class)->documentUrl($document);
        }

        return $data;
    }
}
