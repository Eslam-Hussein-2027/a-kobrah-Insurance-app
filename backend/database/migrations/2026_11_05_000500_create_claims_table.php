<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('claims', function (Blueprint $table) {
            $table->id();
            $table->string('claim_no', 20)->unique();
            $table->foreignId('policy_id')->constrained()->restrictOnDelete();
            $table->dateTime('incident_date');
            $table->decimal('lat', 10, 7);
            $table->decimal('lng', 10, 7);
            $table->text('description');
            $table->string('other_party_name', 100)->nullable();
            $table->string('other_party_plate', 20)->nullable();
            $table->foreignId('other_party_policy_id')->nullable()->constrained('policies')->nullOnDelete();
            $table->string('status', 30)->default('SUBMITTED')->index();
            $table->decimal('estimated_cost', 12, 2)->nullable();
            $table->decimal('approved_amount', 12, 2)->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamps();

            $table->index(['policy_id', 'incident_date']);
        });

        Schema::create('claim_media', function (Blueprint $table) {
            $table->id();
            $table->foreignId('claim_id')->constrained()->cascadeOnDelete();
            $table->string('file_path');
            $table->string('type', 20);                          // DAMAGE | POLICE_REPORT
            $table->string('image_hash', 64)->nullable()->index(); // duplicate-image fraud detection (phase 4)
            $table->timestamps();
        });

        Schema::create('inspections', function (Blueprint $table) {
            $table->id();
            $table->foreignId('claim_id')->constrained()->cascadeOnDelete();
            $table->foreignId('surveyor_id')->constrained('users')->restrictOnDelete();
            // Nullable: the row is created on assignment and completed by the surveyor.
            $table->text('report')->nullable();
            $table->decimal('cost_estimate', 12, 2)->nullable();
            $table->timestamp('inspected_at')->nullable();
            $table->timestamps();
        });

        Schema::create('claim_status_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('claim_id')->constrained()->cascadeOnDelete();
            $table->string('from_status', 30)->nullable(); // NULL for the initial SUBMITTED entry
            $table->string('to_status', 30);
            $table->foreignId('changed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->text('note')->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['claim_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('claim_status_logs');
        Schema::dropIfExists('inspections');
        Schema::dropIfExists('claim_media');
        Schema::dropIfExists('claims');
    }
};
