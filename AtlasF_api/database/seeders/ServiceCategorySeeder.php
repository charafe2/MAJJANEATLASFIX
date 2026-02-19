<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ServiceCategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Réparations générales',             'icon' => '🔧', 'display_order' => 1],
            ['name' => 'Plomberie',                          'icon' => '🚿', 'display_order' => 2],
            ['name' => 'Électricité',                        'icon' => '⚡', 'display_order' => 3],
            ['name' => 'Peinture',                           'icon' => '🎨', 'display_order' => 4],
            ['name' => 'Électroménager',                     'icon' => '🔌', 'display_order' => 5],
            ['name' => 'Nettoyage',                          'icon' => '🧹', 'display_order' => 6],
            ['name' => 'Déménagement',                       'icon' => '📦', 'display_order' => 7],
            ['name' => 'Chauffage, Ventilation et Climatisation', 'icon' => '❄️', 'display_order' => 8],
            ['name' => 'Mécanicien Mobile',                  'icon' => '🔩', 'display_order' => 9],
            ['name' => 'Vidange Mobile',                     'icon' => '🛢️', 'display_order' => 10],
            ['name' => 'Assistance Routière',                'icon' => '🚗', 'display_order' => 11],
            ['name' => "Organisation d'Événements",          'icon' => '🎉', 'display_order' => 12],
            ['name' => 'Photographie',                       'icon' => '📷', 'display_order' => 13],
            ['name' => 'Vidéographie',                       'icon' => '🎥', 'display_order' => 14],
            ['name' => 'Musique & Animation',                'icon' => '🎵', 'display_order' => 15],
            ['name' => 'Beauté & Style',                     'icon' => '💅', 'display_order' => 16],
            ['name' => 'Services de Restauration',           'icon' => '🍽️', 'display_order' => 17],
            ['name' => "Décoration d'Événements",            'icon' => '🌸', 'display_order' => 18],
            ['name' => 'Location de Matériel',               'icon' => '🪑', 'display_order' => 19],
            ['name' => 'Réparation Ordinateurs',             'icon' => '💻', 'display_order' => 20],
            ['name' => 'Réseau & WiFi',                      'icon' => '📡', 'display_order' => 21],
            ['name' => 'Maison Connectée',                   'icon' => '🏠', 'display_order' => 22],
            ['name' => 'Support Technique',                  'icon' => '🖥️', 'display_order' => 23],
            ['name' => 'Réparation Téléphones & Tablettes',  'icon' => '📱', 'display_order' => 24],
            ['name' => 'Lavage auto à domicile',             'icon' => '🚿', 'display_order' => 25],
            ['name' => 'Car Detailing',                      'icon' => '✨', 'display_order' => 26],
            ['name' => 'Diagnostic OBD mobile',              'icon' => '🔍', 'display_order' => 27],
        ];

        $now = now();
        foreach ($categories as &$cat) {
            $cat['is_active']   = true;
            $cat['created_at']  = $now;
            $cat['updated_at']  = $now;
        }

        DB::table('service_categories')->insert($categories);
    }
}
