# Architecture & Layer Isolation

> Full rules: [.claude/skills/tnds-flutter-app/references/architecture-layers.md](../skills/tnds-flutter-app/references/architecture-layers.md) and [service-layer.md](../skills/tnds-flutter-app/references/service-layer.md) — read before placing files or wiring layers.

Non-negotiables:

- Dependency direction `Presentation → Application → Domain ← Data`; domain is pure Dart (no flutter/riverpod/dio imports).
- Call chain is **Controller → Service → Repository** — every repository call goes through a Service class in `application/`; presentation never imports `data/` or reads a `*RepositoryProvider`; `@riverpod` function providers calling repositories are forbidden (legacy ones: see the package `MIGRATION.md`, do not replicate).
- Feature layout: `features/<name>/{application, data{dto,fake}, domain, presentation, router}`.
- No cross-feature imports of another feature's `application/` or `presentation/` — shared concerns live in `lib/src/shared/`, cross-module wiring only at `lib/src/router/module_registry.dart`.
