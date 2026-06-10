# Launchable Module Framework

## Trigger

Signals: LaunchableModule, ModuleLauncher, ModuleController, ModuleService, ModuleScaffold, ModuleSession, session token, moduleToken, parentToken, module_registry, "launch a module", auth factor, FR, OTP as step-up
Before generating code in this area, output verbatim: `Reading: module-launcher.md`

## Rules — NEVER Violate

1. **Never hand-roll the module lifecycle.** A new launchable module is built ONLY on the three shared rails in `lib/src/shared/application/`: `ModuleControllerMixin<P, R>`, `loadWhenSessionReady<T>()`, `ModuleLauncherBase<P, R>`.
2. **The word `Module` marks module-control classes only** (launcher, session controller, lifecycle service). Feature work (screens, content controllers, repositories, domain) stays plain-named. The signal does **not** change folders: a `*_module_controller.dart` is still a controller and lives in `presentation/`; only the launcher (`*_module_launcher.dart`) and module service (`*_module_service.dart`) sit in `application/`.
3. **The module controller holds session/lifecycle state only** (`ModuleSession`), never a screen's content. Per-screen content lives in auto-disposed `@riverpod` controllers gated by `loadWhenSessionReady`.
4. **Exactly one terminal result** reaches the caller (`onCompleted` / `onCancelled` / `onFailed`) — enforced by the mixin's `_terminated` guard. Never bypass it.
5. **Module screens are passive**: the finish button calls `controller.complete()` only — a screen never pops itself; the caller navigates on the result it receives.
6. **`ModuleScaffold` wraps the ENTRY screen only.** Deeper screens within the module are plain `Scaffold` screens with normal back.
7. **Launch params travel in one bag**: `ModuleLaunchContext.args` (`Map<String, dynamic>`). Never widen `launch(...)` or `ModuleLaunchContext` for a module-specific field. The launcher reads keys in `mapParams`; the module's **service** decides which keys go to the backend (e.g. auth/FR/OTP map `args['callbackModule']` into their start DTO).
8. **Sibling modules never import each other.** They meet only through `LaunchableModule` at the composition root `lib/src/router/module_registry.dart`.

## The three rails

| Rail | Shared piece | The module only provides |
|---|---|---|
| Session controller | `ModuleControllerMixin<P, R>` (`module_controller_mixin.dart`) | `build()` one-liner + `openSession(P)` → module token (`''` if none) + optional `finishSession()` (only when the result comes from the server) + optional `abortSession()` |
| Screen content controller | `loadWhenSessionReady<T>()` (`module_screen_content.dart`) | a `build()` that calls it with its load |
| Launcher | `ModuleLauncherBase<P, R>` + `GoRouter.enterModule` (`module_launcher_base.dart`) | `controller` getter + `mapParams` + `mapResult` (+ `onEnter` only if it navigates itself) |

`ModuleSession` (sealed, `module_session.dart`): `Idle → Loading → Ready → (Finishing) → Closed`, with `Failed` as the escapable error state. The mixin drives `start` → `AsyncValue.guard(openSession)` → `Ready`/`Failed`, `complete`, `cancel`, and the exactly-once `_fail` path.

## Reference implementation — `sample_module` (embedded snapshot)

> This snapshot is the canonical module example. The live `features/sample_module/` copy was removed from this template when `expense` became the reference feature (see `MIGRATION.md`); scaffold a real module with the `add-module` skill.

**1. Session controller** (`presentation/sample_module_controller.dart`):

```dart
@Riverpod(keepAlive: true)
class SampleModuleController extends _$SampleModuleController
    with ModuleControllerMixin<SampleLaunchParams, SampleResult> {
  @override
  ModuleSession build() => const ModuleSessionIdle();

  @override
  Future<String> openSession(SampleLaunchParams params) =>
      ref.read(sampleModuleServiceProvider).startSample(params);

  @override
  Future<SampleResult> finishSession() async =>
      SampleResult(value: await ref.read(sampleModuleServiceProvider).finish());
}
```

`build()` MUST stay in the concrete class returning `const ModuleSessionIdle()` — riverpod_generator reads the state type there. A direct entry (deeplink/hot reload) therefore lands in `Idle`, which `ModuleScaffold` renders as an escapable error, never an infinite spinner.

**2. Screen content controller** (auto-dispose; real example `fr_home_controller.dart`):

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

**3. Launcher** (`application/sample_module_launcher.dart`):

```dart
class _SampleModuleLauncher
    extends ModuleLauncherBase<SampleLaunchParams, SampleResult> {
  _SampleModuleLauncher(super.ref);

  @override
  ModuleControllerMixin<SampleLaunchParams, SampleResult> get controller =>
      ref.read(sampleModuleControllerProvider.notifier);

  @override
  SampleLaunchParams mapParams(ModuleLaunchContext context) =>
      SampleLaunchParams(
        title: context.args['title'] as String? ?? '',
        id: context.args['id'] as String? ?? '',
      );

  @override
  ModuleResult mapResult(SampleResult result) =>
      ModuleResult(status: ModuleResultStatus.completed, token: result.value);

  @override
  void onEnter(ModuleLaunchContext context) {
    ref.read(goRouterProvider)
        .enterModule(SampleModuleRouter.home.name, context.navOptions.entryMode);
  }
}

@Riverpod(keepAlive: true)
LaunchableModule sampleModuleLauncher(Ref ref) => _SampleModuleLauncher(ref);
```

**4. Entry screen** renders via `ModuleScaffold` (`lib/src/shared/presentation/module_scaffold.dart`): it watches the session, owns the back policy (`ModulePopScope` → `cancel()`), and shows `ModuleErrorView` for `Failed`/`Idle`. The finish button calls `controller.complete()` (or `complete(result)` for client-determined results) — nothing else.

## Terminal semantics

- `complete(result)` — result is **client-determined** (a user choice). Do NOT store it as a field on the module controller.
- `complete()` — runs `finishSession()` (**server** finalize, e.g. `finishOTP`); a failure auto-routes to `onFailed`.
- `cancel()` — user backs out: `Closed` → `abortSession()` (server cleanup; default no-op) → `onCancelled`.
- Open/finish failure — auto-reports `onFailed`, state stays `Failed` (escapable). An orchestrator must treat `failed` distinctly — never hang.
- `finishSession` is success-finalize ONLY; never call it on abort/failure.

## Composition root — registering a module

`lib/src/router/module_registry.dart` is the ONLY file that imports every module. Register the launcher id and spread the routes:

```dart
final moduleLauncherRegistryOverride = moduleLauncherRegistryProvider
    .overrideWith((ref) {
      return <String, LaunchableModule>{
        'auth': ref.read(authModuleLauncherProvider),
        'sample': ref.read(sampleModuleLauncherProvider),
      };
    });
```

Auth factors additionally get an `AuthFactorBinding` (startLink → entry route + launcher + `ModuleNavOptions`) in `authFactorRegistryOverride` in the same file.

## Naming — `Module` is a signal, not decoration

| Role | Class | File | Folder |
|---|---|---|---|
| Launcher (adapter) | `<Feature>ModuleLauncher` | `<feature>_module_launcher.dart` | `application/` |
| Session controller | `<Feature>ModuleController` | `<feature>_module_controller.dart` | `presentation/` (it is a controller) |
| Lifecycle service (startX/finishX only) | `<Feature>ModuleService` | `<feature>_module_service.dart` | `application/` |
| Screen / content controller / repository / domain | plain (`FrHomeScreen`, `FrHomeController`, `SampleRepository`, `FrHomeData`) | plain | by suffix |

Test: "do this class's functions exist only to control the module?" → yes ⇒ `Module` in the name.

Note: a module does not have to own content screens — `otp` keeps only a session (no content screen controller); `face_recognition` has both. The session/content split applies whenever content exists, but session-only modules are valid.

## Checklist — add module `foo`

1. `domain/`: `FooLaunchParams`, `FooResult`.
2. `FooModuleController extends _$FooModuleController with ModuleControllerMixin<FooLaunchParams, FooResult>` — `build()` + hooks.
3. Screen controller(s): `build() => loadWhenSessionReady(ref, fooModuleControllerProvider, () => ...)`.
4. Entry screen via `ModuleScaffold(controllerProvider: ..., ready: (ctx, onErrorClose) => ...)`; deeper screens plain `Scaffold`.
5. `_FooModuleLauncher extends ModuleLauncherBase<FooLaunchParams, FooResult>` + keepAlive provider.
6. Register in `lib/src/router/module_registry.dart` (launcher id + routes).

## Exemption

`authentication/auth_module` (reference app) is an orchestrator (multi-step factor flow state), not a single-session module — it implements `LaunchableModule` for callers but does not use the session rails internally. Do not copy its internals for a normal module; copy the `sample_module` snapshot above.

Discoverability: `ls lib/src/features/*/application/*_module_launcher.dart` · `grep -rn "ModuleLauncher\|ModuleController" lib/`

## Recap

1. Three rails, never hand-rolled; the `sample_module` snapshot above is the template.
2. Session state in the keepAlive Module controller; content in auto-dispose screen controllers.
3. Exactly one terminal result; screens passive; `ModuleScaffold` entry-only.
4. Wire at `module_registry.dart`; params via `args` bag; `Module` naming = control classes only.
