# Kavodnik

Kavodnik is an Android rewards app built with Flutter. Users sign in with Google, complete daily activities (check-in, spin wheel, scratch card, captcha), take quizzes, read articles, shop through partner stores, invite friends and redeem the coins they earn.

The backend is **not built yet**. Every feature runs against realistic in-memory mock data sources that sit behind the same interfaces the real API will use. Moving to the real backend is a data-layer change. Screens, widgets, navigation and state handling stay as they are.

---

## Contents

1. [Tech stack](#tech-stack)
2. [Architecture](#architecture)
3. [Folder structure](#folder-structure)
4. [Setup](#setup)
5. [Environments and configuration](#environments-and-configuration)
6. [Running and building](#running-and-building)
7. [Google Sign-In setup](#google-sign-in-setup)
8. [Ads (AdMob + Unity)](#ads-admob--unity)
9. [Mock API architecture](#mock-api-architecture)
10. [Connecting the real API](#connecting-the-real-api)
11. [Adding a new feature](#adding-a-new-feature)
12. [Testing](#testing)
13. [Coding conventions](#coding-conventions)
14. [Security notes](#security-notes)

---

## Tech stack

| Concern | Choice |
| --- | --- |
| Flutter / Dart | Flutter 3.47 (stable), Dart 3.13 |
| Platform | Android only (`minSdk` from Flutter defaults) |
| UI | Material 3, custom design system, Outfit typeface |
| State management and DI | `flutter_riverpod` 3 |
| Navigation | `go_router` 18 (`StatefulShellRoute` for the bottom navigation) |
| Networking | `dio` 5 behind a single `ApiClient` |
| Auth | `google_sign_in` 7 (Credential Manager on Android) |
| Secure storage | `flutter_secure_storage` (tokens, cached session) |
| Preferences | `shared_preferences` (non-sensitive settings only) |
| Images | `cached_network_image` |
| Sharing and links | `share_plus`, `url_launcher` |

Models are plain immutable Dart classes with hand-written `fromJson` / `toJson`. Freezed was left out on purpose: the models are small, and skipping code generation keeps the build simple. It can be added per model later without touching callers.

---

## Architecture

Feature-first clean architecture. Every feature follows the same flow:

```text
Screen / Widget            (presentation/screens, presentation/widgets)
   │  ref.watch / ref.read
   ▼
Provider / Controller      (presentation/providers)       ← UI state: loading / data / empty / error
   │
   ▼
Use case                   (domain/usecases)              ← input validation, orchestration
   │
   ▼
Repository interface       (domain/repositories)          ← what the app needs
   │
   ▼
Repository implementation  (data/repositories)
   │
   ▼
Remote data source         (data/datasources)
   ├── XxxApiDataSource  → ApiClient → Dio → Backend      (real)
   └── XxxMockDataSource → in-memory mock "server"        (current default)
```

Rules the codebase follows:

* Widgets never touch Dio, storage or mock data. They only read providers.
* Business logic lives in use cases and controllers, never in widgets.
* Every API path is in `core/network/api_endpoints.dart`. Every route is in `app/router/route_names.dart`.
* Every design value (colour, spacing, radius, shadow, text style) comes from `app/theme`.
* Every failure becomes an `AppException` with a user-safe message. Raw errors and stack traces are never shown.

### Dependency injection

Each feature has `di/<feature>_dependencies.dart`, which wires data source, then repository, then use cases as Riverpod providers. Shared infrastructure (`ApiClient`, storage, session events) is in `core/di/core_providers.dart`.

### Key building blocks

| Piece | File | Purpose |
| --- | --- | --- |
| `ApiClient` | `core/network/api_client.dart` | GET/POST/PUT/PATCH/DELETE, envelope unwrapping, typed parsing, error mapping |
| `ApiResponse` | `core/network/api_response.dart` | The only place that knows the response envelope (`{ data, message, errors }`) |
| `AuthInterceptor` | `core/network/interceptors/auth_interceptor.dart` | Adds `Bearer` token; a `401` clears the session and emits a session-expired event |
| `LoggingInterceptor` | `core/network/interceptors/logging_interceptor.dart` | Logs method, URL, status and timing. Never logs headers or bodies |
| `SessionEvents` | `core/network/session_events.dart` | Decouples the HTTP layer from the auth feature |
| `AppLogger` | `core/utils/app_logger.dart` | Levelled logging, configured per environment |
| `PaginatedController` | `shared/models/paginated_state.dart` | Reusable infinite-list controller (transactions, notifications, articles, merchants) |
| `AsyncValueView` | `core/widgets/async_value_view.dart` | Consistent loading / empty / error / data rendering |
| `GradientPageScaffold` | `core/widgets/gradient_page_scaffold.dart` | Shared page layout: green header with a rounded content sheet |

### Navigation

`app/router/app_router.dart` defines every route. The four tabs (Home, Rewards, Wallet, Profile) are branches of a `StatefulShellRoute.indexedStack`, so each tab keeps its own stack and scroll position, and the floating bottom bar (`shared/components/app_bottom_navigation.dart`) is built once. Every other screen is pushed above the shell.

The auth guard is a pure function, `app/router/auth_redirect.dart`:

* While the stored session is being restored, the app stays on `/splash`.
* Guests are redirected to `/login`.
* Signed-in users never see `/login` or `/splash`.

---

## Folder structure

```text
lib/
├── main.dart                     # bootstrap: error hooks, prefs, ProviderScope
├── app/
│   ├── app.dart                  # MaterialApp.router, theme, text-scale clamp
│   ├── config/                   # environment.dart, app_config.dart, api_config.dart
│   ├── router/                   # app_router.dart, route_names.dart, auth_redirect.dart, main_shell.dart
│   └── theme/                    # app_colors, app_text_styles, app_dimensions, app_shadows, app_theme
├── core/
│   ├── di/                       # core providers (ApiClient, storage, session events)
│   ├── errors/                   # AppException + Network/Server/Unauthorized/Validation/Unknown
│   ├── extensions/               # BuildContext helpers (snackbars)
│   ├── mock/                     # MockLatency (simulated network delay)
│   ├── network/                  # ApiClient, ApiEndpoints, ApiResponse, interceptors/
│   ├── services/                 # ExternalLinkService (url_launcher + share_plus wrapper)
│   ├── storage/                  # SecureStorageService, LocalStorageService, TokenStorage, StorageKeys
│   ├── utils/                    # AppLogger, JsonReader, Formatters, Debouncer, color utils
│   └── widgets/                  # AppButton, AppCard, AppTextField, loaders, error/empty views, ...
├── shared/
│   ├── components/               # bottom nav, paginated list, reward dialog, feature tile card
│   └── models/                   # PaginatedList, PaginatedState / PaginatedController
└── features/
    ├── authentication/  home/  rewards/  wallet/  profile/  leaderboard/
    ├── notifications/   referral/  support/  articles/  shopping/  quiz/
    └── <feature>/
        ├── data/        datasources/ (api + mock), models/, repositories/
        ├── di/          <feature>_dependencies.dart
        ├── domain/      entities/, repositories/, usecases/
        └── presentation/ providers/, screens/, widgets/, <feature>_visuals.dart
```

| Feature | Screens |
| --- | --- |
| authentication | Splash, Login (Google, plus demo sign-in in dev) |
| home | Home: header, banner carousel, quick actions, Daily Rewards, Earn More, Quiz Zone |
| rewards | Rewards tab, Daily Check-in, Spin Wheel, Scratch Card, Captcha |
| wallet | Wallet tab (balance, stats, transactions, details sheet, redeem sheet) |
| profile | Profile tab, Edit Profile, Settings |
| leaderboard | Leaderboard (weekly / monthly / all-time, podium, your rank) |
| notifications | Notifications (read/unread, details, mark all read) |
| referral | Invite Friends (code, share, stats, invited users) |
| support | Contact Us (email, phone, chat, hours, FAQ) |
| articles | Read & Earn, Articles (categories), Article detail with reading-reward tracking |
| shopping | Shop & Earn (search, categories), Merchant detail (offers, coupons, terms) |
| quiz | Daily Quiz, Math Quiz (timed), Give Answer (free text) with results and review |

---

## Setup

```bash
flutter --version   # 3.47.x stable
flutter pub get
```

Android requirements: Android SDK with `compileSdk`/`targetSdk` from the Flutter defaults, and JDK 17.

Release signing: copy `android/key.properties.example` to `android/key.properties` (git-ignored) and fill in your upload keystore. Without it, release builds fall back to the debug key so `flutter build apk` still works locally.

---

## Environments and configuration

All configuration is in `lib/app/config/` and is set with `--dart-define`:

| Define | Default | Purpose |
| --- | --- | --- |
| `ENV` | `development` | `development`, `staging` or `production` |
| `API_BASE_URL` | per environment (see `api_config.dart`) | Overrides the backend base URL |
| `USE_MOCK_API` | `true` | `false` switches every repository to the real API |
| `GOOGLE_SERVER_CLIENT_ID` | *(empty)* | OAuth **web** client id used to get Google ID tokens |
| `ADS_ENABLED` | `true` | `false` turns every ad off (rewards then need no ad) |
| `ADMOB_APP_ID` | AdMob test app | AdMob **app** id (`ca-app-pub-…~…`). Read by Gradle into the manifest; the only ad id that can't come from the backend |

Ad unit ids, the Unity game id, the network share, the interstitial frequency and per-screen switches come from the backend (`GET /ads/config`) and are edited in the admin panel. See [docs/ADS_BACKEND_CHANGES.md](docs/ADS_BACKEND_CHANGES.md).

Environment effects:

* **Logging:** debug-level logs in development, info in staging, warnings and errors only in production. Network logging is disabled in production.
* **Demo sign-in:** shown only when `USE_MOCK_API=true` and `ENV` is not `production`.

---

## Running and building

```bash
# Development against mock data (default)
flutter run

# Staging against a real backend
flutter run --dart-define=ENV=staging \
            --dart-define=USE_MOCK_API=false \
            --dart-define=API_BASE_URL=https://staging-api.example.com/api/v1 \
            --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com

# Release APK
flutter build apk --dart-define=ENV=production --dart-define=USE_MOCK_API=false \
                  --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com

# Play Store bundle
flutter build appbundle --dart-define=ENV=production --dart-define=USE_MOCK_API=false \
                        --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com
```

Easier: use the ready-made files in `env/` (`development.json`, `staging.json`, `production.json`):

```bash
flutter run --dart-define-from-file=env/development.json
flutter build appbundle --dart-define-from-file=env/production.json
```

In VS Code, pick a configuration in **Run and Debug** (`.vscode/launch.json`): *Dev · mock data*, *Dev · local backend*, *Staging*, *Production (profile mode)*. Defines are compiled in, so changing one needs a full restart, not a hot reload.

**Local Spring Boot backend:** `env/development.json` points to `http://10.0.2.2:8080/api/v1`, which is how the Android emulator reaches your computer. Debug builds allow plain HTTP only to `10.0.2.2`, `localhost` and `127.0.0.1` (`android/app/src/debug/res/xml/network_security_config.xml`). On a real phone, use your computer's LAN IP in the URL and add it to that file. Release builds are HTTPS-only.

---

## Google Sign-In setup

The app uses `google_sign_in` 7, which on Android runs on Credential Manager. No `google-services.json` is needed.

1. In [Google Cloud Console](https://console.cloud.google.com/apis/credentials), create (or pick) a project and configure the OAuth consent screen.
2. Create an **Android** OAuth client:
   * Package name: `com.kavodnik.app`
   * SHA-1 of the signing certificate. Debug: `cd android && ./gradlew signingReport`. Release: your upload key, and add the **Play App Signing** SHA-1 as a separate Android client.
3. Create a **Web application** OAuth client. Its client id is the *server client id*. Your backend uses the same id to verify ID tokens.
4. Run the app with `--dart-define=GOOGLE_SERVER_CLIENT_ID=<web client id>`.

Flow:

```text
LoginScreen → AuthController → SignInWithGoogle (use case)
  → AuthRepositoryImpl
      → GoogleAuthService.signIn()          → Google ID token
      → AuthRemoteDataSource.loginWithGoogle(idToken)
                                              → { accessToken, refreshToken, user }
      → AuthLocalDataSource.saveSession()   → secure storage
  → AuthState.authenticated(user)           → router redirects to /home
```

Without a server client id, Google returns no ID token and the app shows a friendly error. In development you can use **Continue as demo user**, which signs in against the mock backend.

The backend must verify the ID token (signature, `aud` equal to the web client id, `iss`, `exp`) before issuing its own session tokens. The mock backend only decodes the token so it can display your Google name.

---

## Ads (AdMob + Unity)

Ads are the app's main revenue, so two networks are used and **every format is split between them** by the share set in the admin panel (50/50 alternates; fallback to the other network when one has no ad). Code: `lib/core/ads/` (`AdService` is the only entry point; screens never call an SDK).

**Settings come from the backend.** At every start the app fetches `GET /ads/config` (unit ids, Unity game id, shares, frequency, per-screen switches) and caches it, so admin changes apply on the next app start. Backend and admin panel work: [docs/ADS_BACKEND_CHANGES.md](docs/ADS_BACKEND_CHANGES.md).

| Where | Format | Behaviour |
| --- | --- | --- |
| Daily check-in, spin wheel, scratch card | Rewarded | The prize popup shows the coins with **Watch ad & collect**. Coins are credited (and the check-in completed) only after the ad, by `POST /rewards/claims/{id}/complete` |
| Captcha | Banner (bottom) + native | Native ad in the empty space below the form and the countdown (the same ad stays while they switch). After each answer, the next captcha loads after a 10 s countdown (`nextChallengeInSeconds` from the backend) |
| Quizzes | Banner (bottom) + native | Native ad in the empty space below the question or result, sized to fit; nothing if the content fills the screen |
| Read & Earn, Articles | Banner (bottom) | |
| Article detail | Banner (bottom) + native | Native ad after the last paragraph |
| Screen changes | Interstitial | Defaults: at most every 4 screen changes and 90 s after any full-screen ad, never in the first minute (admin-configurable) |

Unity has no native format, so native ads always come from AdMob.

**Development:** non-production builds always use Google's test units and Unity test mode, even when the backend returns real ids, but follow every other admin setting. Without a backend config (or with the mock API), AdMob test ads are used.

**Production setup:**

1. **AdMob:** create the Android app and four ad units (rewarded, interstitial, banner, native advanced). Put the **app id** in `env/production.json` (`ADMOB_APP_ID`) and the **unit ids** in the admin panel.
2. **AdMob server-side verification:** on the rewarded unit, set the SSV callback URL to `https://api.kavodnik.com/api/v1/ads/callbacks/admob` (see `docs/API_SPEC.md` §6.14).
3. **Unity:** create the project; enter the Android game id, placement ids and S2S secret in the admin panel, and enable S2S redeem callbacks to `/api/v1/ads/callbacks/unity`.
4. **`app-ads.txt`:** publish the lines from both dashboards on your developer website.
5. **Play Console:** declare "Contains ads" and the advertising ID in the Data safety form.
6. **Consent:** AdMob's UMP consent form runs at start-up. It appears only where required (EEA/UK). Configure the GDPR message in AdMob → Privacy & messaging.

> Never click your own live ads. Use test ids or add your device as a test device, or the AdMob account can be suspended.

---

## Mock API architecture

* Every feature has `data/datasources/<feature>_mock_data_source.dart`, which implements the same `<Feature>RemoteDataSource` interface as `<Feature>ApiDataSource`.
* Mock sources return the same **model** classes the API sources parse from JSON, so the UI cannot tell them apart.
* `MockLatency` adds about 700 ms per call so loading states are visible. Tests set it to zero.
* Mock sources share state like a real backend would:
  * `MockWalletLedger` (wallet) is credited by check-in, spin, scratch, captcha, quiz and article rewards, so balances, transactions and history stay consistent.
  * `MockUserStore` (authentication) holds the signed-in user for the profile, leaderboard and referral mocks.
* Game outcomes (spin result, scratch prize, captcha validity, quiz scoring, daily limits, streaks) are decided **inside the mock data sources**, which stand in for the server. The UI only requests actions and animates the results.

---

## Connecting the real API

For each feature, the work is:

1. **Confirm the endpoint paths** in `lib/core/network/api_endpoints.dart`.
2. **Confirm the envelope** in `lib/core/network/api_response.dart` (`unwrap`, `errorMessage`, `fieldErrors`). This is the only file that knows the response shape.
3. **Align JSON field names** in the feature's `data/models/*_model.dart` (`fromJson` / `toJson`). The domain entities and UI do not change.
4. **Check the API data source** (`data/datasources/<feature>_remote_data_source.dart`, class `<Feature>ApiDataSource`). The calls are already written, so usually only paths or bodies need adjusting.
5. **Switch to the real backend:**

   ```bash
   flutter run --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=https://api.example.com/api/v1
   ```

   The switch is `useMockApiProvider` in `core/di/core_providers.dart`, and each `di/<feature>_dependencies.dart` picks the API or mock source from it. To move one feature at a time, change that feature's provider to always return its `ApiDataSource`.
6. **Optional token refresh:** `AuthInterceptor.onError` is where a refresh-token flow (`ApiEndpoints.refreshToken`) belongs. Today a `401` ends the session.

Screens, widgets, routes, controllers and use cases do not change.

Example: the wallet feature against a live API.

```dart
// lib/features/wallet/di/wallet_dependencies.dart
final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>(
  (ref) => WalletApiDataSource(ref.watch(apiClientProvider)),
);
```

---

## Adding a new feature

1. Create `lib/features/<name>/` with `domain/`, `data/`, `di/` and `presentation/`.
2. **Domain:** entities (immutable), a repository interface, and use cases.
3. **Data:** models (`extends Entity`, with `fromJson`/`toJson`), a `<Name>RemoteDataSource` interface with `<Name>ApiDataSource` and `<Name>MockDataSource`, and `<Name>RepositoryImpl`.
4. **Endpoints:** add them to `ApiEndpoints`.
5. **DI:** add `di/<name>_dependencies.dart`, switching on `useMockApiProvider`.
6. **Presentation:** providers (`FutureProvider.autoDispose`, an `AsyncNotifier`, or a `PaginatedController` subclass for lists), then screens built from `core/widgets` and `shared/components`.
7. **Routing:** add the path to `AppRoutes` and a `GoRoute` in `app_router.dart`.
8. **Tests:** cover the repository with the mock data source, and any non-trivial controller logic.

---

## Testing

```bash
flutter analyze
dart format .
flutter test
```

| Suite | Covers |
| --- | --- |
| `test/unit/features/authentication` | Auth state machine (restore, sign-in, cancel, error, sign-out, 401 expiry) and repository token persistence |
| `test/unit/app/auth_redirect_test.dart` | Route guard |
| `test/unit/core/api_client_test.dart` | Envelope unwrapping, bearer token, 401/422/500 mapping, parse failures |
| `test/unit/models` | JSON serialisation, lenient parsing, unknown enum values |
| `test/unit/features/rewards` | Check-in streak and limits, spin limits, scratch card, captcha |
| `test/unit/features/wallet` | Pending balance, pagination, redeem validation |
| `test/unit/features/quiz` | Quiz session controller: answering, advancing, submitting, scoring |
| `test/widget/components_test.dart` | `QuickActionItem`, `RewardCard`, `WalletBalanceCard`, `QuizOptionCard` |
| `test/widget/app_flow_test.dart` | End to end: login → demo sign-in → home sections → wallet tab → logout |

`test/helpers/test_helpers.dart` replaces platform plugins with in-memory fakes, so the whole app runs inside `flutter test`.

---

## Coding conventions

* `analysis_options.yaml` enables strict casts and raw types, plus lints such as `prefer_single_quotes`, `require_trailing_commas` and `directives_ordering`. `flutter analyze` must be clean.
* Format with `dart format .` (Dart 3.13 tall style).
* **Naming:** `XxxRepository` (interface) and `XxxRepositoryImpl`; `XxxApiDataSource` and `XxxMockDataSource`; `XxxModel extends Xxx`; DI files are `<feature>_dependencies.dart`; UI providers are in `presentation/providers/`.
* Keep widgets small and composed; prefer `StatelessWidget` plus providers over local state, and use local state for UI-only concerns (text controllers, animation).
* Use design tokens from `app/theme` instead of literals, routes from `AppRoutes`, and storage keys from `StorageKeys`.
* Use `AppLogger` instead of `print`.
* Show errors with `AppErrorView`, `context.showErrorSnack` or `userMessageFor(error)`. Never show `error.toString()`.
* Every API-driven section handles loading, empty and error states (`AsyncValueView`, `PaginatedListView`).
* Riverpod's automatic retry is disabled in `main.dart`, so failures surface immediately with a retry button.

---

## Security notes

* The app contains no secrets. The Google *server client id* is a public identifier.
* Access and refresh tokens and the cached user live only in `flutter_secure_storage` (Android Keystore). `shared_preferences` holds only non-sensitive settings.
* Logs never include headers or bodies, and network logging is off in production.
* The backend must be the source of truth for wallet balance, rewards and eligibility, quiz answers, spin and scratch outcomes, transactions and referral rewards. The client sends intents (`claim`, `spin`, `submit`) and renders what the server returns.
* The captcha `previewText` field exists only in the mock. The real API must send an image and keep the solution server-side.
* Release builds use R8 minification (`isMinifyEnabled = true`). APKs can still be reverse engineered, so never rely on client-side checks for rewards.
