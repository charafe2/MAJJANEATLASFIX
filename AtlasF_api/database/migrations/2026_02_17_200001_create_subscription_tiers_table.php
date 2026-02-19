<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscription_tiers', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('name');                         // basic, pro, premium, business
            $table->decimal('price', 10, 2);                // 0, 30, 75, 250
            $table->integer('max_offers_per_month');        // 5, 20, -1 (unlimited)
            $table->integer('max_team_members');            // 1, 1, 1, 10
            $table->boolean('is_popular')->default(false);  // highlights "premium"
            $table->timestamps();
        });

        // Seed the 4 tiers immediately so the FK in artisan_subscriptions is never broken
        DB::table('subscription_tiers')->insert([
            [
                'name'                 => 'basic',
                'price'                => 0.00,
                'max_offers_per_month' => 5,
                'max_team_members'     => 1,
                'is_popular'           => false,
                'created_at'           => now(),
                'updated_at'           => now(),
            ],
            [
                'name'                 => 'pro',
                'price'                => 30.00,
                'max_offers_per_month' => 20,
                'max_team_members'     => 1,
                'is_popular'           => false,
                'created_at'           => now(),
                'updated_at'           => now(),
            ],
            [
                'name'                 => 'premium',
                'price'                => 75.00,
                'max_offers_per_month' => -1,   // unlimited → check via < 0 in app logic
                'max_team_members'     => 1,
                'is_popular'           => true,
                'created_at'           => now(),
                'updated_at'           => now(),
            ],
            [
                'name'                 => 'business',
                'price'                => 250.00,
                'max_offers_per_month' => -1,
                'max_team_members'     => 10,
                'is_popular'           => false,
                'created_at'           => now(),
                'updated_at'           => now(),
            ],
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('subscription_tiers');
    }
};