<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class ArtisanSeeder extends Seeder
{
    public function run(): void
    {
        $now = now();

        $artisans = [
            [
                'full_name'       => 'Youssef Benmoussa',
                'email'           => 'youssef.benmoussa@atlasfixtest.ma',
                'phone'           => '0612345601',
                'city'            => 'Casablanca',
                'business_name'   => 'Plomberie Benmoussa',
                'bio'             => 'Plombier professionnel avec plus de 10 ans d\'expérience. Intervention rapide et travail soigné.',
                'experience_years'=> 10,
                'category'        => 'Plomberie',
                'rating_average'  => 4.7,
                'total_reviews'   => 38,
                'total_jobs'      => 52,
            ],
            [
                'full_name'       => 'Khalid Ezzahouri',
                'email'           => 'khalid.ezzahouri@atlasfixtest.ma',
                'phone'           => '0612345602',
                'city'            => 'Rabat',
                'business_name'   => 'Électricité Ezzahouri',
                'bio'             => 'Électricien certifié, spécialisé en installation résidentielle et dépannage d\'urgence.',
                'experience_years'=> 8,
                'category'        => 'Électricité',
                'rating_average'  => 4.5,
                'total_reviews'   => 24,
                'total_jobs'      => 31,
            ],
            [
                'full_name'       => 'Rachid Oufkir',
                'email'           => 'rachid.oufkir@atlasfixtest.ma',
                'phone'           => '0612345603',
                'city'            => 'Marrakech',
                'business_name'   => 'Peinture Oufkir',
                'bio'             => 'Peintre décorateur, travaux intérieurs et extérieurs. Finitions impeccables garanties.',
                'experience_years'=> 12,
                'category'        => 'Peinture',
                'rating_average'  => 4.8,
                'total_reviews'   => 61,
                'total_jobs'      => 74,
            ],
            [
                'full_name'       => 'Hamza Tazi',
                'email'           => 'hamza.tazi@atlasfixtest.ma',
                'phone'           => '0612345604',
                'city'            => 'Fès',
                'business_name'   => 'Tech Repair Tazi',
                'bio'             => 'Réparation de téléphones, tablettes et ordinateurs. Diagnostic gratuit.',
                'experience_years'=> 5,
                'category'        => 'Réparation Téléphones & Tablettes',
                'rating_average'  => 4.3,
                'total_reviews'   => 17,
                'total_jobs'      => 29,
            ],
            [
                'full_name'       => 'Soufiane Idrissi',
                'email'           => 'soufiane.idrissi@atlasfixtest.ma',
                'phone'           => '0612345605',
                'city'            => 'Casablanca',
                'business_name'   => 'Nettoyage Pro Idrissi',
                'bio'             => 'Service de nettoyage professionnel pour maisons et bureaux. Équipe sérieuse et équipée.',
                'experience_years'=> 6,
                'category'        => 'Nettoyage',
                'rating_average'  => 4.6,
                'total_reviews'   => 43,
                'total_jobs'      => 58,
            ],
            [
                'full_name'       => 'Amine Lahlou',
                'email'           => 'amine.lahlou@atlasfixtest.ma',
                'phone'           => '0612345606',
                'city'            => 'Agadir',
                'business_name'   => 'Climatisation Lahlou',
                'bio'             => 'Technicien HVAC certifié. Installation, entretien et réparation de climatiseurs toutes marques.',
                'experience_years'=> 9,
                'category'        => 'Chauffage, Ventilation et Climatisation',
                'rating_average'  => 4.4,
                'total_reviews'   => 29,
                'total_jobs'      => 41,
            ],
            [
                'full_name'       => 'Omar Berrada',
                'email'           => 'omar.berrada@atlasfixtest.ma',
                'phone'           => '0612345607',
                'city'            => 'Tanger',
                'business_name'   => 'Déménagement Berrada',
                'bio'             => 'Service de déménagement rapide et sécurisé. Camion et équipe disponibles 7j/7.',
                'experience_years'=> 7,
                'category'        => 'Déménagement',
                'rating_average'  => 4.2,
                'total_reviews'   => 21,
                'total_jobs'      => 33,
            ],
            [
                'full_name'       => 'Mehdi Cherkaoui',
                'email'           => 'mehdi.cherkaoui@atlasfixtest.ma',
                'phone'           => '0612345608',
                'city'            => 'Casablanca',
                'business_name'   => 'Mécanique Cherkaoui',
                'bio'             => 'Mécanicien mobile, je me déplace chez vous pour tout dépannage auto.',
                'experience_years'=> 11,
                'category'        => 'Mécanicien Mobile',
                'rating_average'  => 4.9,
                'total_reviews'   => 55,
                'total_jobs'      => 67,
            ],
        ];

        // Load category IDs once
        $categoryMap = DB::table('service_categories')
            ->pluck('id', 'name');

        foreach ($artisans as $data) {
            // Skip if user already exists
            if (DB::table('users')->where('email', $data['email'])->exists()) {
                continue;
            }

            $userId = DB::table('users')->insertGetId([
                'account_type'      => 'artisan',
                'auth_provider'     => 'email',
                'full_name'         => $data['full_name'],
                'birth_date'        => '1990-01-01',
                'email'             => $data['email'],
                'phone'             => $data['phone'],
                'password'          => Hash::make('password123'),
                'is_active'         => true,
                'email_verified_at' => $now,
                'created_at'        => $now,
                'updated_at'        => $now,
            ]);

            $categoryId = $categoryMap[$data['category']] ?? null;

            $artisanId = DB::table('artisans')->insertGetId([
                'user_id'              => $userId,
                'service_category_id'  => $categoryId,
                'business_name'        => $data['business_name'],
                'bio'                  => $data['bio'],
                'experience_years'     => $data['experience_years'],
                'city'                 => $data['city'],
                'referral_code'        => strtoupper(Str::random(8)),
                'rating_average'       => $data['rating_average'],
                'total_reviews'        => $data['total_reviews'],
                'total_jobs_completed' => $data['total_jobs'],
                'is_available'         => true,
                'is_verified'          => true,
                'profile_completed'    => true,
                'confidence_score'     => round($data['rating_average'] * 20, 2),
                'created_at'           => $now,
                'updated_at'           => $now,
            ]);

            // Add an artisan_service entry for their primary category
            if ($categoryId) {
                DB::table('artisan_services')->insert([
                    'artisan_id'          => $artisanId,
                    'service_category_id' => $categoryId,
                    'description'         => $data['bio'],
                    'created_at'          => $now,
                    'updated_at'          => $now,
                ]);
            }
        }
    }
}
