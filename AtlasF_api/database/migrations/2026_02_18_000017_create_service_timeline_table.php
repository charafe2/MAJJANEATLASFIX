<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('service_timeline', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_request_id')->constrained('service_requests')->cascadeOnDelete();
            $table->enum('event_type', [
                'created',
                'offer_submitted',
                'offer_accepted',
                'started',
                'completed',
                'cancelled',
                'payment_made',
            ]);
            $table->foreignId('triggered_by_user_id')->constrained('users')->restrictOnDelete();
            $table->timestamp('created_at')->useCurrent();

            $table->index('service_request_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('service_timeline');
    }
};
