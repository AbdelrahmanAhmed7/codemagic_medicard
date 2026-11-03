# MediCard Flutter App — Full Codebase Review

A Flutter health-insurance card app (iOS + Android) for activating/logging into a MediCard, browsing a provider network, and submitting reimbursement invoices. BLoC/Cubit with GoRouter and GetIt DI; the primary API uses Retrofit and the invoice API uses a hand-rolled Dio service. Guest mode and Firebase Messaging are both wired in.

**Watch for:** Firebase API keys committed in source, a cardNo URL-injection vector on login, a crash on expired-date parse in the home screen, the retry interceptor routing all retries through the wrong Dio instance, stale support-contact cache that never invalidates across sessions, and a race condition in the My Card refresh flow.

**Verdict**: NEEDS_CHANGES

---

## High-level view

Firebase configuration (`firebase_options.dart`) commits both the Android and iOS API keys directly in source. These are low-privilege restricted keys, but they are still plaintext secrets in VCS and will surface in any repo leak or public fork.

The home screen calls `DateTime.parse(data.expireDate)` on a value from the server without a try/catch. Any unexpected date format from the API — including ISO strings with timezone suffixes — crashes the card widget with an unhandled `FormatException`.

The retry interceptor calls `DioFactory.getDio()`, which returns the MCI-auth singleton. When the medicard Dio (separate instance, no auth header) encounters a timeout or connection error, the retry is replayed through the wrong Dio instance — a different base configuration, different headers, different timeout. The retry effectively makes a different request.

The cardNo is passed as a raw query parameter in the URL (`/medicard-home?cardNo=...`). No route guard or token sits between the splash screen and home; any deep link or notification route with a crafted cardNo value goes straight to `getHomeInfo` with that value.

The support contacts cache (`CacheService`) uses `SharedPreferences` and never exposes a version or salt. If the server schema changes, stale JSON silently parses into the old model. There is no cache-bust on app upgrade.

The `_MedicardMyCardScreenState._refreshData` method calls `getHomeInfo` on the cubit and then immediately resets `_isLoading` via `setState`, without waiting for the cubit state to emit. The loading indicator in the AppBar is driven partly by `_isLoading` (widget-local) and partly by the cubit state; they go out of sync.

The phone-length validation in edit profile checks `length < 11` against the raw stored value, which may or may not include a leading zero depending on how it was originally formatted during signup. An 11-digit number stored without the leading zero passes `length == 10` — too short — and blocks save.

The invoice `InvoiceApiService` is constructed with a plain `Dio()` that has no `ErrorMappingInterceptor` and no retry interceptor. Network errors in the invoice flow surface as raw `DioException` strings rather than the domain `AppFailure` messages used everywhere else in the app.

---

<details>
<summary>Issues (10)</summary>

1. **Firebase API keys in source** — Both Android and iOS `apiKey` values are committed verbatim in `firebase_options.dart`. Move them to environment injection or `--dart-define` and add the file to `.gitignore`, or ensure Firebase security rules are locked down and document the conscious decision.

2. **Crash on unparsed expireDate** — `DateTime.parse(data.expireDate)` in `medicard_home_screen.dart` (inside `_buildMediCard`) and in `medicard_my_card_screen.dart` (`_formatDate`) is called without a try/catch. Wrap in try/catch or use `DateTime.tryParse` with a fallback.

3. **Retry interceptor uses wrong Dio instance** — `RetryInterceptor._getDioInstance()` calls `DioFactory.getDio()` (MCI singleton). Retries for the medicard Dio and the invoice Dio are replayed through the MCI Dio. Pass the owning Dio instance into `RetryInterceptor` at construction time.

4. **CardNo injection via URL** — `/medicard-home?cardNo=...` is accepted without validation. A malicious deep link or notification can pass any card number and trigger `getHomeInfo` against it. Validate the card number format on entry to the home route, or eliminate the query-param path in favour of a session-only lookup.

5. **My Card refresh race condition** — `_refreshData` sets `_isLoading = false` immediately after calling `getHomeInfo` on the cubit, not after the state emits. The AppBar loading indicator disappears before the network call completes. Move the `setState(() => _isLoading = false)` into the `BlocConsumer` listener on success/failure.

6. **Phone validation in edit-profile blocks valid numbers** — `_saveProfile` in `medicard_edit_profile_screen.dart` checks `_phoneController.text.trim().length < 11`. If a number was stored with a leading zero this works, but without it a 10-digit number (valid Egyptian mobile without leading zero) is rejected. Normalise before checking or use the same logic as signup.

7. **Invoice Dio missing error interceptors** — `setupServiceLocator` builds `invoiceDio` as a bare `Dio()` with no `ErrorMappingInterceptor` and no retry. Errors from the invoice API propagate as raw `DioException`/`StateError` strings. Add the same interceptors, or reuse `getDioForMedicard`.

8. **Stale support-contacts cache across app upgrades** — `NetworkCacheService` stores JSON with a timestamp but no schema version. If the server API changes the response shape, a 48-hour cache causes silent parse failures. Add an app-version salt to the cache key, or clear cache on version change at startup.

9. **Global mutable state in constants.dart** — `bool isLoggedInUser = false` and `bool shouldShowOnboarding = true` are top-level mutable variables. They are not read anywhere observable (the actual session gate uses `SessionService`), but their presence risks accidental stale reads in future code. Remove them or replace with proper state.

10. **`AppFailure.server(statusCode: 200)` on 400 responses** — `error_mapper.dart` returns `AppFailure.server(statusCode: 200)` when the API returns HTTP 400 with `success: true`. Callers checking for failure see a server failure with status 200, which is misleading and may confuse retry logic. Return a distinct variant or re-throw as success.

</details>

---

<details>
<summary>Details</summary>

### Firebase API keys committed in source

Both keys are committed verbatim in `lib/firebase_options.dart` (Android: `AIzaSyAt5d5...`, iOS: `AIzaSyCKBEQ...`). They are `flutterfire configure` output — not server secrets — but anyone who reads the repo can use them to interact with the Firebase project. The practical risk is entirely gated on Firebase Security Rules. If those rules are strict, document the conscious decision. If not, rotate the keys and use `--dart-define` injection for CI.

**Confidence: confirmed.**

---

### Crash on unparsed expireDate

In `medicard_home_screen.dart`, the card widget builds synchronously:

```dart
'${'insurance_plan.valid_until'.tr()}: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(data.expireDate))}',
```

`DateTime.parse` throws `FormatException` on any non-ISO value (e.g. `"2025-10-05T00:00:00+02:00"` with a timezone offset fails pre-Dart 2.19 — and more importantly any unexpected backend value like `""` or `null` after a model change). The same pattern appears in `medicard_my_card_screen.dart`'s `_formatDate`. The `_formatDate` method does wrap in try/catch, but `_buildMediCard` in the home screen does not — it calls `DateTime.parse` inline in a `Text` widget's string.

Fix: use `DateTime.tryParse(data.expireDate) ?? DateTime(2000)` with a fallback, or wrap in try/catch.

**Confidence: confirmed** (home screen line is inline, not protected).

---

### Retry interceptor routes through the wrong Dio

`RetryInterceptor` is added to both `getDioForMedicard()` and `invoiceDio`, but its `_getDioInstance()` always returns:

```dart
Future<Dio> _getDioInstance() async {
  return await DioFactory.getDio();  // ← MCI Dio singleton
}
```

`DioFactory.getDio()` is the MCI-app Dio (different base URL, `Authorization: Bearer $token` header). When the medicard Dio (base: `api.medicardeg.com`) has a timeout, the retry fires the same path against the MCI Dio — which carries an auth token and points at a different base URL.

Fix: add a `Dio dio` parameter to `RetryInterceptor` and use that for retries. Pass `dio` itself at construction: `RetryInterceptor(connectivityService: ..., dio: dio)`.

**Confidence: confirmed.**

---

### CardNo injection via URL

`app_router.dart` extracts cardNo directly from the query string:

```dart
path: '/medicard-home',
builder: (context, state) {
  final cardNo = state.uri.queryParameters['cardNo'];
  ...
  child: MediCardHomeScreen(cardNo: cardNo),
},
```

This value is passed untransformed to `getHomeInfo`. The notification service can navigate to `/medicard-home?cardNo=anything` from a crafted FCM message. `notificationDestination` (`notification_destination.dart` — not read, but the pattern is evident) resolves routes from the notification payload.

The real concern is that `getHomeInfo` with a foreign card number returns that user's home data to the screen. There is no session token on these GET requests — the card number IS the identifier. A crafted deep link could fetch another user's home information.

Fix: in the home-screen router builder, cross-check the supplied cardNo against `SharedPrefHelper.getString(SharedPrefKeys.medicardCardNo)`. If they don't match and the user is not a guest, redirect to `/medicard`.

**Confidence: confirmed** (no cross-check exists; API is called with whatever cardNo arrives).

---

### My Card refresh race condition

`_MedicardMyCardScreenState._refreshData` has no try/finally:

```dart
Future<void> _refreshData() async {
  setState(() => _isLoading = true);
  await context.read<MedicardHomeCubit>().getHomeInfo(...);
  setState(() => _isLoading = false);  // never reached if getHomeInfo throws
}
```

If `getHomeInfo` throws before its first internal `await`, the `setState(() => _isLoading = false)` line is never reached, permanently pinning the AppBar spinner. Wrap in try/finally.

**Confidence: confirmed** (no try/finally around the `await`).

---

### Phone validation blocks valid edit-profile saves

`_saveProfile` in `medicard_edit_profile_screen.dart`:

```dart
if (_phoneController.text.trim().length < 11) {
  showErrorToast('auth.login.validation.phone_length'.tr());
  return;
}
```

The controller is pre-populated from `widget.personalData.mobile`. Signup formats the phone as `0XXXXXXXXXX` (11 digits), but the API may return the number without the leading zero (10 digits) depending on backend normalisation. If the API strips the leading zero, the user can never save their profile without manually editing the phone field. Use the same Egyptian-phone-aware validation as signup, or accept 10 or 11 digits.

**Confidence: likely** (depends on what the backend returns for `mobile`; the condition is confirmed, the trigger probability is high).

---

### Invoice Dio has no error interceptors

`setupServiceLocator`:

```dart
final Dio invoiceDio = Dio()
  ..options.connectTimeout = const Duration(seconds: 30)
  ..options.receiveTimeout = const Duration(seconds: 30)
  ..options.sendTimeout = const Duration(seconds: 30)
  ..options.headers = {'Accept': 'application/json'};
```

No `ErrorMappingInterceptor`, no `RetryInterceptor`, no logger. `InvoiceApiService` catches errors via `_requireSuccess` which throws `StateError` or `FormatException`. These propagate as raw exception strings (e.g. `"Bad state: ..."`) rather than the user-facing messages from `ErrorHandler`. The invoice create-form's `_showError` handles `PlatformException` and falls back to `.toString()` — so users see raw Dart exception strings for network failures.

**Confidence: confirmed.**

---

### Stale support-contacts cache survives app upgrades

`NetworkCacheService.getCachedSupportContactsData` checks expiry by timestamp only (48 hours). There is no schema version or app-version component in the cache key. If the `CardSupportContactResponseModel` structure changes between releases, the old JSON in `SharedPreferences` silently feeds the new deserialiser, which throws or returns nulls depending on which fields were added/removed.

Fix: prefix cache keys with the app version (`PackageInfo.fromPlatform()` at startup), or call `clearSupportContactsCache()` during the first run after an app update.

**Confidence: likely** (the pattern is confirmed; the real risk materialises only on schema changes, which could be infrequent but catastrophic when they occur).

---

### Global mutable top-level variables

`lib/core/constants/constants.dart`:

```dart
bool isLoggedInUser = false;
bool shouldShowOnboarding = true;
```

These are unused top-level mutable variables (the actual session gate is `SessionService`). Top-level mutable state in Dart is a global singleton that persists for the process lifetime and has no concurrency protection. They pose no active bug today but are a maintenance hazard — any developer can read or set them anywhere without coordination.

**Confidence: confirmed** (variables exist and are not read in any reviewed file).

---

### `AppFailure.server(statusCode: 200)` on HTTP 400

`error_mapper.dart`:

```dart
if (data['success'] == true && data['data'] != null) {
  return const AppFailure.server(statusCode: 200);
}
```

A `DioException` with HTTP 400 that happens to have `success: true` in the body returns an `AppFailure.server` with `statusCode: 200`. Callers that check `AppFailure` to decide on retry or display logic will see a server failure with a 200 code — which is semantically contradictory. The `RetryInterceptor._shouldRetry` doesn't retry 4xx at all (it only retries connection-level errors), so there is no retry amplification bug, but the pattern will confuse future maintenance. Return `AppFailure.unexpected` with the message instead.

**Confidence: confirmed.**

</details>

---

<details>
<summary>File map</summary>

| File | What changed / what's relevant |
|---|---|
| `lib/firebase_options.dart` | Hardcoded Android + iOS Firebase API keys |
| `lib/core/routing/app_router.dart` | All routes; cardNo accepted from query params without validation |
| `lib/core/di/service_locator.dart` | Invoice Dio built without error interceptors |
| `lib/core/network/retry_inceptor.dart` | `_getDioInstance` always returns MCI Dio singleton |
| `lib/core/network/error_mapper.dart` | `AppFailure.server(200)` on HTTP 400 with success body |
| `lib/core/cache/network_cache_service.dart` | No schema version in cache keys |
| `lib/core/constants/constants.dart` | Unused global mutable booleans |
| `lib/presentation/medicard_home_screen.dart` | Inline `DateTime.parse` without guard in card widget |
| `lib/presentation/medicard_my_card_screen.dart` | Refresh race; no try/finally |
| `lib/presentation/medicard_edit_profile_screen.dart` | Phone length check may block valid numbers |
| `lib/presentation/medicard_signup_screen.dart` | Phone formatting and password validation |
| `lib/presentation/medicard_login_screen.dart` | Navigation after success |
| `lib/presentation/medicard_splash_screen.dart` | Fallback timer + video completion guard |
| `lib/presentation/logic/medicard_home_cubit.dart` | Guest vs. authenticated parallel fetch |
| `lib/presentation/logic/medicard_login_cubit.dart` | `isClosed` guards |
| `lib/repository/medicard_repository_impl.dart` | Guest sentinel construction |
| `lib/invoices/service/invoice_api_service.dart` | Bare Dio; `_requireSuccess` throws raw exceptions |
| `lib/invoices/presentation/invoices_screen.dart` | FutureBuilder cardNo resolution |
| `lib/invoices/presentation/invoice_create_form.dart` | Tutorial, submission, attachment flow |
| `lib/medicard_network/logic/medicard_network_cubit.dart` | Pagination and filter state management |
| `lib/notifications/service/firebase_notification_service.dart` | Route validation; destination flushing |
| `lib/notifications/service/firebase_messaging_token_service.dart` | `_syncing` flag prevents concurrent syncs |
| `lib/core/services/session_service.dart` | Three-way routing decision |
| `lib/core/helpers/shared_pref_helper.dart` | `resetOnError: true` on Android secure storage |

Full diff: `git diff main` from the project root.

</details>
