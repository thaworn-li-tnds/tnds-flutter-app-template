# File Naming Conventions

> Full rules: [.claude/skills/tnds-flutter-app/references/naming-conventions.md](../skills/tnds-flutter-app/references/naming-conventions.md) — read before creating or renaming files/classes.

Non-negotiables:

- File suffix encodes the layer: `*_screen.dart` / `*_controller.dart` → `presentation/`; `*_service.dart` → `application/`; `*_repository.dart` + `dto/{request,response}/` + `fake_*.dart` → `data/`; `*_router.dart` → `router/`; never hand-edit `*.g.dart`.
- Domain models are **nouns** — no verb prefixes (`GetXxx`, `FetchXxx`). The operation name belongs to the repository method and the DTO.
- `Module` in a class name marks module-control machinery only (launcher / session controller / lifecycle service).
