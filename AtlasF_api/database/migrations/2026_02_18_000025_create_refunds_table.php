<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('refunds', function (Blueprint $table) {
            $table->id();
            $table->foreignId('payment_id')->constrained('payments')->restrictOnDelete();
            $table->foreignId('service_request_id')->nullable()->constrained('service_requests')->nullOnDelete();
            $table->enum('refund_type', ['full', 'partial', 'penalty']);
            $table->decimal('refund_amount', 10, 2);
            $table->enum('status', ['pending', 'processed', 'rejected'])->default('pending');
            $table->timestamps();

            $table->index('payment_id');
            $table->index('service_request_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('refunds');
    }
};
