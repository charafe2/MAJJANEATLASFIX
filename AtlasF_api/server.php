<?php

/**
 * Laravel development server – modified to route /storage/* requests
 * through Laravel (so the CORS-aware route in web.php handles them).
 */

$uri = urldecode(
    parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? ''
);

// Force /storage/ requests through Laravel so CORS headers are added.
if (str_starts_with($uri, '/storage/')) {
    require_once __DIR__.'/public/index.php';
    return;
}

// For all other URIs, serve static files if they exist, else route through Laravel.
if ($uri !== '/' && file_exists(__DIR__.'/public'.$uri)) {
    return false;
}

require_once __DIR__.'/public/index.php';
