<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('artisan_offers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_request_id')->constrained('service_requests')->cascadeOnDelete();
            $table->foreignId('artisan_id')->constrained('artisans')->cascadeOnDelete();
            $table->decimal('proposed_price', 10, 2);
            $table->integer('estimated_duration'); // in minutes
            $table->text('description')->nullable();
            $table->enum('status', ['pending', 'accepted', 'rejected', 'withdrawn'])->default('pending');
            $table->boolean('has_active_boost')->default(false);
            $table->timestamps();

            $table->index('service_request_id');
            $table->index('artisan_id');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('artisan_offers');
    }
};
