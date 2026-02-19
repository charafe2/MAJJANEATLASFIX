<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cancellations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_request_id')->constrained('service_requests')->cascadeOnDelete();
            $table->foreignId('cancelled_by_user_id')->constrained('users')->restrictOnDelete();
            $table->integer('hours_before_service')->nullable();
            $table->boolean('is_penalty_applied')->default(false);
            $table->decimal('penalty_amount', 10, 2)->default(0);
            $table->timestamps();

            $table->index('service_request_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cancellations');
    }
};
