<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100);
            $table->string('phone', 20)->unique();
            // Nullable for staff accounts; required for customers at registration.
            $table->string('national_id', 20)->nullable()->unique();
            // Nullable: customers authenticate with OTP. Reserved for staff/dashboard login.
            $table->string('password')->nullable();
            // Primary role (denormalized for fast filtering). Permissions are managed by spatie/laravel-permission.
            $table->string('role', 20)->default('customer')->index();
            $table->string('id_image')->nullable();
            $table->string('license_image')->nullable();
            $table->timestamp('phone_verified_at')->nullable();
            $table->boolean('is_active')->default(true);
            $table->rememberToken();
            $table->timestamps();
        });

        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sessions');
        Schema::dropIfExists('users');
    }
};
