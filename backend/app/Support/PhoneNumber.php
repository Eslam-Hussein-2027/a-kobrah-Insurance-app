<?php

namespace App\Support;

/**
 * Normalizes phone input to the local format used for storage and login:
 * "+218 91-123 4567", "00218911234567", "218911234567", "٠٩١١٢٣٤٥٦٧" → "0911234567".
 */
final class PhoneNumber
{
    public static function normalize(mixed $value, ?string $countryCode = null): mixed
    {
        if (! is_string($value)) {
            return $value;
        }

        $countryCode ??= (string) config('insurance.validation.phone_country_code');
        $phone = preg_replace('/[\s\-().]+/u', '', (string) Digits::toWestern($value)) ?? '';

        foreach (['+'.$countryCode, '00'.$countryCode] as $prefix) {
            if (str_starts_with($phone, $prefix)) {
                return '0'.substr($phone, strlen($prefix));
            }
        }

        // Country code without "+" (e.g. 218911234567): local number is 9 digits after it.
        if (str_starts_with($phone, $countryCode) && strlen($phone) === strlen($countryCode) + 9) {
            return '0'.substr($phone, strlen($countryCode));
        }

        return $phone;
    }
}
