<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * People a customer can insure (themselves, family members): used by travel insurance.
     */
    public function up(): void
    {
        Schema::create('insured_persons', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('full_name', 100);
            $table->string('relationship', 20);
            $table->date('birth_date');
            $table->string('passport_no', 20)->nullable();
            $table->string('national_id', 12)->nullable();
            $table->timestamps();

            $table->index(['user_id', 'full_name']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('insured_persons');
    }
};
