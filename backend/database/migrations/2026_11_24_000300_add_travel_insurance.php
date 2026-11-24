<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Policies are no longer always about a vehicle:
     *  - policies.user_id   the policyholder (was reached through the vehicle)
     *  - policies.product   motor | travel
     *  - vehicle / coverage type are motor-only, travel zone / days are travel-only
     */
    public function up(): void
    {
        Schema::table('policies', function (Blueprint $table) {
            $table->foreignId('user_id')->nullable()->after('policy_no')->constrained()->restrictOnDelete();
            $table->string('product', 30)->default('motor')->after('user_id');
            $table->string('travel_zone', 20)->nullable()->after('coverage_type_id');
            $table->unsignedSmallInteger('travel_days')->nullable()->after('travel_zone');
        });

        DB::statement('UPDATE policies SET user_id = (SELECT vehicles.user_id FROM vehicles WHERE vehicles.id = policies.vehicle_id)');

        Schema::table('policies', function (Blueprint $table) {
            $table->foreignId('user_id')->nullable(false)->change();
            $table->foreignId('vehicle_id')->nullable()->change();
            $table->foreignId('coverage_type_id')->nullable()->change();

            $table->index(['user_id', 'status']);
        });

        Schema::create('travel_rates', function (Blueprint $table) {
            $table->id();
            $table->string('zone', 20);
            $table->unsignedSmallInteger('days');
            // Price per traveller for the whole trip.
            $table->decimal('price', 10, 2);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['zone', 'days']);
        });

        Schema::create('policy_travellers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('policy_id')->constrained()->cascadeOnDelete();
            // Snapshot below stays on the policy even if the person is edited or deleted later.
            $table->foreignId('insured_person_id')->nullable()->constrained('insured_persons')->nullOnDelete();
            $table->string('full_name', 100);
            $table->date('birth_date');
            $table->string('passport_no', 20);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('policy_travellers');
        Schema::dropIfExists('travel_rates');

        Schema::table('policies', function (Blueprint $table) {
            $table->dropIndex(['user_id', 'status']);
            $table->dropConstrainedForeignId('user_id');
            $table->dropColumn(['product', 'travel_zone', 'travel_days']);
        });
    }
};
