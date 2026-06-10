# Error Handling Rules

> Full rules: [.claude/skills/tnds-flutter-app/references/error-handling.md](../skills/tnds-flutter-app/references/error-handling.md) — read before writing try/catch or error UI.

Non-negotiables:

- All errors are `AppException` subclasses; `AppException.parse(error, stackTrace)` is the single translation entry point.
- Controllers use `AsyncValue.guard()` for async mutations — never bare try/catch that hides errors from `.when(error:)`.
- `actionCode == EXIT_FLOW` (and other `ActionCodeType`s) handled at controller/service level, never in widgets.
- No `print()` in `lib/src/`; errors route to `ErrorLogger` (→ Crashlytics); never swallow errors silently.
