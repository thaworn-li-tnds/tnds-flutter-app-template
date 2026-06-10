# Testing Rules

> Full rules: [docs/claude-skill/tnds-flutter-app/references/testing.md](../../docs/claude-skill/tnds-flutter-app/references/testing.md) — read before writing any test.

Non-negotiables:

- Widget tests are **Robot-only**: every interaction/assertion via `Robot` (`test/src/robot.dart`) or a feature robot; a missing helper means extending the Robot, never calling `tester.*` / `find.*` in a test body.
- Fakes injected via `overrideRepos: [xRepositoryProvider.overrideWith(...)]` — never mock Riverpod providers directly; fakes live in `features/<name>/data/fake/`.
- Tests mirror `lib/src/` under `test/src/`; mocktail mocks live in `test/src/mocks.dart`.
- `CachedNetworkImage` tests need the sqflite-ffi temp-dir setUp recipe (in the reference); never `deleteDatabase` in `tearDown`. New native-plugin `MissingPluginException` → add the mock handler inside `pumpTestWidget`.
