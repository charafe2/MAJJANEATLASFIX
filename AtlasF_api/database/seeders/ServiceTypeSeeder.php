<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ServiceTypeSeeder extends Seeder
{
    public function run(): void
    {
        // Map category name → service types
        $data = [
            'Réparations générales' => [
                'Plâtrerie & fissures',
                'Carrelage & faïence',
                'Menuiserie générale',
                'Vitrage & fenêtres',
                'Serrurerie',
                'Soudure',
            ],
            'Plomberie' => [
                'Installation sanitaire',
                'Réparation de fuites',
                'Débouchage',
                'Chauffe-eau',
                'WC & Lavabo',
            ],
            'Électricité' => [
                'Installation électrique',
                'Tableau électrique',
                'Prises & interrupteurs',
                'Éclairage',
                'Dépannage électrique',
            ],
            'Peinture' => [
                'Peinture intérieure',
                'Peinture extérieure',
                'Enduit & lissage',
                'Papier peint',
                'Ravalement de façade',
            ],
            'Électroménager' => [
                'Réfrigérateur & congélateur',
                'Machine à laver',
                'Four & cuisinière',
                'Lave-vaisselle',
                'Climatiseur & ventilateur',
            ],
            'Nettoyage' => [
                'Nettoyage appartement',
                'Nettoyage bureau',
                'Nettoyage après chantier',
                'Nettoyage canapé & tapis',
                'Nettoyage façade',
            ],
            'Déménagement' => [
                'Déménagement local',
                'Déménagement longue distance',
                'Transport de meubles',
                'Emballage & déballage',
                'Monte-meuble',
            ],
            'Chauffage, Ventilation et Climatisation' => [
                'Installation climatiseur',
                'Entretien climatiseur',
                'Chauffage central',
                'VMC & ventilation',
                'Chaudière',
            ],
            'Mécanicien Mobile' => [
                'Freins',
                'Vidange & filtres',
                'Batterie',
                'Diagnostic moteur',
                'Révision générale',
            ],
            'Vidange Mobile' => [
                'Vidange standard',
                'Vidange premium',
                'Changement filtre à air',
                'Vérification des niveaux',
            ],
            'Assistance Routière' => [
                'Panne moteur',
                'Pneu crevé',
                'Batterie à plat',
                'Remorquage',
                'Démarrage d\'urgence',
            ],
            "Organisation d'Événements" => [
                'Mariage',
                'Anniversaire',
                'Conférence & séminaire',
                "Soirée d'entreprise",
                'Baby shower',
            ],
            'Photographie' => [
                'Mariage',
                'Portrait',
                'Événements',
                'Immobilier',
                'Produits commerciaux',
            ],
            'Vidéographie' => [
                'Mariage',
                'Clip musical',
                'Événements',
                'Publicité',
                'Interview & corporate',
            ],
            'Musique & Animation' => [
                'DJ',
                'Groupe de musique',
                "Animateur enfants",
                'Karaoké',
                'Chanteur live',
            ],
            'Beauté & Style' => [
                'Coiffure à domicile',
                'Maquillage',
                'Manucure & Pédicure',
                'Massage',
                'Épilation',
            ],
            'Services de Restauration' => [
                'Traiteur',
                'Chef à domicile',
                'Buffet',
                'Barbecue',
                'Food truck',
            ],
            "Décoration d'Événements" => [
                'Décoration mariage',
                'Décoration anniversaire',
                'Fleurs & bouquets',
                'Ballons & guirlandes',
                'Décoration de table',
            ],
            'Location de Matériel' => [
                'Tables & chaises',
                'Tente & chapiteau',
                'Sono & éclairage',
                'Vaisselle & couverts',
                'Scène & estrade',
            ],
            'Réparation Ordinateurs' => [
                'Panne hardware',
                'Virus & logiciels',
                'Upgrade & performance',
                'Récupération de données',
                'Écran & clavier',
            ],
            'Réseau & WiFi' => [
                'Installation réseau',
                'Configuration WiFi',
                'Câblage réseau',
                'Dépannage réseau',
                'Extension WiFi (répéteur)',
            ],
            'Maison Connectée' => [
                'Domotique',
                'Caméras de surveillance',
                'Alarme & sécurité',
                'Smart home',
                'Interphone vidéo',
            ],
            'Support Technique' => [
                'Assistance informatique',
                'Formation utilisateur',
                'Configuration appareil',
                'Dépannage logiciel',
                'Installation système',
            ],
            'Réparation Téléphones & Tablettes' => [
                'Écran cassé',
                'Batterie',
                'Connecteur de charge',
                'Problème logiciel',
                'Caméra',
            ],
            'Lavage auto à domicile' => [
                'Lavage extérieur',
                'Lavage intérieur',
                'Lavage complet',
                'Nettoyage des vitres',
            ],
            'Car Detailing' => [
                'Polissage carrosserie',
                'Céramique & protection',
                'Nettoyage cuir',
                'Ozonisation',
                'Protection peinture',
            ],
            'Diagnostic OBD mobile' => [
                'Diagnostic complet',
                "Effacement codes d'erreur",
                'Rapport de diagnostic',
                'Contrôle technique préparatoire',
            ],
        ];

        $now        = now();
        $categories = DB::table('service_categories')->pluck('id', 'name');
        $rows       = [];
        $order      = 1;

        foreach ($data as $categoryName => $types) {
            $categoryId = $categories[$categoryName] ?? null;
            if (! $categoryId) continue;

            $order = 1;
            foreach ($types as $typeName) {
                $rows[] = [
                    'service_category_id' => $categoryId,
                    'name'                => $typeName,
                    'is_active'           => true,
                    'display_order'       => $order++,
                    'created_at'          => $now,
                    'updated_at'          => $now,
                ];
            }
        }

        DB::table('service_types')->insert($rows);
    }
}
