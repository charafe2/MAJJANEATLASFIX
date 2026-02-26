<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BoostPackageSeeder extends Seeder
{
    public function run(): void
    {
        // Avoid duplicate seeding
        if (DB::table('boost_packages')->count() > 0) {
            return;
        }

        DB::table('boost_packages')->insert([
            [
                'name'           => 'Boost 24h',
                'duration_hours' => 24,
                'price'          => 50.00,
                'is_popular'     => false,
                'created_at'     => now(),
                'updated_at'     => now(),
            ],
            [
                'name'           => 'Boost 7 jours',
                'duration_hours' => 168,
                'price'          => 170.00,
                'is_popular'     => true,
                'created_at'     => now(),
                'updated_at'     => now(),
            ],
            [
                'name'           => 'Boost 30 jours',
                'duration_hours' => 720,
                'price'          => 300.00,
                'is_popular'     => false,
                'created_at'     => now(),
                'updated_at'     => now(),
            ],
        ]);
    }
}
