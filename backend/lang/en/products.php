<?php

// Customer-facing product text. Product names: lang/en/enums.php → insurance_product.
return [

    'motor' => [
        'title' => 'Compulsory motor insurance',
        'description' => 'Third-party liability cover, required by law for every vehicle on the road.',
        'covers' => [
            'Injuries to people in accidents caused by your vehicle',
            'Damage to other people\'s property',
            'Valid for a full year from the start date',
        ],
    ],

    'travel' => [
        'title' => 'Travel insurance',
        'description' => 'Medical and emergency cover while travelling, suitable for visa applications.',
        'covers' => [
            'Emergency medical treatment abroad',
            'Medical transport and evacuation',
            'Delayed or lost baggage',
        ],
    ],

    'orange_card' => [
        'title' => 'Orange Card',
        'description' => 'Cover for your car when you drive it to participating Arab countries.',
        'covers' => [
            'Third-party liability outside Libya',
            'Accepted at the borders of participating countries',
            'Duration based on your trip',
        ],
    ],

    'foreign_workers' => [
        'title' => 'Foreign workers insurance',
        'description' => 'Health cover required to issue or renew a worker\'s residence permit.',
        'covers' => [
            'Emergency treatment and hospital stay',
            'Work injuries',
            'One year, renewable',
        ],
    ],

    'medical_liability' => [
        'title' => 'Medical liability insurance',
        'description' => 'Protects doctors and healthcare facilities against malpractice claims.',
        'covers' => [
            'Compensation due to patients',
            'Legal defence costs',
            'Cover for the doctor or the facility',
        ],
    ],

    'marine_cargo' => [
        'title' => 'Marine cargo insurance',
        'description' => 'Cover for imported and exported goods during shipping.',
        'covers' => [
            'Total or partial loss of the goods',
            'Loading and unloading damage',
            'From the port of loading to your warehouse',
        ],
    ],

    'fields' => [
        'vehicle' => 'Vehicle',
        'destination_country' => 'Destination country',
        'travel_date' => 'Travel date',
        'duration_days' => 'Duration (days)',
        'workers_count' => 'Number of workers',
        'nationality' => 'Nationality',
        'employer_name' => 'Employer',
        'specialty' => 'Specialty',
        'workplace' => 'Workplace',
        'coverage_limit' => 'Requested cover limit (LYD)',
        'cargo_type' => 'Type of goods',
        'origin_port' => 'Port of loading',
        'destination_port' => 'Port of discharge',
        'cargo_value' => 'Value of goods (LYD)',
        'shipping_date' => 'Shipping date',
    ],

    'documents' => [
        'vehicle_registration' => 'Vehicle registration',
        'national_id' => 'Owner\'s national number',
        'passport' => 'Valid passport',
        'worker_passport' => 'Worker\'s passport copy',
        'employer_documents' => 'Employer or sponsor details',
        'practice_license' => 'License to practise',
        'commercial_invoice' => 'Commercial invoice',
        'bill_of_lading' => 'Bill of lading',
    ],

];
