<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('artisan_subscriptions', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('artisan_id');
            $table->unsignedBigInteger('subscription_tier_id');
            $table->date('start_date');
            $table->date('end_date')->nullable();           // null = active indefinitely (basic/free)
            $table->enum('status', [
                'active',
                'expired',
                'cancelled',
                'pending',
            ])->default('active');
            $table->unsignedBigInteger('payment_id')->nullable(); // null for basic (free)
            $table->timestamps();

            // ── Foreign keys ──────────────────────────────────────────────
            $table->foreign('artisan_id')
                  ->references('id')->on('artisans')
                  ->onDelete('cascade');

            $table->foreign('subscription_tier_id')
                  ->references('id')->on('subscription_tiers')
                  ->onDelete('restrict');

            // payment_id FK added after payments table exists (see payments migration)
            // We leave it as a plain column here and add the constraint in the payments migration.

            // ── Indexes ───────────────────────────────────────────────────
            $table->index('artisan_id');
            $table->index('subscription_tier_id');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('artisan_subscriptions');
    }
};