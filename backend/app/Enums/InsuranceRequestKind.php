<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

enum InsuranceRequestKind: string
{
    use HasLabel;

    /** The customer wants the policy issued. */
    case Issue = 'issue';
    /** The customer only wants a price offer. */
    case Quote = 'quote';

    public static function translationGroup(): string
    {
        return 'insurance_request_kind';
    }
}
