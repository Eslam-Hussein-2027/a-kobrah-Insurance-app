# Car Insurance API (Laravel)

REST API for the car insurance platform: customers register vehicles, get quotes, buy policies,
download a printable Arabic PDF, and (later phases) renew and file claims.

**Status: Phase 1 complete** — auth (phone + OTP), roles, vehicles, quote engine, policy issuance,
office-payment confirmation, PDF download, public policy verification.

## Stack

| Concern | Choice |
|---|---|
| Framework | Laravel 12 (same structure as Laravel 11 — see note below) |
| Auth | Laravel Sanctum personal access tokens, phone + OTP |
| Roles | spatie/laravel-permission (`customer`, `surveyor`, `admin`, `workshop`) |
| PDF | mPDF via `carlos-meneses/laravel-mpdf`, Amiri font (OFL), RTL |
| DB | MySQL in production, SQLite in-memory for tests |
| Queue | `database` driver (PDF generation) |

> **Why Laravel 12 and not 11?** Every Laravel 11.x release is affected by CVE-2026-114509 (critical)
> and is out of security support, so no patched 11.x exists. Laravel 12 keeps the exact
> Laravel 11 application structure (`bootstrap/app.php`, no Kernel classes), so nothing in this
> codebase is version-specific.

## Setup

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
```

Create the MySQL database, then set `DB_*` in `.env`:

```sql
CREATE DATABASE akobrah_insurance CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

```bash
php artisan migrate --seed
php artisan serve
```

```bash
php artisan queue:work   # generates policy PDFs after activation
```

### Demo accounts (seeded outside production)

All accounts log in with OTP. With `OTP_FIXED_CODE=123456` in a **local** `.env`, the code is always `123456`;
otherwise the code is written to `storage/logs/laravel.log` (the `log` SMS driver).

| Role | Phone |
|---|---|
| admin | 0910000001 |
| surveyor | 0910000002 |
| customer (has a demo vehicle) | 0910000003 |
| workshop | 0910000004 |

## Tests

```bash
php artisan test
```

72 tests: OTP auth, vehicles, **quote calculation**, policy issuance, **policy PDF access control**,
public verification, claim status transitions (enum rules), plate/digit normalization.

## API

Base URL: `/api/v1`. Send `Authorization: Bearer <token>` for protected routes and
`Accept-Language: ar|en` (Arabic is the default).

### Response envelope

```json
{ "success": true,  "message": "تمت إضافة المركبة بنجاح.", "data": { }, "meta": { "pagination": { } } }
{ "success": false, "message": "البيانات المدخلة غير صحيحة.", "errors": { "vin": ["رقم الشاسيه مسجل لمركبة أخرى."] } }
```

| Status | Meaning |
|---|---|
| 401 | missing/invalid token |
| 403 | not your resource / wrong role / policy not active / invalid signed URL |
| 404 | not found |
| 422 | validation error (`errors`) or business rule (e.g. overlapping policy) |
| 429 | rate limited |

### Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/auth/otp/send` | public, 1/min/phone | Send OTP SMS |
| POST | `/auth/otp/verify` | public | Existing user → `token`; new phone → `registration_token` |
| POST | `/auth/register` | public | `registration_token`, `name`, `national_id`, `device_name`, optional `id_image`, `license_image` |
| GET | `/auth/me` | any role | Current user (document URLs are temporary signed links) |
| POST | `/auth/logout` | any role | Revoke current token |
| GET | `/coverage-types` | public | Active coverage types |
| GET | `/policies/verify?policy_no=&plate_no=` | public, 10/min/IP | `VALID` / `EXPIRED` / `NOT_FOUND`, no personal data |
| POST | `/me/documents` | customer | Upload `id_image` and/or `license_image` (multipart) |
| GET/POST | `/vehicles` | customer | List (paginated) / create |
| GET/PATCH/DELETE | `/vehicles/{id}` | owner | Show / update / delete |
| POST | `/quotes` | owner | `vehicle_id`, `coverage_type_id` → premium + factor breakdown (not saved) |
| GET | `/policies` | customer | Own policies (`?status=ACTIVE&vehicle_id=`) |
| POST | `/policies` | owner | Create `PENDING_PAYMENT` policy (`start_date` optional, ≤ 60 days ahead) |
| GET | `/policies/{id}` | owner/admin | Show |
| POST | `/policies/{id}/cancel` | owner | Cancel while `PENDING_PAYMENT` |
| GET | `/policies/{id}/pdf` | owner, `ACTIVE` only | A4 printable PDF |
| POST | `/policies/{id}/pay-online` | owner | Start online payment → `checkout_url` |
| GET | `/payments/{id}` | owner/admin | Payment status (re-checked with the provider while pending) |
| POST | `/payments/webhook/{gateway}` | provider | Server-to-server notification (status is always re-fetched) |
| POST | `/auth/staff/login` | public | Dashboard login (phone + password, staff roles only) |
| GET | `/admin/stats` | admin | Dashboard numbers + 6-month series |
| GET | `/admin/policies` | admin | `?status=&search=` (policy no, plate, name, phone, national number) |
| GET | `/admin/policies/{id}` | admin | Details with customer, payments, pricing snapshot |
| POST | `/admin/policies/{id}/confirm-office-payment` | admin | "Pay at office": records payment, activates policy, queues PDF |
| POST | `/admin/policies/{id}/cancel` | admin | Cancel a pending policy |
| GET | `/admin/policies/{id}/pdf` | admin | Print an active policy at the office |
| GET | `/admin/payments` | admin | `?method=&status=&requires_refund=1` |
| GET/PATCH | `/admin/customers[/{id}]` | admin | Search, details (documents), block/unblock (`is_active`) |
| GET | `/admin/pricing` | admin | Coverage types, factor bands, gap report |
| PATCH | `/admin/coverage-types/{id}` | admin | Base price, active flag, names |
| POST/PUT/DELETE | `/admin/pricing-factors[/{id}]` | admin | Factor bands (overlaps rejected) |

### Login / registration flow

```
POST /auth/otp/send     {phone}
POST /auth/otp/verify   {phone, code, device_name}
   ├─ existing user → { is_new_user: false, token, user }
   └─ new phone     → { is_new_user: true, registration_token (30 min, single use) }
POST /auth/register     {registration_token, name, national_id, device_name, id_image?, license_image?}
   → { token, user }
```

OTP codes are stored as HMAC hashes, expire after 5 minutes, and lock after 5 wrong attempts.
Localized for **Libya** (all values in `config/insurance.php` / `.env`):

| Input | Rule |
|---|---|
| Phone | `09[1-5]XXXXXXX` (10 digits); `+218…`, `00218…`, spaces and dashes are converted to the local format |
| National number | 12 digits, starts with 1 or 2 |
| Plate | free format, e.g. `5-123456`; spaces/dashes ignored when comparing |
| Currency | LYD (دينار ليبي) |

Arabic-Indic digits (`٠١٢٣`) are accepted in phone, national number, OTP, plate and year inputs.

### Coverage types

The company currently sells **compulsory third-party insurance only** (`THIRD_PARTY`).
`COMPREHENSIVE` exists in `coverage_types` but is seeded with `is_active = false`; switching it on needs no code change.
Seeded base prices are placeholders until the official tariff is provided.

### Quote engine

```
premium = base_price × vehicle_age_factor × engine_factor × claims_history_factor
```

- Factors live in `pricing_factors` (`factor_type`, inclusive `min_value`..`max_value`, `NULL` max = open-ended).
- `claims_history` = the owner's non-rejected claims across all their vehicles in the last
  `QUOTE_CLAIMS_HISTORY_YEARS` (default 3).
- A value with no matching band returns 422 instead of silently using 1.0.
- The premium is recalculated on `POST /policies` (client values are ignored), and the full
  breakdown is stored in `policies.pricing_snapshot` for audit.

### Policy lifecycle (phase 1)

```
POST /policies → PENDING_PAYMENT ──(admin confirms office payment)──► ACTIVE ──(PDF queued)
                        └──(customer cancels)──► CANCELLED
```

- Policy numbers: `POL-YYYY-000001`, yearly sequence with a row lock (`document_sequences`).
- One pending/active policy per vehicle per period (overlap check).
- KYC (ID + license images) is required before creating a policy.
- If payment is confirmed after the requested start date, coverage starts on the payment day (full term kept).

## Online payments

![Online payment flow](../docs/online-payment-flow.png)

Hosted-checkout model behind `App\Services\Payments\PaymentGateway`:

```
app  → POST /policies/{id}/pay-online → checkout_url (provider page)
customer pays on the provider page
provider → POST /payments/webhook/{gateway}   (and/or the app polls GET /payments/{id})
server   → fetchStatus() from the provider → PAID → policy ACTIVE → PDF queued
```

- Callback parameters are **never trusted**: the result is always re-fetched from the provider.
- Idempotent: concurrent webhooks and polls are serialized with row locks, so a policy is activated once.
- The amount must match the policy premium, otherwise the payment fails with `amount_mismatch` and is flagged for refund.
- Starting a new attempt closes the previous one (`superseded`). An office payment closes open online attempts (`paid_at_office`).
  If the customer still pays on the provider page, the money is recorded and flagged `requires_refund` instead of being lost.
- **`simulator`** is a built-in fake provider: a signed Arabic page with "دفع ناجح" / "رفض الدفع" buttons, used for development and demos.
  It is disabled when `APP_ENV=production` (`PAYMENT_SIMULATOR_ENABLED`).

**Adding a real Libyan provider** (Sadad, Edfa3ly, Moamalat, or an aggregator):

1. Implement `PaymentGateway` (`createCheckout`, `fetchStatus`, `referenceFromCallback`).
2. Register it in `PaymentGatewayManager::GATEWAYS` and `config/payments.php`.
3. Set `PAYMENT_GATEWAY=<name>` and the merchant credentials in `.env`.
4. Give the provider the webhook URL `https://<api-host>/api/v1/payments/webhook/<name>`.

## Admin dashboard

Staff sign in at `POST /auth/staff/login` with phone + password (the demo admin is `0910000001` / `password`, seeded outside production).
The React dashboard lives in [`../admin`](../admin/README.md).

## Policy PDF

![Policy PDF sample](../docs/policy-pdf-sample.png)

- Template: `resources/views/pdf/policy.blade.php` (single A4 page, black & white, RTL, Amiri).
- Logo: `resources/pdf/logo.png` (colour, by company choice; the rest of the page is black & white).
  The stamp is still a placeholder (`resources/pdf/stamp.svg`); override paths with `COMPANY_LOGO_PATH` / `COMPANY_STAMP_PATH`.
- Stored on the private disk at `storage/app/private/policies/{year}/{policy_no}.pdf`; generated by a
  queued job, or on first download if the worker hasn't run yet.
- mPDF notes: don't use CSS `size:` in `@page` (it breaks pagination). Wrap Latin text or dates that sit
  next to Arabic text in `<bdo dir="ltr">`. Amiri **0.113** is bundled because newer Amiri builds use
  GPOS lookups that mPDF cannot parse.

## Project layout

```
app/
  Enums/                 PolicyStatus, ClaimStatus (with transition rules), UserRole, ...
  Exceptions/            BusinessRuleException, ApiExceptionRenderer (JSON + Arabic messages)
  Http/
    Controllers/Api/V1/  Auth, Vehicle, Quote, Policy, PolicyVerification, Admin/PolicyPayment, File
    Middleware/          ForceJsonResponse, SetLocale
    Requests/            Form requests (digit normalization in ApiRequest)
    Resources/           JSON resources
    Responses/ApiResponse.php
  Jobs/GeneratePolicyPdf.php
  Models/                User, Vehicle, CoverageType, PricingFactor, Policy, Payment, Claim, ClaimMedia,
                         Inspection, ClaimStatusLog, Workshop, NotificationLog, OtpCode
  Policies/              VehiclePolicy, PolicyPolicy (authorization)
  Services/              Auth/OtpService, Auth/AuthService, Pricing/QuoteService,
                         Policy/PolicyService, Policy/PolicyPdfService, Policy/PolicyVerificationService,
                         DocumentNumberGenerator, UserDocumentService, Sms/*
config/insurance.php     All business settings (currency, OTP, regexes, upload limits, company info)
lang/{ar,en}/            messages, enums, validation (ar)
```

## Next phases

- **Phase 2**: ✅ online payments (simulator, real provider pending) and admin dashboard. Still to do: renewal
  (`previous_policy_id`), expiry job, reminders 30/7/1 days before expiry (scheduler + FCM), `notifications_log`.
- **Phase 3**: claims API (media upload with `image_hash`, other-party linking, status workflow and
  `claim_status_logs`), surveyor flow, admin dashboard endpoints and stats.
