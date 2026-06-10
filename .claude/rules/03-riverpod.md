# Riverpod Rules

> Full rules: [.claude/skills/tnds-flutter-app/references/riverpod-state.md](../skills/tnds-flutter-app/references/riverpod-state.md) and [service-layer.md](../skills/tnds-flutter-app/references/service-layer.md) — read before writing providers or controllers.

Non-negotiables:

- Codegen only (`@riverpod` / `@Riverpod(keepAlive: true)` + `part '*.g.dart'`); never manual `Provider(...)` variants; run `rps gen build` after annotation changes.
- `keepAlive` = Dio/repositories/storage/router/module session controllers; auto-dispose `@riverpod` = screen controllers and services.
- `ref.watch` in `build()` only; `ref.read` in callbacks; `ref.listen` for side effects.
- Data access goes through the Service class — **no `@riverpod Future<T> getXxx(Ref ref)` function providers that call repositories** (legacy ones listed in the package `MIGRATION.md`; never add new ones).
- Screens render remote data via `AsyncValue.when` / `SystemAsyncValueWidget`; no `StatefulWidget` for server state.
