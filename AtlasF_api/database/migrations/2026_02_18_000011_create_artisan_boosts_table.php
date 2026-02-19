<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('artisan_boosts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('artisan_id')->constrained('artisans')->cascadeOnDelete();
            $table->foreignId('service_category_id')->nullable()->constrained('service_categories')->nullOnDelete();
            $table->foreignId('boost_package_id')->nullable()->constrained('boost_packages')->nullOnDelete();
            $table->foreignId('boost_credit_id')->nullable()->constrained('artisan_boost_credits')->nullOnDelete();
            $table->enum('boost_type', ['paid', 'credit']);
            $table->dateTime('start_date');
            $table->dateTime('end_date');
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index('artisan_id');
            $table->index('is_active');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('artisan_boosts');
    }
};
