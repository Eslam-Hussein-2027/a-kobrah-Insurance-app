<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

/**
 * Insurance products shown in the app.
 * Structure (issuance mode, form fields, documents) lives in config/products.php,
 * customer-facing text in lang/{locale}/products.php.
 */
enum InsuranceProduct: string
{
    use HasLabel;

    case Motor = 'motor';
    case Travel = 'travel';
    case OrangeCard = 'orange_card';
    case ForeignWorkers = 'foreign_workers';
    case MedicalLiability = 'medical_liability';
    case MarineCargo = 'marine_cargo';

    public static function translationGroup(): string
    {
        return 'insurance_product';
    }

    /** Issued and paid inside the app (no staff involvement). */
    public function isInstant(): bool
    {
        return (bool) config("products.items.{$this->value}.instant", false);
    }

    /** Switched on in config/products.php (offered). */
    public function isOffered(): bool
    {
        return in_array($this->value, (array) config('products.offered'), true);
    }

    /**
     * Products the app offers, in display order.
     *
     * @return list<self>
     */
    public static function offered(): array
    {
        return array_map(fn (string $code) => self::from($code), array_values((array) config('products.offered')));
    }

    /**
     * Offered products that are handled through a request reviewed by staff.
     *
     * @return list<self>
     */
    public static function onRequest(): array
    {
        return array_values(array_filter(self::offered(), fn (self $product) => ! $product->isInstant()));
    }
}
