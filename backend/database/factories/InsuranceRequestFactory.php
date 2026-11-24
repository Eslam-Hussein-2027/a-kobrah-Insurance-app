<?php

namespace Database\Factories;

use App\Enums\InsuranceProduct;
use App\Enums\InsuranceRequestKind;
use App\Enums\InsuranceRequestStatus;
use App\Models\InsuranceRequest;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<InsuranceRequest>
 */
class InsuranceRequestFactory extends Factory
{
    public function definition(): array
    {
        return [
            'request_no' => 'REQ-'.now()->year.'-'.fake()->unique()->numerify('######'),
            'user_id' => User::factory(),
            'product' => InsuranceProduct::MarineCargo,
            'kind' => InsuranceRequestKind::Quote,
            'status' => InsuranceRequestStatus::Submitted,
            'details' => [
                'cargo_type' => 'مواد غذائية',
                'origin_port' => 'ميناء الإسكندرية',
                'destination_port' => 'ميناء بنغازي',
                'cargo_value' => '250000',
            ],
        ];
    }

    public function status(InsuranceRequestStatus $status): static
    {
        return $this->state(['status' => $status]);
    }
}
