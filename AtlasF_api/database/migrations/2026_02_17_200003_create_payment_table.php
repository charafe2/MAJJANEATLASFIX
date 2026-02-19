<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->bigIncrements('id');

            // Who pays, who receives
            $table->unsignedBigInteger('payer_id');         // FK → users.id
            $table->unsignedBigInteger('payee_id');         // FK → users.id (platform user or artisan)

            $table->enum('payment_type', [
                'subscription',     
                'service',          
                'boost',            
                'refund',
            ]);

            // Amount breakdown (matches your diagram)
            $table->decimal('service_amount',     10, 2)->default(0);
            $table->decimal('commission_amount',  10, 2)->default(0);
            $table->decimal('transaction_fee_amount', 10, 2)->default(0);
            $table->decimal('total_amount',       10, 2);

            $table->enum('status', [
                'pending',
                'completed',
                'failed',
                'refunded',
            ])->default('pending');

            $table->string('transaction_id')->nullable()->unique(); // gateway ref
            $table->timestamps();

            // ── Foreign keys ──────────────────────────────────────────────
            $table->foreign('payer_id')
                  ->references('id')->on('users')
                  ->onDelete('restrict');

            $table->foreign('payee_id')
                  ->references('id')->on('users')
                  ->onDelete('restrict');

            // ── Indexes ───────────────────────────────────────────────────
            $table->index('payer_id');
            $table->index('payee_id');
            $table->index('status');
            $table->index('payment_type');
        });

        // Now that payments exists, add the FK from artisan_subscriptions.payment_id
        Schema::table('artisan_subscriptions', function (Blueprint $table) {
            $table->foreign('payment_id')
                  ->references('id')->on('payments')
                  ->onDelete('set null');
        });
    }

    public function down(): void
    {
        // Drop the cross-table FK first to avoid constraint errors
        Schema::table('artisan_subscriptions', function (Blueprint $table) {
            $table->dropForeign(['payment_id']);
        });

        Schema::dropIfExists('payments');
    }
};