<?php

namespace App\Support;

/**
 * Privacy helper for public pages: "محمد أحمد علي" → "محمد أ. ع."
 * Enough for an inspector to match the driver's ID, without publishing full names.
 */
final class PersonName
{
    public static function mask(string $name): string
    {
        $parts = preg_split('/\s+/u', trim($name), -1, PREG_SPLIT_NO_EMPTY) ?: [];
        $first = array_shift($parts) ?? '';

        $initials = array_map(fn (string $part) => mb_substr($part, 0, 1).'.', $parts);

        return trim($first.' '.implode(' ', $initials));
    }
}
