<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('client_reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_request_id')->constrained('service_requests')->cascadeOnDelete();
            $table->foreignId('artisan_id')->constrained('artisans')->cascadeOnDelete();
            $table->foreignId('client_id')->constrained('clients')->cascadeOnDelete();
            $table->unsignedTinyInteger('rating'); // 1-5
            $table->unsignedTinyInteger('payment_reliability'); // 1-5
            $table->timestamps();

            $table->index('artisan_id');
            $table->index('client_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('client_reviews');
    }
};
