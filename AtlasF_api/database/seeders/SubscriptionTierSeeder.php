<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\SubscriptionTier;

class SubscriptionTierSeeder extends Seeder
{
    public function run(): void
    {
        SubscriptionTier::firstOrCreate(['name' => 'Basic'],    ['price' => 0,   'description' => 'Plan Basic']);
        SubscriptionTier::firstOrCreate(['name' => 'Pro'],      ['price' => 30,  'description' => 'Plan Pro']);
        SubscriptionTier::firstOrCreate(['name' => 'Premium'],  ['price' => 75,  'description' => 'Plan Premium']);
        SubscriptionTier::firstOrCreate(['name' => 'Business'], ['price' => 250, 'description' => 'Plan Business']);
    }
}