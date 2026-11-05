<?php

return [

    'errors' => [
        'validation' => 'The given data was invalid.',
        'unauthenticated' => 'Please log in first.',
        'forbidden' => 'You are not allowed to perform this action.',
        'model_not_found' => 'The requested item was not found.',
        'route_not_found' => 'The requested URL was not found.',
        'method_not_allowed' => 'Method not allowed.',
        'too_many_requests' => 'Too many attempts. Please try again later.',
        'invalid_signature' => 'The link is invalid or has expired.',
        'server_error' => 'Something went wrong. Please try again later.',
    ],

    'otp' => [
        'sms' => 'Your verification code is :code. It is valid for :minutes minutes. Do not share it.',
        'sent' => 'A verification code has been sent to your phone.',
        'invalid' => 'The verification code is invalid or has expired.',
    ],

    'auth' => [
        'logged_in' => 'Logged in successfully.',
        'logged_out' => 'Logged out successfully.',
        'registered' => 'Account created successfully.',
        'complete_registration' => 'Phone verified. Please complete your registration.',
        'registration_token_invalid' => 'Registration session is invalid or expired. Please request a new code.',
        'phone_taken' => 'This phone number is already registered.',
        'account_disabled' => 'This account is disabled. Please contact customer service.',
        'invalid_credentials' => 'Invalid phone number or password.',
    ],

    'payment' => [
        'started' => 'Payment created. Complete it on the payment provider page.',
    ],

    'customer' => [
        'blocked' => 'Customer account blocked.',
        'activated' => 'Customer account activated.',
    ],

    'pricing' => [
        'saved' => 'Pricing saved.',
        'deleted' => 'Band deleted.',
        'overlap' => 'This band overlaps an existing band (:min - :max).',
    ],

    'profile' => [
        'documents_uploaded' => 'Documents uploaded successfully.',
    ],

    'vehicle' => [
        'created' => 'Vehicle added successfully.',
        'updated' => 'Vehicle updated successfully.',
        'deleted' => 'Vehicle deleted successfully.',
        'not_owner' => 'This vehicle is not registered to you.',
        'locked_by_policy' => 'A vehicle with an active or pending policy cannot be modified.',
        'has_policies' => 'A vehicle with insurance policies cannot be deleted.',
    ],

    'quote' => [
        'coverage_inactive' => 'The selected coverage type is not available.',
        'missing_factor' => 'No pricing factor is configured for (:factor) with value :value. Please contact customer service.',
    ],

    'policy' => [
        'created' => 'Policy created. Please complete the payment to activate it.',
        'cancelled' => 'Policy cancelled.',
        'payment_confirmed' => 'Payment confirmed and policy activated.',
        'not_owner' => 'This policy is not registered to you.',
        'not_active' => 'The policy document is available only after activation.',
        'not_pending' => 'This policy is not awaiting payment.',
        'kyc_required' => 'Please upload your identity document and driving license images before issuing a policy.',
        'overlap' => 'This vehicle already has an active or pending policy for the same period.',
    ],

];
