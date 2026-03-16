<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TestimonialSeeder extends Seeder
{
    public function run(): void
    {
        if (DB::table('testimonials')->exists()) {
            return;
        }

        $now = now();

        $testimonials = [
            [
                'name'          => 'Karim Benali',
                'role'          => 'Client',
                'text'          => "J'ai trouvé un excellent plombier en moins de 10 minutes. Le service était rapide, propre et professionnel. Je recommande vivement AtlasFix à tous.",
                'display_order' => 1,
            ],
            [
                'name'          => 'Fatima Zahra',
                'role'          => 'Cliente',
                'text'          => "Très bonne expérience ! L'artisan est arrivé à l'heure, a bien expliqué le problème et le prix était transparent. Pas de mauvaises surprises.",
                'display_order' => 2,
            ],
            [
                'name'          => 'Youssef Alami',
                'role'          => 'Client',
                'text'          => "Plateforme très simple à utiliser. J'ai comparé trois devis et choisi le meilleur. Le paiement en ligne est sécurisé et le suivi est top.",
                'display_order' => 3,
            ],
            [
                'name'          => 'Nadia Chraibi',
                'role'          => 'Cliente',
                'text'          => "Artisan ponctuel et très compétent. Le travail de peinture est impeccable. Je referai appel à AtlasFix sans hésitation pour mes prochains travaux.",
                'display_order' => 4,
            ],
            [
                'name'          => 'Omar Tazi',
                'role'          => 'Client',
                'text'          => "Excellent service de bout en bout. La réservation est simple, l'artisan vérifié et le résultat parfait. Une vraie plateforme de confiance.",
                'display_order' => 5,
            ],
            [
                'name'          => 'Salma El Amrani',
                'role'          => 'Cliente',
                'text'          => "J'avais besoin d'un électricien en urgence un dimanche. En 20 minutes j'avais trois offres. Problème résolu en une heure. Incroyable !",
                'display_order' => 6,
            ],
            [
                'name'          => 'Anas Hajji',
                'role'          => 'Client',
                'text'          => "Le système de notation m'a vraiment aidé à choisir. L'artisan avait 4,9 étoiles et franchement ça se voit dans la qualité du travail.",
                'display_order' => 7,
            ],
            [
                'name'          => 'Houda Bakkali',
                'role'          => 'Cliente',
                'text'          => "Déménagement sans stress grâce à AtlasFix. L'équipe était professionnelle, rapide et aucun meuble abîmé. Prix honnête et devis immédiat.",
                'display_order' => 8,
            ],
            [
                'name'          => 'Mehdi Ouzzani',
                'role'          => 'Artisan',
                'text'          => "En tant qu'artisan, la plateforme m'a permis de doubler mes clients en un mois. Les demandes sont sérieuses et le paiement est toujours sécurisé.",
                'display_order' => 9,
            ],
            [
                'name'          => 'Zineb Moussaoui',
                'role'          => 'Cliente',
                'text'          => "Interface très claire, géolocalisation précise et artisans vérifiés. Enfin une solution fiable pour trouver de l'aide à domicile au Maroc.",
                'display_order' => 10,
            ],
        ];

        foreach ($testimonials as &$t) {
            $t['is_visible'] = true;
            $t['created_at'] = $now;
            $t['updated_at'] = $now;
        }

        DB::table('testimonials')->insert($testimonials);
    }
}
