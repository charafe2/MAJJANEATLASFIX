<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('referrals', function (Blueprint $table) {
            $table->id();

            $table->unsignedBigInteger('referrer_id');
            $table->unsignedBigInteger('referred_id');
            $table->string('referral_code_used', 50);
            $table->enum('status', ['pending', 'completed', 'expired'])->default('pending');
            $table->foreignId('reward_boost_credit_id')->nullable()->constrained('artisan_boost_credits')->nullOnDelete();
            $table->timestamps();

            $table->foreign('referrer_id')->references('id')->on('users')->onDelete('restrict');
            $table->foreign('referred_id')->references('id')->on('users')->onDelete('restrict');

            $table->unique('referred_id');
            $table->index('referrer_id');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('referrals');
    }
};
