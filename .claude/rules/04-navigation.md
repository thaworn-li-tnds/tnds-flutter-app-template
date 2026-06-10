# Navigation Rules

> Full rules: [docs/claude-skill/tnds-flutter-app/references/navigation.md](../../docs/claude-skill/tnds-flutter-app/references/navigation.md) — read before adding routes or navigating.

Non-negotiables:

- Enum-based navigation only: `context.goNamed(XRouter.y.name)` via an enum `with MymoRouter` — never raw path strings.
- Deeplink entry routes pass params via `queryParameters` only (`extra` is lost on re-entry).
- Programmatic navigation from services/controllers via `ref.read(goRouterProvider)`.
