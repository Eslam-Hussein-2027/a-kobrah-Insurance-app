<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('coverage_types', function (Blueprint $table) {
            $table->id();
            $table->string('code', 30)->unique();      // THIRD_PARTY, COMPREHENSIVE
            $table->string('name', 100);               // Arabic (primary UI language)
            $table->string('name_en', 100)->nullable();
            $table->text('description')->nullable();
            $table->decimal('base_price', 12, 2);
            $table->boolean('is_mandatory')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('coverage_types');
    }
};
