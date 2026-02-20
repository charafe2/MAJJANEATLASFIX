# AtlasFixMajjane — API Documentation

> **For contributors:** This document covers everything you need to understand the backend, navigate the codebase, and start contributing.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Getting Started (Local Setup)](#3-getting-started-local-setup)
4. [Project Structure](#4-project-structure)
5. [Authentication](#5-authentication)
6. [API Reference](#6-api-reference)
   - [Public Routes](#public-routes-no-auth)
   - [Auth Routes](#auth-routes)
   - [Client Routes](#client-routes)
   - [Artisan Routes](#artisan-routes)
   - [Messaging Routes](#messaging-routes)
   - [Agenda Routes](#agenda-routes)
   - [Payment Stats](#payment-stats)
7. [Database Schema](#7-database-schema)
8. [Models & Relationships](#8-models--relationships)
9. [Business Logic](#9-business-logic)
10. [Services & Utilities](#10-services--utilities)
11. [Key Conventions](#11-key-conventions)
12. [Known TODOs / Dev Notes](#12-known-todos--dev-notes)

---

## 1. Project Overview

**AtlasFixMajjane** is a service marketplace API that connects **clients** (people who need work done) with **artisans** (service professionals).

Core platform flows:
- Clients post service requests (plumbing, electrical, etc.)
- Artisans browse and submit price offers
- Client accepts an offer → job begins
- Messaging, scheduling (agenda), and payment tracking are built in

There are two distinct user roles:
- **Client** — creates requests, reviews offers, manages jobs
- **Artisan** — browses requests, submits offers, manages their agenda and subscriptions

---

## 2. Tech Stack

| Layer | Technology |
|---|---|
| Framework | Laravel 12.0 |
| PHP | 8.2+ |
| Auth | Laravel Sanctum (token-based) |
| OAuth | Laravel Socialite (Google, Facebook) |
| SMS | Infobip API |
| Database |POSTGRES|
| File Storage | Local (`storage/app/public/`) |
| Cache / Queue | Database driver (dev) |

---

## 3. Getting Started (Local Setup)

### Prerequisites
- PHP 8.2+
- Composer
- Postgres 

### Steps

```bash
# 1. Clone the repo and enter the API folder
cd AtlasF_api

# 2. Install PHP dependencies
composer install

# 3. Copy environment config
cp .env.example .env

# 4. Generate app key
php artisan key:generate

# 5. Run migrations (creates the SQLite database automatically)
php artisan migrate

# 6. Link public storage (for serving uploaded images)
php artisan storage:link

# 7. Start the dev server
php artisan serve
```

The API will be available at `http://127.0.0.1:8000/api/`.

### Environment Variables to configure

| Variable | Description |
|---|---|
| `DB_CONNECTION` | `postgres` |
| `MAIL_*` | SMTP config for email OTP/reset |
| `INFOBIP_API_KEY` | SMS provider key |
| `INFOBIP_BASE_URL` | Infobip base URL |
| `INFOBIP_SENDER` | SMS sender name |
| `GOOGLE_CLIENT_ID` | Google OAuth client ID |
| `GOOGLE_CLIENT_SECRET` | Google OAuth secret |
| `APP_URL` | Base URL (used for storage links) |

---

## 4. Project Structure

```
AtlasF_api/
├── app/
│   ├── Http/
│   │   └── Controllers/
│   │       ├── Auth/
│   │       │   └── AuthController.php       # All registration/login/OTP flows
│   │       ├── Client/
│   │       │   └── ServiceRequestController.php  # Client-side request ops
│   │       ├── Artisan/
│   │       │   └── ServiceRequestController.php  # Artisan-side offer/browse ops
│   │       ├── Messaging/
│   │       │   ├── ConversationController.php
│   │       │   └── MessageController.php
│   │       ├── AgendaController.php          # Appointments calendar
│   │       ├── ArtisanBrowseController.php   # Public artisan directory
│   │       └── PaymentStatsController.php    # Revenue/payment history
│   ├── Models/                               # 33 Eloquent models
│   ├── Services/
│   │   └── SmsService.php                   # Infobip SMS wrapper
│   ├── Mail/
│   │   └── VerificationCodeMail.php         # OTP email template
│   └── Providers/
│       └── AppServiceProvider.php
│
├── database/
│   ├── migrations/                           # 37 migration files
│   ├── factories/
│   └── seeders/
│
├── routes/
│   └── api.php                              # ALL API routes defined here
│
├── config/
│   ├── sanctum.php                          # Token auth config
│   ├── services.php                         # External service keys
│   └── ...
│
└── storage/
    └── app/public/
        └── service-requests/photos/         # Uploaded request photos
```

---

## 5. Authentication

The API uses **Laravel Sanctum** (token-based). After login, include the token in every request:

```
Authorization: Bearer {your_token}
```

### User Roles
Users have an `account_type` field: either `'client'` or `'artisan'`. Most protected endpoints check this and load the appropriate profile.

### Registration Flows

There are two flows depending on the client (mobile app vs web):

#### Flow A — Mobile / OTP Flow
```
POST /api/pre-register   → Creates account stub, sends 4-digit OTP via email/SMS
POST /api/verify         → Verifies OTP, activates account
POST /api/complete-register → Sets password + profile data
```

#### Flow B — Web / Direct Flow
```
POST /api/register  → Creates account + profile in one step
                      Clients are immediately ready.
                      Artisans must then call POST /api/complete-plan to pick a subscription tier.
```

#### Google OAuth
```
POST /api/google/complete  → Receives Google token, creates or retrieves user
```

### Password Reset
```
POST /api/forgot-password   → Sends 4-digit code via email or SMS
POST /api/reset-password    → Validates code and sets new password
```

### Code caching
OTP and reset codes are cached for **10 minutes**. Resend has a **1-minute cooldown**.

### Account Status
Login is blocked if the user:
- Has `is_active = false`
- Has `is_banned = true`
- Has an active suspension (`suspended_until` in the future)

---

## 6. API Reference

### Base URL
```
http://127.0.0.1:8000/api
```

All request bodies should use `Content-Type: application/json` unless uploading files (use `multipart/form-data`).

---

### Public Routes (No Auth)

#### `GET /public/categories`
Lists all active service categories.

**Response:**
```json
[
  { "id": 1, "name": "Plomberie", "icon": "🔧", "is_active": true, "display_order": 1 }
]
```

---

#### `GET /public/artisans`
Paginated list of available artisans. Used for the public artisan directory.

**Query params:**
| Param | Type | Description |
|---|---|---|
| `category_id` | integer | Filter by service category |
| `search` | string | Search by name, city, or bio |
| `per_page` | integer | Results per page (default: 9) |

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "user": { "full_name": "..." },
      "business_name": "...",
      "city": "...",
      "rating_average": 4.7,
      "total_reviews": 42,
      "is_verified": true,
      "primary_category": { "name": "Plomberie" }
    }
  ],
  "current_page": 1,
  "last_page": 5
}
```

---

#### `POST /pre-register`
Step 1 of the mobile OTP flow.

**Body:**
```json
{
  "full_name": "Ahmed Benali",
  "email": "ahmed@example.com",
  "phone": "+212600000000",
  "account_type": "client",
  "verification_method": "email"
}
```

---

#### `POST /verify`
Validates the OTP code sent after pre-register or forgot-password.

**Body:**
```json
{
  "email": "ahmed@example.com",
  "code": "1234"
}
```

---

#### `POST /complete-register`
Completes the mobile flow after OTP verification.

**Body:**
```json
{
  "email": "ahmed@example.com",
  "password": "secret123",
  "password_confirmation": "secret123",
  "city": "Casablanca",
  "account_type": "client"
}
```

---

#### `POST /register`
Direct web registration (creates user + profile in one step).

**Body:**
```json
{
  "full_name": "Fatima Zahra",
  "email": "fatima@example.com",
  "phone": "+212611111111",
  "password": "secret123",
  "password_confirmation": "secret123",
  "account_type": "artisan",
  "city": "Rabat",
  "birth_date": "1990-05-15"
}
```

---

#### `POST /login`
**Body:**
```json
{
  "email": "ahmed@example.com",
  "password": "secret123"
}
```

**Response:**
```json
{
  "token": "1|abc...",
  "user": { "id": 1, "full_name": "Ahmed Benali", "account_type": "client" }
}
```

---

#### `POST /forgot-password`
**Body:**
```json
{ "email": "ahmed@example.com" }
```

---

#### `POST /reset-password`
**Body:**
```json
{
  "email": "ahmed@example.com",
  "code": "5678",
  "password": "newpassword",
  "password_confirmation": "newpassword"
}
```

---

#### `POST /complete-plan`
Artisan selects a subscription tier after web registration.

**Body:**
```json
{
  "user_id": 5,
  "tier_id": 2
}
```

---

### Auth Routes

> All routes below require `Authorization: Bearer {token}`

#### `POST /logout`
Revokes the current token. No body needed.

---

#### `GET /me`
Returns the authenticated user's profile.

**Response includes:**
- User fields (name, email, phone, avatar_url, etc.)
- Nested `client` or `artisan` profile based on `account_type`
- Artisan includes: subscription tier, active subscription, primary category

---

#### `GET /categories`
Returns all active service categories (authenticated version).

#### `GET /categories/{category}/service-types`
Returns all active service types belonging to a category.

---

### Client Routes

> Requires authenticated `client` user.

#### `GET /client/service-requests`
Lists all of the authenticated client's service requests, with their offers.

**Response:**
```json
[
  {
    "id": 10,
    "title": null,
    "description": "Fuite sous l'évier",
    "city": "Casablanca",
    "budget_min": "200.00",
    "budget_max": "500.00",
    "status": "open",
    "category": { "name": "Plomberie", "icon": "🔧" },
    "service_type": { "name": "Réparation de fuite" },
    "offers": [ ... ],
    "photos": [ ... ]
  }
]
```

---

#### `POST /client/service-requests`
Creates a new service request. Use `multipart/form-data` for file uploads.

**Body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `service_category_id` | integer | Yes | |
| `service_type_id` | integer | Yes | |
| `description` | string | Yes | |
| `city` | string | Yes | |
| `budget_min` | numeric | Yes | |
| `budget_max` | numeric | Yes | |
| `request_type` | string | Yes | `public` or `direct` |
| `service_mode` | string | Yes | `sur_place` or `a_distance` |
| `notes` | string | No | |
| `photos[]` | file | No | Max 5 images, 5MB each |

---

#### `GET /client/service-requests/{id}`
Returns full detail of a single service request including all offers.

---

#### `PATCH /client/service-requests/{id}/cancel`
Cancels a request. Only works when status is `open` or `in_progress`.

---

#### `POST /client/service-requests/{id}/offers/{offer}/accept`
Accepts a specific artisan offer.
- All other `pending` offers on that request are automatically `rejected`
- Request status moves to `in_progress`

---

#### `POST /client/service-requests/{id}/offers/{offer}/reject`
Rejects a specific pending offer.

---

### Artisan Routes

> Requires authenticated `artisan` user.

#### `GET /artisan/service-requests`
Lists all **open** public service requests, excluding any the artisan already submitted an offer on.

**Response:** Array of service requests with category, type, client info, and photo count.

---

#### `POST /artisan/service-requests/{id}/offers`
Submit a price offer on an open request.

**Body:**
```json
{
  "proposed_price": 350.00,
  "estimated_duration": 120,
  "description": "Je peux intervenir demain matin."
}
```
- `estimated_duration` is in **minutes**
- Cannot submit more than one offer per request

---

#### `GET /artisan/offers`
Lists all the artisan's own offers with their current status.

**Response includes:** offer status, linked service request, and whether a boost is active.

---

#### `GET /artisan/service-requests/{id}`
Shows full detail of a service request. Only accessible if the artisan has an accepted offer on it.

---

#### `GET /artisan/clients/{client}`
Shows a client's public profile and their recent service requests.

---

### Messaging Routes

> Requires authenticated user (client or artisan).

#### `GET /conversations`
Lists all conversations for the current user, sorted by most recent message.

**Response:**
```json
[
  {
    "id": 3,
    "other_user": { "full_name": "...", "avatar_url": "..." },
    "last_message_at": "2026-02-19T14:30:00Z",
    "unread_count": 2,
    "status": "active"
  }
]
```

---

#### `POST /conversations`
Creates a new conversation between the current user and another user. If a conversation already exists, returns the existing one.

**Body:**
```json
{
  "other_user_id": 7,
  "service_request_id": 12
}
```
- `service_request_id` is optional (links the chat to a specific job)

---

#### `GET /conversations/{id}`
Returns conversation header info (participants, status, linked service request).

---

#### `GET /conversations/{id}/messages`
Returns paginated messages (50 per page, newest last). Automatically marks received messages as read.

---

#### `POST /conversations/{id}/messages`
Sends a new message.

**Body:**
```json
{
  "content": "Bonjour, je suis disponible demain.",
  "message_type": "text"
}
```
- `message_type`: `text`, `image`, `file`, or `system`

---

#### `POST /conversations/{id}/read`
Marks all received messages in the conversation as read.

---

### Agenda Routes

> Requires authenticated user.

#### `GET /agenda`
Returns a combined agenda: **manual appointments** + **service-request-derived appointments** (from accepted offers).

**Response:**
```json
[
  {
    "id": "manual_5",
    "type": "manual",
    "title": "Visite client",
    "client_name": "M. Alami",
    "scheduled_at": "2026-02-22T10:00:00Z",
    "duration_minutes": 60,
    "status": "scheduled",
    "rdv_type": "sur_place",
    "city": "Fès"
  },
  {
    "id": "request_12",
    "type": "from_request",
    "title": "Réparation fuite - Plomberie",
    "client_name": "Fatima Zahra",
    "status": "in_progress"
  }
]
```

---

#### `POST /agenda`
Creates a manual appointment.

**Body:**
```json
{
  "title": "Visite estimation",
  "client_name": "M. Tazi",
  "client_phone": "+212622222222",
  "scheduled_at": "2026-02-25T09:00:00",
  "duration_minutes": 60,
  "rdv_type": "sur_place",
  "city": "Marrakech",
  "notes": "Apporter le devis"
}
```
- `duration_minutes`: one of `30`, `60`, `120`, `180`
- `rdv_type`: `sur_place` or `visioconference`

---

### Payment Stats

> Requires authenticated user.

#### `GET /payment-stats`
Returns payment history and revenue summary.

**Artisan response:**
```json
{
  "stats": {
    "total_revenue": "2350.00",
    "completed_total": "1900.00",
    "pending_total": "450.00",
    "total_jobs": 14,
    "completed_jobs": 11,
    "pending_jobs": 3
  },
  "payments": [
    {
      "id": 8,
      "service_request_title": "Fuite cuisine",
      "client_name": "...",
      "amount": "350.00",
      "status": "accepted",
      "created_at": "..."
    }
  ]
}
```

**Client response:** same structure but shows service requests with accepted offer prices.

---

## 7. Database Schema

Below is the schema grouped by domain. All tables have `id` (primary, auto-increment) unless noted.

### Users & Profiles

**`users`**
| Column | Type | Notes |
|---|---|---|
| `account_type` | enum | `client`, `artisan` |
| `auth_provider` | enum | `email`, `google`, `facebook` |
| `full_name` | string | |
| `email` | string unique | nullable |
| `phone` | string unique | nullable |
| `password` | string | nullable (OAuth users) |
| `avatar_url` | string | nullable |
| `is_active` | boolean | default true |
| `is_banned` | boolean | default false |
| `suspended_until` | timestamp | nullable |
| `cin_number` | string | nullable |
| `cin_verified` | boolean | default false |
| `verification_method` | enum | `email`, `phone` |

**`clients`**
| Column | Type | Notes |
|---|---|---|
| `user_id` | FK → users | cascade delete |
| `city` | string | nullable |
| `total_requests` | integer | counter |
| `total_spent` | decimal(10,2) | |
| `reliability_score` | decimal(3,2) | |

**`artisans`**
| Column | Type | Notes |
|---|---|---|
| `user_id` | FK → users | cascade delete, unique |
| `service_category_id` | FK → service_categories | |
| `business_name` | string | nullable |
| `bio` | text | nullable |
| `experience_years` | integer | nullable |
| `city` | string | nullable |
| `rating_average` | decimal(3,2) | default 0 |
| `total_reviews` | integer | default 0 |
| `total_jobs_completed` | integer | default 0 |
| `is_available` | boolean | default true |
| `is_verified` | boolean | default false |
| `referral_code` | string unique | |
| `referred_by_id` | FK → artisans | nullable, self-ref |
| `current_subscription_tier_id` | FK → subscription_tiers | |

---

### Services

**`service_categories`** — `name`, `icon` (emoji), `is_active`, `display_order`

**`service_types`** — `service_category_id`, `name`, `is_active`, `display_order`

**`service_requests`**
| Column | Type | Notes |
|---|---|---|
| `client_id` | FK → clients | cascade delete |
| `service_category_id` | FK | |
| `service_type_id` | FK | |
| `title` | string | nullable |
| `description` | text | |
| `city` | string | |
| `budget_min` | decimal(10,2) | |
| `budget_max` | decimal(10,2) | |
| `status` | enum | `open`, `in_progress`, `completed`, `cancelled` |
| `request_type` | enum | `public`, `direct` |
| `service_mode` | enum | `sur_place`, `a_distance` |
| `accepted_offer_id` | unsignedBigInteger | nullable |
| `target_artisan_id` | FK → artisans | nullable (for direct requests) |

**`artisan_offers`**
| Column | Type | Notes |
|---|---|---|
| `service_request_id` | FK | cascade delete |
| `artisan_id` | FK | cascade delete |
| `proposed_price` | decimal(10,2) | |
| `estimated_duration` | integer | minutes |
| `description` | text | nullable |
| `status` | enum | `pending`, `accepted`, `rejected`, `withdrawn` |
| `has_active_boost` | boolean | default false |

**`service_request_photos`** — `service_request_id`, `photo_url`, `display_order`

**`service_timeline`** — `service_request_id`, `event_type`, `triggered_by_user_id`, `created_at` (no `updated_at`)

---

### Messaging

**`conversations`**
| Column | Type | Notes |
|---|---|---|
| `client_id` | FK → clients | cascade delete |
| `artisan_id` | FK → artisans | cascade delete |
| `service_request_id` | FK | nullable |
| `status` | enum | `active`, `archived`, `blocked` |
| `last_message_at` | timestamp | nullable |
| Unique | (client_id, artisan_id, service_request_id) | |

**`messages`**
| Column | Type | Notes |
|---|---|---|
| `conversation_id` | FK | cascade delete |
| `sender_id` | FK → users | cascade delete |
| `content` | text | |
| `message_type` | enum | `text`, `image`, `file`, `system` |
| `is_read` | boolean | default false |

---

### Appointments

**`appointments`**
| Column | Type | Notes |
|---|---|---|
| `artisan_id` | FK → artisans | nullable |
| `client_id` | FK → clients | nullable |
| `service_request_id` | FK | nullable |
| `title` | string | |
| `client_name` | string | free text (off-platform clients) |
| `client_phone` | string | |
| `scheduled_at` | dateTime | |
| `duration_minutes` | integer | |
| `status` | enum | `scheduled`, `completed`, `cancelled` |
| `rdv_type` | enum | `sur_place`, `visioconference` |
| `city` | string | nullable |
| `notes` | text | nullable |

---

### Subscriptions & Payments

**`subscription_tiers`** — Seeded with 4 tiers:
| name | price | max_offers/month | max_team |
|---|---|---|---|
| basic | 0 | 5 | 1 |
| pro | 30 | 20 | 1 |
| premium | 75 | -1 (unlimited) | 1 |
| business | 250 | -1 (unlimited) | 10 |

**`artisan_subscriptions`** — `artisan_id`, `subscription_tier_id`, `start_date`, `end_date`, `status` (active/pending), `payment_id`

**`payments`** — `payer_id`, `payee_id`, `payment_type` (subscription/job), `service_amount`, `commission_amount`, `transaction_fee_amount`, `total_amount`, `status` (pending/completed/failed), `transaction_id`

---

## 8. Models & Relationships

### User
```php
// Key relations
$user->client           // HasOne Client
$user->artisan          // HasOne Artisan
$user->notifications    // HasMany Notification
$user->messages         // HasMany Message (sent)
$user->payments         // HasMany Payment (as payer)
```

### Client
```php
$client->user               // BelongsTo User
$client->serviceRequests    // HasMany ServiceRequest
$client->reviews            // HasMany Review (given)
$client->conversations      // HasMany Conversation
```

### Artisan
```php
$artisan->user                  // BelongsTo User
$artisan->primaryCategory       // BelongsTo ServiceCategory
$artisan->currentTier           // BelongsTo SubscriptionTier
$artisan->activeSubscription    // HasOne ArtisanSubscription (active only)
$artisan->offers                // HasMany ArtisanOffer
$artisan->reviews               // HasMany Review (received)
$artisan->conversations         // HasMany Conversation
$artisan->portfolio             // HasMany ArtisanPortfolio
$artisan->badges                // HasMany ArtisanBadge
$artisan->boosts                // HasMany ArtisanBoost
$artisan->activeBoost           // HasOne ArtisanBoost (active only)
```

### ServiceRequest
```php
$serviceRequest->client         // BelongsTo Client
$serviceRequest->category       // BelongsTo ServiceCategory
$serviceRequest->serviceType    // BelongsTo ServiceType
$serviceRequest->offers         // HasMany ArtisanOffer
$serviceRequest->acceptedOffer  // BelongsTo ArtisanOffer (via accepted_offer_id)
$serviceRequest->photos         // HasMany ServiceRequestPhoto
$serviceRequest->timeline       // HasMany ServiceTimeline
$serviceRequest->conversation   // HasOne Conversation
```

### Conversation
```php
$conversation->client       // BelongsTo Client
$conversation->artisan      // BelongsTo Artisan
$conversation->messages     // HasMany Message
$conversation->unreadCount($userId)  // Helper method
```

---

## 9. Business Logic

### Service Request Lifecycle

```
[Client creates request] → status: open
        ↓
[Artisans submit offers] (one per artisan per request)
        ↓
[Client accepts one offer]
  → accepted offer status: accepted
  → all other pending offers: rejected
  → request status: in_progress
        ↓
[Job completed / cancelled]
  → status: completed or cancelled
```

Every status transition is logged in `service_timeline`.

### Offer Boost
Artisans can boost their offers (`has_active_boost = true`) to appear higher to clients. The boost system is managed via `ArtisanBoost`, `ArtisanBoostCredit`, and `BoostPackage` models (not yet exposed via API endpoints).

### Subscription Limits
- Artisans are capped on offers per month based on their tier (`max_offers_per_month`)
- `-1` means unlimited (premium/business tiers)
- The `isFree()` and `isUnlimited()` helpers on `SubscriptionTier` simplify checks

### Referral System
- Each artisan gets a unique `referral_code` on registration
- Artisans signing up with a code are linked via `referred_by_id`
- Tracked via the `Referral` model for potential incentives

### Agenda (Appointments)
The `GET /agenda` endpoint merges two sources:
1. **Manual appointments** — created directly via `POST /agenda`
2. **Service-request appointments** — derived from service requests with `in_progress` status and an accepted offer

Both are formatted into a unified response shape with a `type` field (`manual` or `from_request`) and prefixed `id` (`manual_5`, `request_12`) to avoid collisions.

---

## 10. Services & Utilities

### SmsService (`app/Services/SmsService.php`)
Wrapper around the Infobip REST API.

```php
$smsService->send($to, $message);
$smsService->sendVerificationCode($to, $code);
$smsService->sendResetCode($to, $code);
```

Config keys used:
- `services.infobip.api_key`
- `services.infobip.base_url`
- `services.infobip.sender`

Errors are logged but not thrown (silent failure on SMS send).

### VerificationCodeMail (`app/Mail/VerificationCodeMail.php`)
Sends OTP codes via email. Used when `verification_method = 'email'`.

### OTP / Code Caching
- Codes are stored in Laravel cache with a 10-minute TTL
- Cache key format: `verify_{email}` / `reset_{email}`
- Resend cooldown key: `resend_cooldown_{email}` (1-minute TTL)

---

## 11. Key Conventions

- **Sanctum tokens** are returned as `{ token: "...", user: {...} }` on login
- **File uploads** use `multipart/form-data` and are stored under `storage/app/public/`
- **Public file URLs** use `Storage::url()` — requires `php artisan storage:link`
- **Pagination** uses Laravel's default `paginate()` with `data`, `current_page`, `last_page`, etc.
- **Soft deletes** are not used — `forceDelete()` removes records completely
- **Timestamps** — all models use `created_at`/`updated_at` except `ServiceTimeline` which has no `updated_at`
- **Service timeline** is append-only — never update, only insert
- **`account_type`** is checked in every protected controller to guard role-specific routes
- **Validation** — all controllers use `$request->validate()` inline (no separate Form Requests yet)
- **Direct requests** — `request_type = direct` with a `target_artisan_id` allows clients to send requests to a specific artisan

---

## 12. Known TODOs / Dev Notes

| Area | Note |
|---|---|
| Google OAuth | Client credentials are currently hardcoded in `AuthController` for debugging. Move to `.env` before deploying. |
| Boost API | Artisan boost endpoints don't exist yet — the model and DB are ready. |
| Reviews API | Review/rating endpoints are not yet implemented. |
| Payment Integration | Payments table and model exist but no real payment gateway is integrated. |
| CIN Verification | CIN fields are in the DB but verification flow is not implemented. |
| Team Members | `ArtisanTeamMember` model and table exist but no management endpoints. |
| Certifications | `ArtisanCertification` and `ProfessionalLicense` models exist, no endpoints. |
| Push Notifications | `Notification` model exists, no push integration yet. |
| Database (prod) | Switch `DB_CONNECTION` from `sqlite` to `mysql` and update `DB_*` vars. |
| Queue (prod) | Switch from `database` to `redis` queue driver for production workloads. |
| Sanctum stateful | Stateful domains in `config/sanctum.php` include `localhost:5173` (Vue dev). Update for prod. |
