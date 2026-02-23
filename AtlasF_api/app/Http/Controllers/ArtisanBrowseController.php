<?php

namespace App\Http\Controllers;

use App\Models\Artisan;
use App\Models\ServiceCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ArtisanBrowseController extends Controller
{
    /**
     * Public list of active service categories.
     */
    public function categories(): JsonResponse
    {
        $categories = ServiceCategory::where('is_active', true)
            ->orderBy('display_order')
            ->get(['id', 'name', 'icon']);

        return response()->json(['data' => $categories]);
    }

    /**
     * Public list of artisans, optionally filtered by category.
     *
     * Query params:
     *   category_id  (int)    – filter by service_category_id
     *   search       (string) – filter by name, city, or bio
     *   per_page     (int)    – default 9
     *   page         (int)    – default 1
     */
    public function artisans(Request $request): JsonResponse
    {
        $query = Artisan::with('user')
            ->where('is_available', true);

        if ($request->filled('category_id')) {
            $query->where('service_category_id', $request->integer('category_id'));
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('bio',  'like', "%{$search}%")
                  ->orWhere('city', 'like', "%{$search}%")
                  ->orWhereHas('user', function ($uq) use ($search) {
                      $uq->where('full_name', 'like', "%{$search}%");
                  });
            });
        }

        $perPage  = min($request->integer('per_page', 9), 50);
        $artisans = $query->orderByDesc('rating_average')->paginate($perPage);

        $data = $artisans->map(function (Artisan $artisan) {
            $user = $artisan->user;
            return [
                'id'               => $artisan->id,
                'name'             => $user?->full_name ?? 'Artisan',
                'avatar'           => $user?->avatar_url && !str_starts_with($user->avatar_url, 'http')
                    ? Storage::url($user->avatar_url)
                    : $user?->avatar_url,
                'city'             => $artisan->city ?? 'Maroc',
                'bio'              => $artisan->bio ?? 'Artisan professionnel à votre service.',
                'rating'           => number_format((float) ($artisan->rating_average ?? 0), 1) . '/5',
                'reviews'          => (int) ($artisan->total_reviews ?? 0),
                'verified'         => (bool) $artisan->is_verified,
                'experience_years' => $artisan->experience_years,
            ];
        });

        return response()->json([
            'data' => $data,
            'meta' => [
                'total'        => $artisans->total(),
                'current_page' => $artisans->currentPage(),
                'last_page'    => $artisans->lastPage(),
            ],
        ]);
    }
}
