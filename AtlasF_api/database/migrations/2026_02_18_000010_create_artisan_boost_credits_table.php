<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('artisan_boost_credits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('artisan_id')->constrained('artisans')->cascadeOnDelete();
            $table->integer('boost_duration_hours');
            $table->enum('source', ['referral', 'subscription', 'purchase', 'promotion']);
            $table->boolean('is_used')->default(false);
            $table->dateTime('expires_at')->nullable();
            $table->timestamps();

            $table->index('artisan_id');
            $table->index('is_used');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('artisan_boost_credits');
    }
};
