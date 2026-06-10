# Dio Client Selection Rules

> Full rules: [docs/claude-skill/tnds-flutter-app/references/dio-clients.md](../../docs/claude-skill/tnds-flutter-app/references/dio-clients.md) — MUST read before wiring any new repository's Dio.

Non-negotiables:

- A new repository's Dio client (`mymoMsDio` / `viperaDio` / `viperaAppSaltDio` / `cdnDio` / `viperaConfigDio`) is a backend crypto contract — it CANNOT be inferred from the API spec and must be **confirmed with the user via AskUserQuestion**. Never copy a neighboring repo's choice.
- `viperaDio` = dynamic session salt (key follows login state — most feature APIs, re-launchable modules). `viperaAppSaltDio` = fixed app salt (session-independent, e.g. app-protection logging only). The deciding question is the backend's decrypt key, not the screen's position in the flow.
- Record a one-line comment on the provider when the choice is non-obvious.
