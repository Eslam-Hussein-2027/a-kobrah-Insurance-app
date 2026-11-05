<?php

namespace App\Support;

/**
 * Egyptian plates mix Arabic letters and digits ("ق ط ن 1234"), and users type them
 * inconsistently (with/without spaces, Arabic/Western digits).
 */
final class PlateNumber
{
    /** Display/storage form: Western digits, single spaces, upper-case latin. */
    public static function format(string $plate): string
    {
        $plate = (string) Digits::toWestern($plate);
        $plate = preg_replace('/\s+/u', ' ', $plate) ?? $plate;

        return mb_strtoupper(trim($plate));
    }

    /** Comparison key: same as format() but without any whitespace or dashes. */
    public static function key(string $plate): string
    {
        return preg_replace('/[\s\-]+/u', '', self::format($plate)) ?? '';
    }

    public static function equals(string $a, string $b): bool
    {
        return self::key($a) === self::key($b);
    }
}
