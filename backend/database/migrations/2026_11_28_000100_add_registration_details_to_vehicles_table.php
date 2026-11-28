<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Registration details asked when adding a vehicle (owner, colour, country, licence purpose,
 * seats, licensing authority). Nullable so vehicles added before stay valid; the app asks to
 * complete them before a new policy is issued.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('vehicles', function (Blueprint $table) {
            $table->string('owner_name', 120)->nullable()->after('user_id');
            $table->string('owner_address', 255)->nullable()->after('owner_name');
            $table->string('color', 20)->nullable()->after('engine_cc');
            $table->string('country_of_origin', 30)->nullable()->after('color');
            $table->string('license_purpose', 30)->nullable()->after('country_of_origin');
            $table->unsignedTinyInteger('seats')->nullable()->after('license_purpose');
            $table->string('licensing_authority', 40)->nullable()->after('seats');
        });
    }

    public function down(): void
    {
        Schema::table('vehicles', function (Blueprint $table) {
            $table->dropColumn([
                'owner_name', 'owner_address', 'color', 'country_of_origin', 'license_purpose', 'seats', 'licensing_authority',
            ]);
        });
    }
};
