<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;

/**
 * Generates sequential, yearly-reset document numbers: POL-2026-000001, CLM-2026-000001.
 *
 * Uses a row lock on document_sequences so concurrent requests never get the same number.
 * When called inside an outer transaction, the number is only "used" if that transaction commits.
 */
class DocumentNumberGenerator
{
    public function next(string $prefix, ?int $year = null): string
    {
        $year ??= (int) now()->format('Y');

        $number = DB::transaction(function () use ($prefix, $year): int {
            DB::table('document_sequences')->insertOrIgnore([
                'prefix' => $prefix,
                'year' => $year,
                'last_number' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $sequence = DB::table('document_sequences')
                ->where('prefix', $prefix)
                ->where('year', $year)
                ->lockForUpdate()
                ->first();

            $next = (int) $sequence->last_number + 1;

            DB::table('document_sequences')
                ->where('id', $sequence->id)
                ->update(['last_number' => $next, 'updated_at' => now()]);

            return $next;
        });

        return sprintf('%s-%d-%06d', $prefix, $year, $number);
    }
}
