class ApiConstants {
  ApiConstants._();
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String preRegister      = '/pre-register';
  static const String verify           = '/verify';
  static const String completeRegister = '/complete-register';
  static const String resend           = '/resend';
  static const String login            = '/login';
  static const String logout           = '/logout';
  static const String forgotPassword   = '/forgot-password';
  static const String resetPassword    = '/reset-password';
  static const String me               = '/me';

  // ── Public ────────────────────────────────────────────────────────────────
  static const String publicCategories = '/public/categories';
  static const String publicArtisans   = '/public/artisans';
  // /public/artisans/{id}

  // ── Categories & service types ────────────────────────────────────────────
  static const String categories       = '/categories';
  // /categories/{id}/service-types

  // ── Client: service requests ──────────────────────────────────────────────
  static const String clientRequests   = '/client/service-requests';
  // /client/service-requests/{id}
  // /client/service-requests/{id}/cancel
  // /client/service-requests/{id}/offers/{offerId}/accept
  // /client/service-requests/{id}/offers/{offerId}/reject

  // ── Conversations ─────────────────────────────────────────────────────────
  static const String conversations    = '/conversations';
  // /conversations/{id}
  // /conversations/{id}/messages
  // /conversations/{id}/read
  // /conversations/{id}/report

  // ── Agenda ────────────────────────────────────────────────────────────────
  static const String agenda           = '/agenda';

  // ── Artisan: requests & offers ────────────────────────────────────────────
  static const String artisanRequests  = '/artisan/service-requests';
  // /artisan/service-requests/{id}/offer  (POST to submit)
  static const String artisanOffers    = '/artisan/offers';
  static const String artisanStats     = '/artisan/stats';
  static const String artisanProfile   = '/artisan/profile';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications    = '/notifications';
}
