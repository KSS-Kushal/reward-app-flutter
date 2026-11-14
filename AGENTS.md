# AGENTS.md

Guidance for AI coding agents working on **Kavodnik**, an Android-only Flutter rewards app (users earn coins through check-in, spin, scratch, captcha, quizzes, articles, shopping and referrals, then redeem them).

Read this first. `README.md` has the full detail (setup, env defines, Google Sign-In, ads, real-API migration). `docs/API_SPEC.md` is the backend contract and `docs/ADS_BACKEND_CHANGES.md` covers ad settings. Both are git-ignored and exist only locally.

---

## Owner rules

- **Android only.** Don't spend effort on iOS, web or desktop.
- **Keep the layers apart.** UI, business logic, API calls, config and data access never mix. Moving from mock data to the real API must only touch the data layer and config.
- **The backend decides.** The backend is Spring Boot + PostgreSQL, built by the owner. Coin amounts, game outcomes, limits, streaks and eligibility are the server's job (today the mock data sources play the server). The client only sends intents and shows what comes back.
- **Design source of truth** is the Figma prototype. The only local references are `claudeAgent/design-reference/home-*.png`. Other screens follow that look.
- **Agent scratch space** is `claudeAgent/` (git-ignored): notes, logs, edit scripts. Don't use system temp folders. Longer working notes and the change log are in `claudeAgent/agent.md`; add an entry there when you finish a significant change.

---

## Commands

```bash
flutter pub get
flutter analyze          # must report "No issues found"
dart format lib test     # Dart 3.13 tall style
flutter test             # all tests must pass
flutter run --dart-define-from-file=env/development.json
flutter build apk --release
flutter build appbundle --release --dart-define-from-file=env/production.json
```

- All config is compile-time (`--dart-define` / `env/*.json`), so changing a value needs a full restart, not a hot reload. VS Code launch configs are in `.vscode/launch.json`.
- `USE_MOCK_API` defaults to `true` in code, but read `env/*.json` before you assume which backend a launch config uses.
- Never commit secrets: `env/`, `android/key.properties` and `*.jks` are git-ignored. Keep them that way.

---

## Architecture

Flutter 3.47 / Dart 3.13, Riverpod 3, go_router 18, dio 5, google_sign_in 7, flutter_secure_storage, google_mobile_ads + unity_ads_plugin.

```text
lib/
  main.dart        bootstrap: error hooks, SharedPreferences, ProviderContainer (retry disabled), ad init
  app/             config/ (env, api, ads), router/ (routes, guard, shell), theme/ (design tokens)
  core/            ads/, di/, errors/, network/, storage/, services/, utils/, widgets/, mock/
  shared/          components/ (bottom nav, paginated list, dialogs), models/ (pagination)
  features/<f>/    data/ (datasources, models, repositories), di/, domain/ (entities, repositories, usecases),
                   presentation/ (providers, screens, widgets)
```

Features: authentication, home, rewards, wallet, profile, leaderboard, notifications, referral, support, articles, shopping, quiz.

Call flow: **Screen → provider/controller → use case → repository interface → repository impl → `<F>RemoteDataSource`** (`<F>ApiDataSource` through `ApiClient`, or `<F>MockDataSource`). `di/<f>_dependencies.dart` picks the API or mock source from `useMockApiProvider` (`core/di/core_providers.dart`).

### Hard rules

- Widgets read providers only. They never touch Dio, storage or mock data.
- Every API path goes in `core/network/api_endpoints.dart`, every route in `app/router/route_names.dart` (`AppRoutes`), and every storage key in `core/storage/storage_keys.dart`.
- Design values come from `app/theme` (`AppColors`, `AppSpacing`, `AppRadius`, `AppSizes`, `AppTextStyles`, `AppShadows`). No literal colours or sizes.
- Only `core/network/api_response.dart` knows the response envelope `{success, message, data, errors?, code?}`. On a 2xx, `success:false` becomes a `ValidationException`.
- Every failure becomes an `AppException` subclass (`core/errors`). Show it with `userMessageFor(error)`, `AppErrorView` or `context.showErrorSnack`, never `error.toString()`.
- Tokens and the cached user go in `flutter_secure_storage` only. `shared_preferences` is for non-sensitive settings.
- Log with `AppLogger`, never `print`. Never log headers, bodies or tokens.

### Conventions

- Naming: `XxxRepository` / `XxxRepositoryImpl`, `XxxApiDataSource` / `XxxMockDataSource`, `XxxModel extends Xxx` (entity).
- Models are immutable classes with hand-written `fromJson` / `toJson` using the `JsonReader` extension (`core/utils/json_reader.dart`). There is no Freezed or code generation; don't add it. `readEnum` is lenient: `DAILY_CHECK_IN` maps to `dailyCheckIn`.
- Providers: `FutureProvider.autoDispose`, `AsyncNotifier`, or a `PaginatedController` subclass for lists (backend pagination: `page` is 1-based, plus `limit`).
- UI: non-home screens use `GradientPageScaffold`. Async sections use `AsyncValueView` or `PaginatedListView` and handle loading, empty and error states.
- Riverpod 3: check `ref.mounted` after every `await` before touching `state` or `ref`. Family notifiers take their argument through the constructor.
- Dart 3.13 idioms are in use: private named initializing formals (`required this._x`) and null-aware elements (`'key': ?value`).
- Lints are strict (`strict-casts`, `strict-raw-types`, `directives_ordering`, `require_trailing_commas`, `prefer_single_quotes`, `unawaited_futures`). Run `dart fix --apply` and `dart format` after edits.

### Adding a feature

Follow "Adding a new feature" in `README.md`: domain → data (API + mock source) → endpoints → `di/` → presentation → route in `AppRoutes` + `app_router.dart` → tests.

---

## Sensitive areas

**Auth and networking** (`core/network/`). `AuthInterceptor` adds the bearer token. On a `401` it calls `TokenRefresher.refresh()` (one request at a time, on a Dio with no interceptors) and retries the request once. The session ends only when the refresh is refused (401/403) or there is no refresh token. Network or 5xx errors during a refresh keep the session and come back as a connection error. Login calls opt out with `Options(extra: {AuthInterceptor.skipAuthKey: true})`. The README's "Today a 401 ends the session" line is out of date.

**Ads** (`core/ads/`). `AdService` (`adServiceProvider`) is the only entry point; screens never call an ad SDK directly. Settings come from `GET /ads/config` and are cached. Non-production builds always use test units and Unity test mode. Never click live ads. Use the `BannerAdSlot`, `NativeAdSlot` and `AdaptiveNativeAdSliver` widgets (with `placement:`). Interstitials are handled by `InterstitialRouteObserver` + `InterstitialPolicy`.

**Ad-gated rewards.** Check-in, spin and scratch return a `PendingReward`. Coins are credited only by `WatchAdRewardDialog` → `RewardClaimController` → `AdService.showRewarded(customData: claimId)` → `CompleteRewardClaim`. Never credit those coins anywhere else.

**Mock backend.** `MockWalletLedger` is the shared coin ledger and `MockUserStore` holds the current user. `MockLatency` adds about 700 ms per call (tests set it to zero). All mock state lives in memory and resets on restart. The mock captcha's `previewText` (the answer) exists only in the mock.

---

## Testing

- Layout: `test/unit/{app,core,features,models}` and `test/widget`. `test/helpers/test_helpers.dart` provides `testOverrides()`, `createTestContainer()`, `themed()`, `disableMockLatency()` and in-memory fakes for storage, Google Sign-In and ads (`DisabledAdService`, where a rewarded ad counts as watched).
- Cover new repositories through their mock data source, plus any non-trivial controller logic.
- Widget-test pitfalls:
  - `Text.rich` needs `find.text(..., findRichText: true)`.
  - End the test with `pumpWidget(const SizedBox.shrink())` so the banner auto-scroll timer stops.
  - Skeleton loaders animate forever, so `pumpAndSettle` never settles. Pump with explicit durations instead.
  - Network images and platform-view ads can't render in tests.
  - Test periodic timers (the captcha cooldown) with `testWidgets` + `tester.pump(Duration)`.

---

## Environment gotchas

- On this Windows machine, Git Bash heredocs that contain Dart quotes break. Edit files with the editor tools, or write a Python script to `claudeAgent/scripts/` (helper: `edit_util.py`) and run it from the repo root.
- `android/app/build.gradle.kts`: import `java.util.*` classes at the top of the file, because the `java.` prefix resolves to the Java extension. `ADMOB_APP_ID` is read from the base64 `dart-defines` Gradle property into the manifest.
- google_mobile_ads needs minSdk 24. Unity Ads has no native format, so native ads always come from AdMob.
- Debug builds allow cleartext HTTP only to `10.0.2.2`, `localhost` and `127.0.0.1` (`android/app/src/debug/res/xml/network_security_config.xml`). Release builds are HTTPS-only.
- Without `android/key.properties`, release builds are signed with the debug key.
