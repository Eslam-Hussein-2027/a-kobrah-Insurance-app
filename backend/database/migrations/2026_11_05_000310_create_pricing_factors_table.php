<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pricing_factors', function (Blueprint $table) {
            $table->id();
            $table->string('factor_type', 30);              // vehicle_age | engine_cc | claims_history
            $table->unsignedInteger('min_value');            // inclusive
            $table->unsignedInteger('max_value')->nullable(); // inclusive; NULL = open-ended
            $table->decimal('multiplier', 6, 3);
            $table->timestamps();

            $table->index(['factor_type', 'min_value']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pricing_factors');
    }
};
