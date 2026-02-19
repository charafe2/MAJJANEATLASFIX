<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('artisans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('service_category_id')->nullable()->constrained('service_categories');

            $table->string('business_name')->nullable();
            $table->text('bio')->nullable();
            $table->integer('experience_years')->nullable();

            $table->string('city', 100)->nullable();
            $table->text('address')->nullable();

            $table->string('referral_code', 50)->unique();
            $table->foreignId('referred_by_id')->nullable()->constrained('artisans')->nullOnDelete();

            $table->decimal('rating_average', 3, 2)->default(0);
            $table->integer('total_reviews')->default(0);
            $table->integer('total_jobs_completed')->default(0);
            $table->decimal('total_revenue', 12, 2)->default(0);
            $table->integer('response_time_avg')->nullable();
            $table->decimal('confidence_score', 5, 2)->default(0);

            $table->boolean('is_available')->default(true);
            $table->boolean('is_verified')->default(false);
            $table->boolean('profile_completed')->default(false);
            $table->timestamp('subscription_expires_at')->nullable();

      
            $table->unsignedBigInteger('current_subscription_tier_id')->nullable();

            $table->timestamps();

            $table->index('city');
            $table->index('rating_average');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('artisans');
    }
};