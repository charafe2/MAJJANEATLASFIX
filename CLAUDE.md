# AtlasFixMajjane — Claude Notes

## After `migrate:fresh`

Whenever you run `php artisan migrate:fresh`, you **must** re-seed the database in this order:

```bash
cd AtlasF_api
php artisan migrate:fresh
php artisan db:seed --class=SubscriptionTierSeeder
php artisan db:seed --class=ServiceCategorySeeder
php artisan db:seed --class=ServiceTypeSeeder
php artisan db:seed --class=BoostPackageSeeder
php artisan db:seed --class=ArtisanSeeder
php artisan db:seed --class=TestimonialSeeder
```

Or simply run the full seeder (runs all of the above in order):

```bash
php artisan migrate:fresh --seed
```

### What each seeder does

| Seeder | Table | Description |
|---|---|---|
| `SubscriptionTierSeeder` | `subscription_tiers` | Subscription plan tiers |
| `ServiceCategorySeeder` | `service_categories` | 27 service categories (Plomberie, Électricité, etc.) |
| `ServiceTypeSeeder` | `service_types` | Service sub-types per category |
| `BoostPackageSeeder` | `boost_packages` | Artisan boost/promotion packages |
| `ArtisanSeeder` | `users` + `artisans` + `artisan_services` | 8 sample artisans (password: `password123`) |
| `TestimonialSeeder` | `testimonials` | 10 homepage testimonials |

### Seeder order matters

`ArtisanSeeder` depends on `service_categories` being populated first (it looks up category IDs by name). Always seed categories before artisans.
