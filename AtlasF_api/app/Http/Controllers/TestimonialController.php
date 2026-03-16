<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class TestimonialController extends Controller
{
    public function index(): JsonResponse
    {
        $testimonials = DB::table('testimonials')
            ->where('is_visible', true)
            ->orderBy('display_order')
            ->get(['name', 'role', 'text']);

        return response()->json(['data' => $testimonials]);
    }
}
