# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

**TNDS Flutter app template** — the foundation for new TNDS Flutter apps (any domain, not only banking). It carries the team's coding standard and Claude Code tooling; new apps start from this repo and build features on top. There is no application code yet — when scaffolding the project, follow the standard below from the first file.

## Project standard (authoritative)

The coding standard lives in **`.claude/skills/tnds-flutter-app/`** (the `tnds-flutter-app` skill). Before writing Dart code, follow its `SKILL.md` Critical Rules and read the matching `references/*.md` from its Trigger Map. Key rules that are easy to miss:

- **Controller → Service → Repository, always.** Every repository call goes through a Service class in `application/`; `@riverpod` function providers that call repositories are forbidden, and presentation never reads a `*RepositoryProvider`.
- **New repository ⇒ ask the user which Dio client** (crypto contract — see `references/dio-clients.md`).
- **Widget tests are Robot-only** — extend the Robot instead of calling `tester.*` in test bodies.

Guardrail summaries auto-load from `.claude/rules/` (slim pointers into the package — keep them thin; the package is the single source of truth).

Companion workflow skills (generate-api, add-module, add-locale-key, fix-analysis, commit-plan-from-diff, review-uncommitted, codebase-alignment-review) each live as their own top-level skill under `.claude/skills/`, alongside `tnds-flutter-app/`.

## Target stack (when scaffolding)

- **Flutter** pinned via FVM (`.fvmrc`); use `fvm flutter ...`.
- **State mgmt**: Riverpod + `riverpod_annotation` (codegen only, all `*.g.dart`).
- **Router**: `go_router` — central config in `lib/src/router/app_router.dart`, per-feature routes under `lib/src/features/<feature>/router/`, enum + `TndsRouter`-style mixin.
- **Serialization**: `json_serializable` — no freezed.
- **Localization**: `easy_localization` with generated locale keys.
- **Scripts**: RPS (`scripts:` in `pubspec.yaml`) — `rps gen build`, `rps analyze`, `rps test`, etc.

## Layout

Each feature under `lib/src/features/<name>/`:

```
<feature>/
├── application/      # Services (*_service.dart), module launchers & module services
├── data/             # Repositories, dto/{request,response}/, fake/
├── domain/           # Pure Dart nouns: entities/value objects + service-built read models (*Overview/*Summary/*Status)
├── presentation/     # Screens, widgets, controllers (*_controller.dart incl. *_module_controller.dart)
└── router/           # GoRoute definitions for this feature
```

Call chain: Controller (presentation) → Service (application) → Repository (data). Shared concerns in `lib/src/shared/`; reusable widgets in `lib/src/common_widgets/`; no cross-feature imports of another feature's `application/`/`presentation/`.

## Notes for this template

- The skill package was extracted from the MyMo SME app — code examples in `references/` cite that codebase (e.g. `ViperaBaseRepository`, `flutter_mymo_sme` imports) as the reference implementation until this template gets its own foundation code. The architecture rules apply as-is; adjust app-specific facts (backend/crypto in `dio-clients.md`, module factors) per product.
- `.claude/skills/tnds-flutter-app/MIGRATION.md` starts empty — it is the ledger for any future deviations from the standard; record violations there instead of replicating them.
- When starting a new app from this template: rename the app identifiers, then follow the `Adoption` section in the package `SKILL.md` if the skill needs to move.
