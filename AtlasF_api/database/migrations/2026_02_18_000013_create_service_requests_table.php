<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('service_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('client_id')->constrained('clients')->cascadeOnDelete();
            $table->foreignId('service_category_id')->constrained('service_categories')->restrictOnDelete();
            $table->foreignId('service_type_id')->constrained('service_types')->restrictOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('city', 100);
            $table->decimal('budget_min', 10, 2)->nullable();
            $table->decimal('budget_max', 10, 2)->nullable();
            $table->enum('status', ['open', 'in_progress', 'completed', 'cancelled'])->default('open');

            // accepted_offer_id column only — FK added in migration 16 (circular dep)
            $table->unsignedBigInteger('accepted_offer_id')->nullable();

            $table->foreignId('payment_id')->nullable()->constrained('payments')->nullOnDelete();
            $table->enum('request_type', ['public', 'direct'])->default('public');
            $table->foreignId('target_artisan_id')->nullable()->constrained('artisans')->nullOnDelete();
            $table->timestamps();

            $table->index('client_id');
            $table->index('status');
            $table->index('city');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('service_requests');
    }
};
