# Navigation

## Trigger

Signals: GoRoute, router enum, `goNamed` / `pushNamed`, `context.go`, deeplink, route params, `state.extra`, new screen route
Before generating code in this area, output verbatim: `Reading: navigation.md`

## Rules — NEVER Violate

1. **Enum-based navigation only**: `context.goNamed(XRouter.y.name)` / `context.pushNamed(...)`. Raw path strings (`context.go('/login')`) are forbidden.
2. **Every route group is an enum `with TndsRouter`** defining `routerName` and `path`; `name` is derived by the mixin — never hand-write route name strings.
3. **Route paths are kebab-case; enum values camelCase.**
4. **Deeplink entry routes use `queryParameters` only** — `extra` objects are lost on deeplink re-entry.
5. **Programmatic navigation from services/controllers goes through `ref.read(goRouterProvider)`** — never store a `GoRouter` reference manually.
6. Feature routes live in `features/<name>/router/<name>_router.dart` and are spread into the app router (or `module_registry.dart` for module routes) — `app_router.dart` does not define feature screens inline.

## The TndsRouter mixin

`lib/src/router/tnds_route.dart`:

```dart
mixin TndsRouter {
  String get routerName;
  String get path;
  String get parent => '';

  String get name {
    if (path == '/') return 'app_router';
    final generatePath = path.replaceAll('/', '').replaceAll('-', '_');
    if (parent.isNotEmpty) return '$routerName.$parent$generatePath';
    return '$routerName.$generatePath';
  }
}
```

## Canonical feature router

From `lib/src/features/face_recognition/router/face_recognition_router.dart`:

```dart
enum FaceRecognitionRouter with TndsRouter {
  frTutorial,
  frScan;

  @override
  String get routerName => 'face_recognition_router';

  @override
  String get path {
    switch (this) {
      case FaceRecognitionRouter.frTutorial:
        return '/onboard/face-recognition/tutorial';
      case FaceRecognitionRouter.frScan:
        return '/onboard/face-recognition/scan';
    }
  }
}

final faceRecognitionRouter = [
  GoRoute(
    path: FaceRecognitionRouter.frTutorial.path,
    name: FaceRecognitionRouter.frTutorial.name,
    builder: (context, state) => const FrTutorialScreen(),
  ),
  // ...
];
```

Note the path prefix matters: FR routes sit under `/onboard/...` so the onboarding redirect whitelist applies pre-login. When adding a route, check `app_router.dart`'s redirect logic for which prefix gives the right auth gating.

## Passing parameters

| Pattern | Use for |
|---|---|
| `state.uri.queryParameters['key']` | Scalars (IDs, flags) — REQUIRED for deeplink entries |
| `state.extra as SomeType` | Complex objects between in-app screens |
| `state.pathParameters['key']` | Path segments |

Typed extra convention — wrap in a dedicated class so casts are checked:

```dart
class FaceRecognitionRouteExtra {
  const FaceRecognitionRouteExtra({required this.frActionsResult});
  final FrActionsResult frActionsResult;
}

// in the GoRoute builder: tolerate a missing/wrong extra, fall back safely
final extra = state.extra;
final routeExtra = extra is FaceRecognitionRouteExtra ? extra : null;
if (routeExtra == null) return const FrTutorialScreen(); // never crash on bad entry
```

## Programmatic navigation

```dart
// from a service/controller
ref.read(goRouterProvider).goNamed(AppRouter.home.name);

// module entry honouring ModuleEntryMode (push vs replace)
ref.read(goRouterProvider).enterModule(SampleModuleRouter.home.name, entryMode);
```

`goRouterProvider` is keepAlive in `lib/src/router/app_router.dart`. Module routes are registered through `lib/src/router/module_registry.dart` — see [module-launcher.md](module-launcher.md).

## Recap

1. Enum + `TndsRouter`; navigate by `.name`, never raw paths.
2. Deeplinks: queryParameters only.
3. Route builders never crash on missing extras — fall back to a safe screen.
4. Services navigate via `goRouterProvider`.
