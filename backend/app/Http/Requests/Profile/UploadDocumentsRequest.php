<?php

namespace App\Http\Requests\Profile;

use App\Http\Requests\ApiRequest;

class UploadDocumentsRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_image' => [...$this->imageRules(), 'required_without:license_image'],
            'license_image' => [...$this->imageRules(), 'required_without:id_image'],
        ];
    }
}
