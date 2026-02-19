<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('artisan_portfolios', function (Blueprint $table) {
            $table->id();
            $table->foreignId('artisan_id')->constrained('artisans')->cascadeOnDelete();
            $table->foreignId('service_category_id')->nullable()->constrained('service_categories')->nullOnDelete();
            $table->string('image_url');
            $table->string('title', 150)->nullable();
            $table->boolean('is_visible')->default(true);
            $table->timestamps();

            $table->index('artisan_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('artisan_portfolios');
    }
};
