<?php

/*
|--------------------------------------------------------------------------
| Car insurance domain settings
|--------------------------------------------------------------------------
| Business values that change per deployment live here (or in .env),
| never hardcoded in services. Pricing factors themselves are stored
| in the database and managed by admins.
*/

return [

    'currency' => env('INSURANCE_CURRENCY', 'LYD'),
    'currency_label' => env('INSURANCE_CURRENCY_LABEL', 'دينار ليبي'),

    'company' => [
        'name_ar' => env('COMPANY_NAME_AR', 'العربية الكبرى للتأمين المساهمة'),
        'name_en' => env('COMPANY_NAME_EN', 'Alarabia Kobrah Insurance Company'),
        'address' => env('COMPANY_ADDRESS', 'بنغازي - ليبيا'),
        'phone' => env('COMPANY_PHONE', '0925441206'),
        // Absolute paths (PNG/JPG/SVG). Colour logo (company's choice); the rest of the document is black & white.
        // The stamp is still a placeholder.
        'logo_path' => env('COMPANY_LOGO_PATH', resource_path('pdf/logo.png')),
        'stamp_path' => env('COMPANY_STAMP_PATH', resource_path('pdf/stamp.svg')),
        // Shown on the PDF so third parties know where to verify a policy (no QR code by design).
        'verification_url' => env('POLICY_VERIFICATION_URL', env('APP_URL').'/verify'),
    ],

    'policy' => [
        'number_prefix' => 'POL',
        'duration_months' => (int) env('POLICY_DURATION_MONTHS', 12),
        // How far in the future a customer may set the policy start date.
        'max_start_days_ahead' => (int) env('POLICY_MAX_START_DAYS_AHEAD', 60),
        'pdf_disk' => env('POLICY_PDF_DISK', 'local'),
        'pdf_directory' => 'policies',
    ],

    'claim' => [
        'number_prefix' => 'CLM',
    ],

    'quote' => [
        // Look-back window used to compute the claims_history factor.
        'claims_history_years' => (int) env('QUOTE_CLAIMS_HISTORY_YEARS', 3),
    ],

    'otp' => [
        'length' => 6,
        'ttl_minutes' => (int) env('OTP_TTL_MINUTES', 5),
        'max_attempts' => (int) env('OTP_MAX_ATTEMPTS', 5),
        'resend_after_seconds' => 60,
        // Registration token issued after a new phone number is verified.
        'registration_token_ttl_minutes' => 30,
        // Fixed code for local development ONLY. Ignored outside local/testing environments.
        'fixed_code' => env('OTP_FIXED_CODE'),
    ],

    'sms' => [
        'driver' => env('SMS_DRIVER', 'log'),
    ],

    'validation' => [
        // Libyan mobile numbers, local format: 091 / 092 / 093 / 094 / 095 + 7 digits.
        // +218 / 00218 prefixes are converted to the local format before validation.
        'phone_country_code' => env('PHONE_COUNTRY_CODE', '218'),
        'phone_regex' => env('PHONE_REGEX', '/^09[1-5][0-9]{7}$/'),
        // Libyan national number: 12 digits, first digit 1 (male) or 2 (female).
        'national_id_regex' => env('NATIONAL_ID_REGEX', '/^[12][0-9]{11}$/'),
        // ISO 3779 VIN: 17 chars, excludes I, O, Q.
        'vin_regex' => '/^[A-HJ-NPR-Z0-9]{17}$/',
        'policy_no_regex' => '/^POL-[0-9]{4}-[0-9]{6}$/',
        'min_vehicle_year' => 1950,
    ],

    'uploads' => [
        'disk' => env('UPLOADS_DISK', 'local'),
        'image_mimes' => ['jpg', 'jpeg', 'png', 'webp'],
        'image_max_kb' => (int) env('UPLOAD_IMAGE_MAX_KB', 5120),
        'signed_url_ttl_minutes' => (int) env('SIGNED_URL_TTL_MINUTES', 15),
    ],

];
