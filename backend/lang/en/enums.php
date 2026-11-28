<?php

return [

    'user_role' => [
        'customer' => 'Customer',
        'surveyor' => 'Surveyor',
        'admin' => 'Administrator',
        'workshop' => 'Workshop',
    ],

    'policy_status' => [
        'PENDING_PAYMENT' => 'Pending payment',
        'ACTIVE' => 'Active',
        'EXPIRED' => 'Expired',
        'CANCELLED' => 'Cancelled',
    ],

    'payment_method' => [
        'ONLINE' => 'Online payment',
        'OFFICE' => 'Pay at office',
    ],

    'payment_status' => [
        'PENDING' => 'Pending',
        'PAID' => 'Paid',
        'FAILED' => 'Failed',
        'REFUNDED' => 'Refunded',
    ],

    'pricing_factor_type' => [
        'vehicle_age' => 'Vehicle age',
        'engine_cc' => 'Engine capacity',
        'claims_history' => 'Claims history',
    ],

    'claim_status' => [
        'SUBMITTED' => 'Submitted',
        'UNDER_REVIEW' => 'Under review',
        'SURVEYOR_ASSIGNED' => 'Surveyor assigned',
        'INSPECTED' => 'Inspected',
        'APPROVED' => 'Approved',
        'IN_REPAIR' => 'In repair',
        'SETTLED' => 'Settled',
        'CLOSED' => 'Closed',
        'REJECTED' => 'Rejected',
    ],

    'claim_media_type' => [
        'DAMAGE' => 'Damage photo',
        'POLICE_REPORT' => 'Police report',
    ],

    'user_document_type' => [
        'id_image' => 'Identity document image (ID card or passport)',
        'license_image' => 'Driving license image',
    ],

    'policy_verification' => [
        'VALID' => 'Policy is valid',
        'EXPIRED' => 'Policy has expired',
        'NOT_FOUND' => 'No valid policy matches these details',
    ],

    'insurance_product' => [
        'motor' => 'Compulsory motor',
        'travel' => 'Travel',
        'orange_card' => 'Orange Card',
        'foreign_workers' => 'Foreign workers',
        'medical_liability' => 'Medical liability',
        'marine_cargo' => 'Marine cargo',
    ],

    'person_relationship' => [
        'self' => 'Me',
        'spouse' => 'Spouse',
        'child' => 'Child',
        'parent' => 'Parent',
        'sibling' => 'Sibling',
        'other' => 'Other',
    ],

    'insurance_request_kind' => [
        'issue' => 'Issue request',
        'quote' => 'Price request',
    ],

    'insurance_request_status' => [
        'SUBMITTED' => 'Submitted',
        'IN_REVIEW' => 'In review',
        'QUOTED' => 'Price offered',
        'COMPLETED' => 'Completed',
        'REJECTED' => 'Rejected',
        'CANCELLED' => 'Cancelled',
    ],

    'travel_zone' => [
        'arab' => 'Arab countries',
        'schengen' => 'Europe (Schengen)',
        'worldwide' => 'Worldwide',
    ],

    'vehicle_color' => [
        'white' => 'White',
        'black' => 'Black',
        'silver' => 'Silver',
        'grey' => 'Grey',
        'red' => 'Red',
        'blue' => 'Blue',
        'green' => 'Green',
        'beige' => 'Beige',
        'brown' => 'Brown',
        'gold' => 'Gold',
        'yellow' => 'Yellow',
        'orange' => 'Orange',
        'other' => 'Other colour',
    ],

    'manufacture_country' => [
        'japan' => 'Japan',
        'south_korea' => 'South Korea',
        'germany' => 'Germany',
        'united_states' => 'United States',
        'china' => 'China',
        'france' => 'France',
        'italy' => 'Italy',
        'united_kingdom' => 'United Kingdom',
        'sweden' => 'Sweden',
        'czech_republic' => 'Czech Republic',
        'spain' => 'Spain',
        'turkey' => 'Turkey',
        'india' => 'India',
        'iran' => 'Iran',
        'malaysia' => 'Malaysia',
        'other' => 'Other country',
    ],

    'license_purpose' => [
        'private' => 'Private',
        'taxi' => 'Taxi',
        'private_transport' => 'Private goods transport',
        'public_transport' => 'Public goods transport',
        'passenger_transport' => 'Passenger transport (bus)',
        'driving_school' => 'Driving school',
        'government' => 'Government',
    ],

    'licensing_authority' => [
        'tripoli' => 'Tripoli traffic dept.',
        'benghazi' => 'Benghazi traffic dept.',
        'misrata' => 'Misrata traffic dept.',
        'zawiya' => 'Zawiya traffic dept.',
        'sabha' => 'Sabha traffic dept.',
        'bayda' => 'Bayda traffic dept.',
        'tobruk' => 'Tobruk traffic dept.',
        'derna' => 'Derna traffic dept.',
        'sirte' => 'Sirte traffic dept.',
        'khoms' => 'Khoms traffic dept.',
        'zliten' => 'Zliten traffic dept.',
        'gharyan' => 'Gharyan traffic dept.',
        'ajdabiya' => 'Ajdabiya traffic dept.',
        'marj' => 'Marj traffic dept.',
        'sabratha' => 'Sabratha traffic dept.',
        'zuwara' => 'Zuwara traffic dept.',
        'tarhuna' => 'Tarhuna traffic dept.',
        'bani_walid' => 'Bani Walid traffic dept.',
        'kufra' => 'Kufra traffic dept.',
        'ubari' => 'Ubari traffic dept.',
        'ghat' => 'Ghat traffic dept.',
        'murzuq' => 'Murzuq traffic dept.',
        'jufra' => 'Jufra traffic dept.',
        'nalut' => 'Nalut traffic dept.',
        'yafran' => 'Yafran traffic dept.',
        'other' => 'Other authority',
    ],

];
