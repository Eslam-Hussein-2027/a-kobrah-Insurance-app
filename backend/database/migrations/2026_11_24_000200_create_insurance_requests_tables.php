<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Requests for products that staff price and issue manually
     * (orange card, foreign workers, medical liability, marine cargo).
     */
    public function up(): void
    {
        Schema::create('insurance_requests', function (Blueprint $table) {
            $table->id();
            $table->string('request_no', 20)->unique();
            $table->foreignId('user_id')->constrained()->restrictOnDelete();
            $table->string('product', 30);
            $table->string('kind', 10);
            $table->string('status', 20)->default('SUBMITTED');
            // Answers to the product's form fields: {"field_key": "value", ...}
            $table->json('details');
            $table->text('notes')->nullable();
            $table->text('staff_reply')->nullable();
            $table->decimal('quoted_amount', 12, 2)->nullable();
            $table->foreignId('handled_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('replied_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'status']);
            $table->index(['status', 'created_at']);
        });

        Schema::create('insurance_request_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('insurance_request_id')->constrained()->cascadeOnDelete();
            $table->string('document_key', 40);
            $table->string('path');
            $table->string('original_name');
            $table->string('mime_type', 100);
            $table->unsignedInteger('size');
            $table->timestamps();

            $table->unique(['insurance_request_id', 'document_key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('insurance_request_documents');
        Schema::dropIfExists('insurance_requests');
    }
};
