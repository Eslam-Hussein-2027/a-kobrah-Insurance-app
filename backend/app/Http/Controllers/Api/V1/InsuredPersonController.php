<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Person\PersonRequest;
use App\Http\Resources\InsuredPersonResource;
use App\Http\Responses\ApiResponse;
use App\Models\InsuredPerson;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InsuredPersonController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        // Small list per customer: returned in full (no pagination).
        $persons = $request->user()->insuredPersons()->orderBy('id')->get();

        return ApiResponse::success(InsuredPersonResource::collection($persons));
    }

    public function store(PersonRequest $request): JsonResponse
    {
        $person = $request->user()->insuredPersons()->create($request->personData());

        return ApiResponse::created(new InsuredPersonResource($person), __('messages.person.created'));
    }

    public function show(InsuredPerson $person): JsonResponse
    {
        $this->authorize('view', $person);

        return ApiResponse::success(new InsuredPersonResource($person));
    }

    public function update(PersonRequest $request, InsuredPerson $person): JsonResponse
    {
        $this->authorize('update', $person);

        $person->update($request->personData());

        return ApiResponse::success(new InsuredPersonResource($person), __('messages.person.updated'));
    }

    public function destroy(InsuredPerson $person): JsonResponse
    {
        $this->authorize('delete', $person);

        $person->delete();

        return ApiResponse::success(message: __('messages.person.deleted'));
    }
}
