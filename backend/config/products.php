<?php

/*
|--------------------------------------------------------------------------
| Insurance product catalog
|--------------------------------------------------------------------------
| Structure only. Names and descriptions are translated in lang/{locale}/products.php
| (product names in lang/{locale}/enums.php → insurance_product).
|
| offered   products the app shows, in display order. The others below stay defined but are
|           switched off: hidden from the catalog and refused by the API (their routes answer 404).
|           To bring one back, add its code here.
|
| instant   true  → issued and paid in the app (motor, travel).
|           false → the customer sends a request; staff reply with a price or issue it.
| icon      key the mobile app maps to an icon.
| fields    questions asked in the request form (request products only).
|           type: text | integer | number | date | vehicle (one of the customer's vehicles)
| documents files the customer can attach (labels in products.documents.*).
*/

return [

    'offered' => ['motor', 'marine_cargo'],

    'items' => [

        'motor' => [
            'instant' => true,
            'icon' => 'car',
            'documents' => ['vehicle_registration', 'national_id'],
        ],

        'travel' => [
            'instant' => true,
            'icon' => 'luggage',
            'documents' => ['passport'],
        ],

        'orange_card' => [
            'instant' => false,
            'icon' => 'card',
            'fields' => [
                ['key' => 'vehicle', 'type' => 'vehicle', 'required' => true],
                ['key' => 'destination_country', 'type' => 'text', 'required' => true, 'max' => 60],
                ['key' => 'travel_date', 'type' => 'date', 'required' => true],
                ['key' => 'duration_days', 'type' => 'integer', 'required' => true, 'min' => 1, 'max' => 365],
            ],
            'documents' => ['vehicle_registration', 'passport'],
        ],

        'foreign_workers' => [
            'instant' => false,
            'icon' => 'worker',
            'fields' => [
                ['key' => 'workers_count', 'type' => 'integer', 'required' => true, 'min' => 1, 'max' => 1000],
                ['key' => 'nationality', 'type' => 'text', 'required' => true, 'max' => 60],
                ['key' => 'employer_name', 'type' => 'text', 'required' => true, 'max' => 120],
            ],
            'documents' => ['worker_passport', 'employer_documents'],
        ],

        'medical_liability' => [
            'instant' => false,
            'icon' => 'stethoscope',
            'fields' => [
                ['key' => 'specialty', 'type' => 'text', 'required' => true, 'max' => 80],
                ['key' => 'workplace', 'type' => 'text', 'required' => true, 'max' => 120],
                ['key' => 'coverage_limit', 'type' => 'number', 'required' => false, 'min' => 0, 'max' => 100000000],
            ],
            'documents' => ['practice_license'],
        ],

        'marine_cargo' => [
            'instant' => false,
            'icon' => 'ship',
            'fields' => [
                ['key' => 'cargo_type', 'type' => 'text', 'required' => true, 'max' => 120],
                ['key' => 'origin_port', 'type' => 'text', 'required' => true, 'max' => 80],
                ['key' => 'destination_port', 'type' => 'text', 'required' => true, 'max' => 80],
                ['key' => 'cargo_value', 'type' => 'number', 'required' => true, 'min' => 1, 'max' => 1000000000],
                ['key' => 'shipping_date', 'type' => 'date', 'required' => false],
            ],
            'documents' => ['commercial_invoice', 'bill_of_lading'],
        ],

    ],

    'request' => [
        'number_prefix' => 'REQ',
        'notes_max' => 1000,
        'document_mimes' => ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
        'document_max_kb' => (int) env('REQUEST_DOCUMENT_MAX_KB', 5120),
    ],

];
