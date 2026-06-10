# Riverpod & State

## Trigger

Signals: `@riverpod`, `@Riverpod`, provider, controller, notifier, AsyncValue, keepAlive, ref.watch / ref.read / ref.listen / ref.invalidate, `part '*.g.dart'`
Before generating code in this area, output verbatim: `Reading: riverpod-state.md`

## Rules — NEVER Violate

1. **Codegen only.** Every provider uses `@riverpod` / `@Riverpod(keepAlive: true)` annotations with `part '<file>.g.dart';`. Never manual `Provider(...)`, `FutureProvider`, `StateNotifierProvider`, etc. Never hand-edit `*.g.dart`.
2. **Lifetime by role**:
   - `@Riverpod(keepAlive: true)` — Dio clients, repositories, storage, `goRouter`, module session controllers. App-lifetime singletons.
   - `@riverpod` (auto-dispose) — screen controllers, services, anything scoped to a screen/flow.
3. **`ref.watch` only in `build()` / provider body. `ref.read` in callbacks. `ref.listen` for side effects** (navigation, snackbars). `ref.invalidate` sparingly and never as a substitute for proper state design.
4. **Async mutations use `AsyncValue.guard()`** — never bare try/catch that swallows the error (see [error-handling.md](error-handling.md)).
5. **Screens render remote data via `AsyncValue.when`** or `SystemAsyncValueWidget`. No `StatefulWidget` holding server-derived state.
6. After ANY annotation change, run `rps gen build` (or keep `rps gen code` watching).

## Provider lifetime table

| Annotation | Lifetime | Used for | Real example |
|---|---|---|---|
| `@Riverpod(keepAlive: true)` | App | Dio, repositories, storage, router, module controllers | `paymentRepositoryProvider` (`lib/src/features/payment/data/payment_repository.dart`), `viperaDioProvider` |
| `@riverpod` class | Auto-dispose | Screen controllers | `FrHomeController` |
| `@riverpod` function returning a class | Auto-dispose | Services | `sampleScreenServiceProvider` |

## Controller shapes

Pick the variant from the operation type:

| Variant | When to use | `build()` | Action method |
|---|---|---|---|
| **Read/Fetch** | Screen loads data automatically on entry | calls the service method → `AsyncValue<T>` | none |
| **Submit** | User fills a form / taps a button | returns `null` (idle) | `submit()` sets loading + `AsyncValue.guard` |
| **Void** | Fire-and-forget trigger (e.g. log event) | `void` | `submit()` awaits the service, no return value |

**Load-on-entry controller (Read/Fetch)** — `build()` performs the load; the screen watches it:

```dart
@riverpod
class BankListController extends _$BankListController {
  @override
  Future<Banks?> build() => ref.read(paymentServiceProvider).getBanks();
}
```

**Mutation controller (Submit)** — `build()` returns an idle value; mutation methods drive the state:

```dart
@riverpod
class RequestStatementController extends _$RequestStatementController {
  @override
  Future<StatementRequest?> build() async => null;

  Future<void> execute(RequestStatementRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(accountServiceProvider).requestStatement(request),
    );
  }
}
```

(Shape from `lib/src/features/account/presentation/request_statement_controller.dart`, with the call routed through the Service per [service-layer.md](service-layer.md).)

**Module-gated controller** — loads only when the module session is ready (see [module-launcher.md](module-launcher.md)):

```dart
@riverpod
class FrHomeController extends _$FrHomeController {
  @override
  Future<void> build() => loadWhenSessionReady(
    ref,
    faceRecognitionModuleControllerProvider,
    () => ref.read(frScreenServiceProvider).getFRHomeData(
      ref.read(faceRecognitionModuleControllerProvider.notifier).moduleToken,
    ),
  );
}
```

## Screen consumption

```dart
final banksAsync = ref.watch(bankListControllerProvider);

return banksAsync.when(
  loading: () => const CommonCircularProgressWidget(),
  error: (e, st) => CommonErrorWidget(exception: e, stackTrace: st),
  data: (banks) => _BankList(banks: banks),
);
```

Or the shared wrapper `SystemAsyncValueWidget` (`lib/src/common_widgets/system_async_value_widget.dart`) which supplies default loading/error widgets and pull-to-refresh:

```dart
SystemAsyncValueWidget<Banks?>(
  value: banksAsync,
  data: (banks) => _BankList(banks: banks),
  onRefresh: () => ref.refresh(bankListControllerProvider.future),
)
```

Reacting to a mutation result (navigation/snackbar) uses `ref.listen` in the screen:

```dart
ref.listen(requestStatementControllerProvider, (prev, next) {
  next.whenOrNull(
    data: (result) { if (result != null) context.goNamed(...); },
  );
});
```

## ref usage table

| Method | Where | Behavior |
|---|---|---|
| `ref.watch(p)` | `build()` / provider body | Subscribes; rebuilds on change |
| `ref.read(p)` | Callbacks, service bodies | One-shot, no subscription |
| `ref.listen(p, cb)` | Screen `build()` | Side effects on change |
| `ref.invalidate(p)` | Rare | Force re-run; prefer controller-owned refresh |

## Anti-patterns

- ❌ `ref.watch` inside a callback or service method body.
- ❌ Manual provider declarations (the legacy `themeModeStateProvider = StateProvider(...)` in `app_theme.dart` is grandfathered — do not add more).
- ❌ `StatefulWidget` + `initState` fetching server data — use a controller.
- ❌ Editing `.g.dart` files or committing annotation changes without running `rps gen build`.
- ❌ Function providers calling repositories — see [service-layer.md](service-layer.md).

## Recap

1. Codegen annotations only; `rps gen build` after changes.
2. keepAlive = infra + module sessions; auto-dispose = screens + services.
3. Mutations: `AsyncValue.loading()` then `AsyncValue.guard(...)`.
4. UI renders `AsyncValue.when` / `SystemAsyncValueWidget`; side effects via `ref.listen`.
