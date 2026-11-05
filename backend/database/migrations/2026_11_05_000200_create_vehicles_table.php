<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vehicles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->restrictOnDelete();
            $table->string('plate_no', 20)->index();
            $table->string('vin', 17)->unique();
            $table->string('make', 50);
            $table->string('model', 50);
            $table->unsignedSmallInteger('year');
            $table->unsignedInteger('engine_cc');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vehicles');
    }
};
