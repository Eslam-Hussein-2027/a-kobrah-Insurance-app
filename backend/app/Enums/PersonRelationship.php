<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

/** How an insured person relates to the account holder. */
enum PersonRelationship: string
{
    use HasLabel;

    case Self = 'self';
    case Spouse = 'spouse';
    case Child = 'child';
    case Parent = 'parent';
    case Sibling = 'sibling';
    case Other = 'other';

    public static function translationGroup(): string
    {
        return 'person_relationship';
    }
}
