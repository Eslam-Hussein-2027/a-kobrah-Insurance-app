<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->string('gateway', 30)->nullable()->after('method');       // simulator | sadad | moamalat | ...
            $table->text('checkout_url')->nullable()->after('gateway_ref');
            $table->string('failure_reason')->nullable()->after('status');
            // Money was captured but the policy could no longer be activated (cancelled / already paid at office).
            $table->boolean('requires_refund')->default(false)->after('failure_reason');
            $table->json('gateway_payload')->nullable()->after('requires_refund'); // last raw status, for audit
        });
    }

    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropColumn(['gateway', 'checkout_url', 'failure_reason', 'requires_refund', 'gateway_payload']);
        });
    }
};
