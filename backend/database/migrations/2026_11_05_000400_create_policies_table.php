<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('policies', function (Blueprint $table) {
            $table->id();
            $table->string('policy_no', 20)->unique();
            $table->foreignId('vehicle_id')->constrained()->restrictOnDelete();
            $table->foreignId('coverage_type_id')->constrained()->restrictOnDelete();
            $table->foreignId('previous_policy_id')->nullable()->constrained('policies')->nullOnDelete();
            $table->date('start_date');
            $table->date('end_date');
            $table->decimal('premium', 12, 2);
            // Factors and multipliers used at issuance time (factors are admin-editable, so we snapshot them).
            $table->json('pricing_snapshot')->nullable();
            $table->string('status', 20)->default('PENDING_PAYMENT');
            $table->string('pdf_path')->nullable();
            $table->timestamp('issued_at')->nullable();
            $table->timestamps();

            $table->index(['vehicle_id', 'status']);
            $table->index(['status', 'end_date']); // expiry jobs & renewal reminders
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('policies');
    }
};
