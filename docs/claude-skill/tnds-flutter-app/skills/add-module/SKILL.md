---
name: add-module
description: >
  Scaffold a complete LaunchableModule from scratch: domain, controller, launcher,
  service, screen controller, entry screen, router, and module_registry registration.
  Triggers on: add module, new module, scaffold module, create module, add launchable
allowed-tools: Bash, Read, Edit, Write, TodoWrite
---

# Skill: Add Module

Scaffold a complete LaunchableModule following rule `09-module-launcher-naming.md`.
Reference implementation: `lib/src/features/sample_module/`.

---

## Step 0 — Parse Arguments & Ask Clarifying Questions

Extract **feature name** (camelCase or snake_case) from `$ARGUMENTS`.

If not provided, ask before continuing.

Then ask these **4 questions** (can be answered in one reply):

```
1. Module ID string — the key used in moduleLauncherRegistryOverride
   (e.g. 'auth', 'sample', 'kyc')

2. LaunchParams fields — what does the caller pass in?
   (e.g. "parentToken: String, callbackModule: String" — or "none" for no fields beyond defaults)

3. Result type — what does the module return on success?
   (e.g. "token: String" — or "void" for no payload)

4. Does the module call a backend to open a session (startFoo)?
   - yes → generate ModuleService + repository stub + openSession returns token
   - no  → openSession returns '' (client-only, e.g. consent screen)
```

Derive from answers:
- `featureSnake` = snake_case of feature name → `face_recognition`, `kyc`
- `FeaturePascal` = PascalCase → `FaceRecognition`, `Kyc`
- `featureCamel` = camelCase → `faceRecognition`, `kyc`
- `hasService` = answer 4 == yes
- `hasResult` = answer 3 != "void"

---

## Step 2 — Explore & Read Reference

Before writing any file, read the reference implementation in parallel:

```bash
cat lib/src/features/sample_module/domain/sample_launch_params.dart
cat lib/src/features/sample_module/domain/sample_result.dart
cat lib/src/features/sample_module/application/sample_module_controller.dart
cat lib/src/features/sample_module/application/sample_module_launcher.dart
cat lib/src/features/sample_module/application/sample_screen_controller.dart
cat lib/src/features/sample_module/presentation/sample_screen.dart
cat lib/src/features/sample_module/router/sample_router.dart
cat lib/src/router/module_registry.dart
```

---

## Step 3 — Generate Files

Create all files. Use `sample_module` as the exact reference — mirror imports,
annotations, and structure. Only substitute the feature name and the fields
from the answers in Step 0.

### 3a — Domain: LaunchParams

`lib/src/features/{featureSnake}/domain/{featureSnake}_launch_params.dart`

```dart
class {FeaturePascal}LaunchParams {
  const {FeaturePascal}LaunchParams({
    // fields from answer 2
  });

  // final fields
}
```

Rules:
- Pure Dart only — zero imports from flutter, riverpod, dio
- No annotations, no `part` directive
- All fields have default values (non-nullable)

### 3b — Domain: Result

`lib/src/features/{featureSnake}/domain/{featureSnake}_result.dart`

Skip this file entirely if answer 3 was "void" — use `void` as the type parameter throughout.

```dart
class {FeaturePascal}Result {
  const {FeaturePascal}Result({required this.<field>});

  final <Type> <field>;
}
```

### 3c — Module Controller

`lib/src/features/{featureSnake}/application/{featureSnake}_module_controller.dart`

```dart
part '{featureSnake}_module_controller.g.dart';

@Riverpod(keepAlive: true)
class {FeaturePascal}ModuleController extends _${FeaturePascal}ModuleController
    with ModuleControllerMixin<{FeaturePascal}LaunchParams, {FeaturePascal}Result> {
  @override
  ModuleSession build() => const ModuleSessionIdle();

  @override
  Future<String> openSession({FeaturePascal}LaunchParams params) =>
      // hasService=true: call service.start{FeaturePascal}(params)
      // hasService=false: Future.value('')
      ;

  // Include finishSession() ONLY when result comes from the server:
  @override
  Future<{FeaturePascal}Result> finishSession() async =>
      {FeaturePascal}Result(<field>: await ref.read({featureCamel}ModuleServiceProvider).finish());

  // Include abortSession() ONLY when the module token needs server-side cleanup:
  // @override
  // Future<void> abortSession() => ref.read({featureCamel}ModuleServiceProvider).abort(moduleToken);
}
```

Decision table for which overrides to include:

| Scenario | `openSession` | `finishSession` | `abortSession` |
|---|---|---|---|
| Backend start + server result | calls service | ✅ override | only if cleanup needed |
| Backend start + client result | calls service | ❌ omit — call `complete(result)` directly | only if cleanup needed |
| Client-only (no backend) | `Future.value('')` | ❌ omit | ❌ omit |

### 3d — Module Launcher

`lib/src/features/{featureSnake}/application/{featureSnake}_module_launcher.dart`

```dart
part '{featureSnake}_module_launcher.g.dart';

class _{FeaturePascal}ModuleLauncher
    extends ModuleLauncherBase<{FeaturePascal}LaunchParams, {FeaturePascal}Result> {
  _{FeaturePascal}ModuleLauncher(super.ref);

  @override
  ModuleControllerMixin<{FeaturePascal}LaunchParams, {FeaturePascal}Result> get controller =>
      ref.read({featureCamel}ModuleControllerProvider.notifier);

  @override
  {FeaturePascal}LaunchParams mapParams(ModuleLaunchContext context) =>
      {FeaturePascal}LaunchParams(
        // map from context.args — never widen the launch signature
      );

  @override
  ModuleResult mapResult({FeaturePascal}Result result) =>
      ModuleResult(status: ModuleResultStatus.completed, token: result.<field>);
  // For void result: ModuleResult(status: ModuleResultStatus.completed)

  @override
  void onEnter(ModuleLaunchContext context) {
    ref
        .read(goRouterProvider)
        .enterModule(
          {FeaturePascal}Router.home.name,
          context.navOptions.entryMode,
        );
  }
}

@Riverpod(keepAlive: true)
LaunchableModule {featureCamel}ModuleLauncher(Ref ref) => _{FeaturePascal}ModuleLauncher(ref);
```

### 3e — Module Service (only if `hasService = true`)

`lib/src/features/{featureSnake}/application/{featureSnake}_module_service.dart`

```dart
part '{featureSnake}_module_service.g.dart';

/// Module-control service — only functions that drive the session lifecycle.
/// Carries `Module` in its name because all its functions exist only to control the module.
class {FeaturePascal}ModuleService {
  {FeaturePascal}ModuleService(this.ref);

  final Ref ref;

  {FeaturePascal}Repository get _repo => ref.read({featureCamel}RepositoryProvider);

  Future<String> start{FeaturePascal}({FeaturePascal}LaunchParams params) =>
      _repo.start{FeaturePascal}(/* map params fields */);

  Future<String> finish() => _repo.finish();
}

@riverpod
{FeaturePascal}ModuleService {featureCamel}ModuleService(Ref ref) =>
    {FeaturePascal}ModuleService(ref);
```

Skip this file if `hasService = false`.

### 3f — Screen Controller

`lib/src/features/{featureSnake}/application/{featureSnake}_screen_controller.dart`

```dart
part '{featureSnake}_screen_controller.g.dart';

@riverpod
class {FeaturePascal}ScreenController extends _${FeaturePascal}ScreenController {
  @override
  Future<{ContentType}> build() => loadWhenSessionReady(
    ref,
    {featureCamel}ModuleControllerProvider,
    () => ref
        .read({featureCamel}ScreenServiceProvider)
        .load(ref.read({featureCamel}ModuleControllerProvider.notifier).launchParams),
  );
}
```

If the entry screen has no content to load (purely session-gated UI with no async fetch),
skip this file and have the screen read `launchParams` directly from the controller.

### 3g — Entry Screen

`lib/src/features/{featureSnake}/presentation/{featureSnake}_screen.dart`

```dart
class {FeaturePascal}Screen extends ConsumerWidget {
  const {FeaturePascal}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read({featureCamel}ModuleControllerProvider.notifier);
    // if screen controller exists:
    final contentAsync = ref.watch({featureCamel}ScreenControllerProvider);

    return ModuleScaffold(
      title: '{FeaturePascal}',
      controllerProvider: {featureCamel}ModuleControllerProvider,
      ready: (context, onErrorClose) => contentAsync.when(
        loading: () => const Center(child: CommonCircularProgressWidget()),
        error: (error, _) => ModuleErrorView(error: error, onClose: onErrorClose),
        data: (content) => /* screen UI */,
      ),
    );
  }
}
```

Critical rules (from rule 09):
- **Entry screen ONLY**: wrap with `ModuleScaffold`. Deeper screens use plain `Scaffold`.
- **Finish button**: calls `controller.complete()` only — NO `context.pop()` alongside it.
- **Never a bare `CommonErrorWidget`** — always `ModuleErrorView` so the user can escape.

### 3h — Router

`lib/src/features/{featureSnake}/router/{featureSnake}_router.dart`

```dart
enum {FeaturePascal}Router with TndsRouter {
  home;
  // add more values if multi-screen

  @override
  String get routerName => '{featureSnake}_router';

  @override
  String get path {
    switch (this) {
      case {FeaturePascal}Router.home:
        return '/{feature-kebab}';
    }
  }
}

final {featureCamel}Router = <RouteBase>[
  GoRoute(
    path: {FeaturePascal}Router.home.path,
    name: {FeaturePascal}Router.home.name,
    builder: (context, state) => const {FeaturePascal}Screen(),
  ),
];
```

Path uses kebab-case (e.g. `face-recognition`, `kyc-verify`).

---

## Step 4 — Register in module_registry.dart

Edit `lib/src/router/module_registry.dart` — add in **two places**:

**4a — Add to `moduleLauncherRegistryOverride` map:**

```dart
'{moduleId}': ref.read({featureCamel}ModuleLauncherProvider),
```

**4b — Spread routes into the appropriate list:**

For a standalone module (not an auth factor):
```dart
final List<RouteBase> {featureCamel}ModuleRoutes = [
  ...{featureCamel}Router,
];
```
Then reference this list in `app_router.dart` alongside the other route spreads.

For an auth factor module, add a binding to `authFactorRegistryOverride` instead:
```dart
'{START_LINK}': AuthFactorBinding(
  startLink: '{START_LINK}',
  entryRouteName: {FeaturePascal}Router.home.name,
  module: ref.read({featureCamel}ModuleLauncherProvider),
  navOptions: const ModuleNavOptions(backTarget: ModuleBackTarget.opener),
),
```
And spread `...{featureCamel}Router` into `authFlowModuleRoutes`.

---

## Step 5 — Verify

```bash
fvm flutter analyze lib/src/features/{featureSnake}/ lib/src/router/module_registry.dart
```

Fix all errors. Then remind the user:

```
⚠️ Run `rps gen build` to generate *.g.dart files before testing.
```

---

## Step 6 — Summary

```
✅ Module `{FeaturePascal}` scaffolded

Files created:
- (new) lib/src/features/{featureSnake}/domain/{featureSnake}_launch_params.dart
- (new) lib/src/features/{featureSnake}/domain/{featureSnake}_result.dart
- (new) lib/src/features/{featureSnake}/application/{featureSnake}_module_controller.dart
- (new) lib/src/features/{featureSnake}/application/{featureSnake}_module_launcher.dart
- (new) lib/src/features/{featureSnake}/application/{featureSnake}_module_service.dart  [if hasService]
- (new) lib/src/features/{featureSnake}/application/{featureSnake}_screen_controller.dart  [if content]
- (new) lib/src/features/{featureSnake}/presentation/{featureSnake}_screen.dart
- (new) lib/src/features/{featureSnake}/router/{featureSnake}_router.dart

Files modified:
- (modified) lib/src/router/module_registry.dart — registered '{moduleId}'

Next steps:
1. `rps gen build` — generate *.g.dart
2. Wire the entry UI (replace placeholder content in {featureSnake}_screen.dart)
3. If hasService: implement {featureSnake}_repository.dart + fake_repository
```

---

## Notes

- Reference every generated file against `sample_module` — if something looks different, it's probably wrong.
- Module controller is `keepAlive: true`; screen controllers are `@riverpod` (auto-dispose).
- `ModuleScaffold` is **entry screen only** — deeper screens use plain `Scaffold`.
- Screens never `pop()` themselves — `controller.complete()` only.
- `finishSession` = server finalizes the result. `complete(result)` = client determines result. Never both.
- `abortSession` = server cleanup on cancel (default no-op if not overridden).
- Launch params always come through `context.args` — never widen `ModuleLaunchContext`.
