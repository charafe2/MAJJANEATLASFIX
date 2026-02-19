<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('artisan_badges', function (Blueprint $table) {
            $table->id();
            $table->foreignId('artisan_id')->constrained('artisans')->cascadeOnDelete();
            $table->enum('badge_type', [
                'top_rated',
                'fast_response',
                'verified_pro',
                'new_comer',
                'trusted',
                'expert',
            ]);
            $table->boolean('is_active')->default(true);
            $table->dateTime('earned_at');
            $table->timestamps();

            $table->index('artisan_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('artisan_badges');
    }
};
