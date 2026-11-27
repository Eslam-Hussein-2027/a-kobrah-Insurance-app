<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            // Wallet / bank app chosen by the customer (edfali, sadad, mobicash...), online payments only.
            $table->string('pay_method', 30)->nullable()->after('gateway');
        });
    }

    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropColumn('pay_method');
        });
    }
};
