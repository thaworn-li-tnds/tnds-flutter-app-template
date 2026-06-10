# Module Launcher Rules

> Full rules: [docs/claude-skill/tnds-flutter-app/references/module-launcher.md](../../docs/claude-skill/tnds-flutter-app/references/module-launcher.md) — read before touching any launchable module. Scaffold new modules with the bundled `add-module` skill.

Non-negotiables:

- Never hand-roll the module lifecycle — build on the three shared rails: `ModuleControllerMixin<P, R>`, `loadWhenSessionReady<T>()`, `ModuleLauncherBase<P, R>` (+ `ModuleScaffold` for the entry screen only); register in `lib/src/router/module_registry.dart`.
- `Module` in a class name = module-control only (`<Feature>ModuleLauncher` / `ModuleController` / `ModuleService`); screens, content controllers, repositories, domain stay plain.
- Module controller holds session/lifecycle state only (`ModuleSession`); per-screen content lives in auto-disposed screen controllers gated by `loadWhenSessionReady`.
- Exactly one terminal result (`onCompleted` / `onCancelled` / `onFailed`); screens are passive — `controller.complete()` only, never self-pop; launch params go through the `ModuleLaunchContext.args` bag.
- Reference implementation: `features/sample_module/`. `authentication/auth_module` is an orchestrator — exempt; do not copy its internals.
