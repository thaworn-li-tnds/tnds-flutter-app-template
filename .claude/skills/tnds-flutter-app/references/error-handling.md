# Error Handling

## Trigger

Signals: try/catch, AppException, ActionCodeType, EXIT_FLOW, AsyncValue.guard, ErrorLogger, Crashlytics, DioException, error screen
Before generating code in this area, output verbatim: `Reading: error-handling.md`

## Rules — NEVER Violate

1. **All errors become `AppException` subclasses.** `AppException.parse(error:, stackTrace:)` (`lib/src/exceptions/app_exception.dart`) is the single translation entry point — never hand-roll DioException parsing.
2. **Controllers use `AsyncValue.guard()` for async mutations** — never bare try/catch that keeps the error out of `AsyncValue.when(error:)`.
3. **try/catch is allowed only at the data boundary** for error translation (e.g. mapping a raw response into a specific `AppException`) — and it must rethrow as an `AppException`, never swallow.
4. **`actionCode == EXIT_FLOW` exits the feature flow** — handle at controller/service level, never in widgets.
5. **No `print()` anywhere in `lib/src/`.** Errors route to `ErrorLogger` (→ Crashlytics). Non-error paths get no logging.
6. Never swallow errors silently. If a failure is intentionally ignored, comment why.

## ActionCodeType — server-driven directives

```dart
enum ActionCodeType {
  none(''),
  exitFlow('EXIT_FLOW'),          // terminate the current feature flow
  signedKeyBlock('SIGNED_KEY_BLOCK'),
  frRetryable('FR_RETRYABLE'),    // face recognition should offer retry
  integrityBlock('INTEGRITY_BLOCK');
}
```

Every `AppException` exposes `actionCode`; the backend attaches it via the response error block. Orchestrating code switches on it:

```dart
ref.listen(submitControllerProvider, (prev, next) {
  next.whenOrNull(error: (e, st) {
    final ex = AppException.parse(error: e, stackTrace: st);
    if (ex.actionCode == ActionCodeType.exitFlow) {
      // leave the flow — controller/service decision, not a widget's
    }
  });
});
```

## AppException hierarchy (sealed, `lib/src/exceptions/app_exception.dart`)

| Subclass | When |
|---|---|
| `ViperaPlatformError` | Vipera returned `err` field |
| `ViperaApplicationError` | Vipera returned structured `error` block |
| `SessionExpiredException` | `err == "E:V_SESSIONID_NOTFOUND"` |
| `ActivitySessionExpiredException` | Inactivity timer fired |
| `NoneNetworkDetectionException` / `WifiDetectionException` | Pre-flight network checks |
| `CertificateExpiredException` | TLS pin mismatch |
| `MaintainanceException` / `ForceUpdateException` | Backend maintenance / forced update |
| `ExitFlowException` / `FrRetryableException` / `IntegrityBlockException` / `SignedKeyException` | actionCode-driven |
| Domain validation (`FromAccountNotSelectedException`, `ConfirmPinNotMatchException`, …) | Feature-level guards |
| `UnknownException` | Fallback |

When a new failure mode needs distinct handling, add a subclass here (with `LocaleKeys` title/description — see [localization.md](localization.md)) rather than string-matching messages at call sites.

## The guard pattern

```dart
// ✅ error reaches AsyncValue.when(error:) and AsyncErrorLogger
Future<void> submit() async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(
    () => ref.read(transferServiceProvider).transfer(request),
  );
}

// ❌ error never reaches the UI or the logger
Future<void> submit() async {
  try {
    final result = await ref.read(transferServiceProvider).transfer(request);
    state = AsyncValue.data(result);
  } catch (e) {
    // swallowed
  }
}
```

`AsyncErrorLogger` (a `ProviderObserver` registered in `AppBootstrap`) logs every provider that lands in `AsyncError` through `ErrorLogger` → Crashlytics — guard + state is all a controller needs; no manual logging.

## Surfacing in UI

`CommonErrorWidget(exception:, stackTrace:)` / `SystemAsyncValueWidget`'s default error branch render `AppException.title`/`description` (already localized). Module screens use `ModuleErrorView` with an escape callback — see [module-launcher.md](module-launcher.md). Never `Text(e.toString())` raw errors to users.

## Global handlers

`AppBootstrap.registerErrorHandlers` wires `FlutterError.onError`, `PlatformDispatcher.instance.onError`, and `ErrorWidget.builder` to `ErrorLogger` + Crashlytics. Do not register additional global handlers in features.

## Recap

1. `AppException.parse` is the only translator; subclass for new failure modes.
2. Controllers: `AsyncValue.guard`, nothing else.
3. `EXIT_FLOW`/actionCodes handled in controllers/services, not widgets.
4. `ErrorLogger`, never `print()`.
