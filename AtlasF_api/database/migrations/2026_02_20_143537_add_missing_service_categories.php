<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $missing = [
            ['name' => 'Menuiserie', 'icon' => '🪵', 'display_order' => 28],
            ['name' => 'Maçonnerie', 'icon' => '🧱', 'display_order' => 29],
            ['name' => 'Carrelage',  'icon' => '🔲', 'display_order' => 30],
            ['name' => 'Jardinage',  'icon' => '🌿', 'display_order' => 31],
        ];

        $now = now();
        foreach ($missing as $cat) {
            if (DB::table('service_categories')->where('name', $cat['name'])->exists()) {
                continue;
            }
            DB::table('service_categories')->insert(array_merge($cat, [
                'is_active'  => true,
                'created_at' => $now,
                'updated_at' => $now,
            ]));
        }
    }

    public function down(): void
    {
        DB::table('service_categories')
            ->whereIn('name', ['Menuiserie', 'Maçonnerie', 'Carrelage', 'Jardinage'])
            ->delete();
    }
};
