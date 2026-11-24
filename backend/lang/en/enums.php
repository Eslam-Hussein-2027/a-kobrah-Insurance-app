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

];
