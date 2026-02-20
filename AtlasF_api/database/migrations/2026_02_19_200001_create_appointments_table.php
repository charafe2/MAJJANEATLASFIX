<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('appointments', function (Blueprint $table) {
            $table->id();

            // The artisan who owns / created the appointment
            $table->foreignId('artisan_id')
                  ->nullable()
                  ->constrained('artisans')
                  ->nullOnDelete();

            // The client (may be null for off-platform clients)
            $table->foreignId('client_id')
                  ->nullable()
                  ->constrained('clients')
                  ->nullOnDelete();

            // Optional link to a service request
            $table->foreignId('service_request_id')
                  ->nullable()
                  ->constrained('service_requests')
                  ->nullOnDelete();

            $table->string('title');
            $table->string('client_name', 255)->nullable();  // free-text when no linked client
            $table->string('client_phone', 30)->nullable();

            $table->dateTime('scheduled_at');
            $table->unsignedSmallInteger('duration_minutes')->nullable();

            $table->enum('status', ['scheduled', 'completed', 'cancelled'])->default('scheduled');
            $table->enum('rdv_type', ['sur_place', 'visioconference'])->default('sur_place');

            $table->string('city', 100)->nullable();
            $table->text('notes')->nullable();

            $table->timestamps();

            $table->index('artisan_id');
            $table->index('client_id');
            $table->index('scheduled_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('appointments');
    }
};
