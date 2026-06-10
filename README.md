# TNDS Flutter App Template

Foundation for new TNDS Flutter apps. Carries the team's coding standard, architecture conventions, and Claude Code tooling. New apps start from this repo and build features on top.

## What's included

- **Architecture standard** — Controller → Service → Repository layering with full Riverpod codegen, concrete repositories, and encrypted Dio clients
- **Feature scaffold** — per-feature layout (`application/`, `data/`, `domain/`, `presentation/`, `router/`)
- **Launchable module framework** — `ModuleControllerMixin`, `ModuleLauncherBase`, `ModuleScaffold` rails
- **Claude Code skills** — AI-assisted code generation, review, and alignment checks wired into `.claude/`

## Target stack

| Concern | Choice |
|---|---|
| Flutter version | FVM (`.fvmrc`) |
| State management | Riverpod + `riverpod_annotation` (codegen only) |
| Router | `go_router` with enum + `TndsRouter` mixin |
| Serialization | `json_serializable` (no freezed) |
| Localization | `easy_localization` with generated locale keys |
| Scripts | RPS (`rps gen build`, `rps analyze`, `rps test`) |

## Feature layout

```
lib/src/features/<name>/
├── application/      # Services, module launchers/controllers
├── data/             # Repositories, dto/{request,response}/, fake/
├── domain/           # Pure Dart models (nouns)
├── presentation/     # Screens, widgets, controllers
└── router/           # GoRoute definitions
```

Call chain: **Controller → Service → Repository**. Shared concerns in `lib/src/shared/`; reusable widgets in `lib/src/common_widgets/`.

## Starting a new app

1. Clone this repo and rename the app identifiers.
2. Run `fvm flutter pub get`.
3. Use the bundled Claude Code skills to scaffold features:
   - `/add-module` — scaffold a complete launchable module
   - `/generate-api` — scaffold a full API layer (DTO → repository → service)
   - `/add-locale-key` — add translation keys
   - `/fix-analysis` — auto-fix lint errors

## Coding standard

Full rules live in [`docs/claude-skill/tnds-flutter-app/`](docs/claude-skill/tnds-flutter-app/). Key non-negotiables:

- Presentation never imports `data/` or reads a `*RepositoryProvider`.
- `@riverpod` function providers that call repositories are forbidden.
- New repository → ask which Dio client (backend crypto contract, cannot be inferred).
- Widget tests are Robot-only — never call `tester.*` / `find.*` in a test body.
- `json_serializable` only — no freezed.

See [`CLAUDE.md`](CLAUDE.md) for Claude Code–specific guidance.
