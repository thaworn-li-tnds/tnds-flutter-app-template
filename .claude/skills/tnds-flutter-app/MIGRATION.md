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

- **Home widget tests skipped** (`test/src/features/home/home_screen_test.dart`): `Robot.pumpTestWidget` hangs in this fresh project — suspect EasyLocalization initialization or a never-settling `pumpAndSettle`. Controller tests run fine. Fix the Robot bootstrap, then remove `skip: true`.

## Definition of done per batch (when debt exists)

1. The violating pattern is deleted (not deprecated-and-kept) after call sites move.
2. `rps gen build` + `rps analyze` clean; `rps test` passes.
3. Tests for the touched screens converted to Robot-only in the same PR.
