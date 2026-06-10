# Migration Plan — Deviations from the Skill Standard

> This template starts with no legacy code, so there is no debt yet. Keep this
> file as the single ledger of known violations: when code that breaks a rule
> in [SKILL.md](SKILL.md) has to be merged (or is discovered), record it here
> with file paths and a grep recipe instead of silently replicating it.
>
> Review/scaffold skills reference this file — `review-uncommitted` and
> `codebase-alignment-review` report violations listed here as notes (known
> debt) rather than new findings, and `generate-api` forbids replicating them.

## A. Function providers calling repositories (violates Critical Rule 2)

None. Verify: `grep -rln "RepositoryProvider" lib/src/features/*/application --include="*_service.dart"`

## B. Presentation reading repository providers directly (violates Rules 1 + 2)

None. Verify: `grep -rln "RepositoryProvider" lib/src/features/*/presentation -r`

## C. Widget tests calling `tester.*` / `find.*` directly (violates Rule 11)

None. Verify: `grep -rln "await tester\.\|find\.byKey\|find\.text" test/src --include="*_test.dart"`

## D. Other known debt

- **No live launchable-module example in the tree** (2026-06-10): `features/sample_module/` was removed when the `expense` feature became the template's reference feature. The module rails stay in `lib/src/shared/application/` + `lib/src/shared/presentation/module_scaffold.dart`; the canonical module example is now the embedded snapshot in [references/module-launcher.md](references/module-launcher.md), and `add-module` scaffolds from it. Restore a live example with `add-module` if one is ever needed.

Resolved:

- The widget-test hang — `EasyLocalization.ensureInitialized()` awaited `SharedPreferences.getInstance()` inside the fake-async test zone — is fixed by `test/flutter_test_config.dart` initializing once outside it; all tests run un-skipped. Verify: `grep -rln "skip:" test/`

## Definition of done per batch (when debt exists)

1. The violating pattern is deleted (not deprecated-and-kept) after call sites move.
2. `rps gen build` + `rps analyze` clean; `rps test` passes.
3. Tests for the touched screens converted to Robot-only in the same PR.
