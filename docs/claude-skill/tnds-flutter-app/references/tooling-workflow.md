# Tooling & Workflow

## Trigger

Signals: build_runner, rps, codegen, flavor, entry point, ENVIRONMENT, analyze, test command, pre-push, pubspec scripts, running the app
Before generating code in this area, output verbatim: `Reading: tooling-workflow.md`

## Rules — NEVER Violate

1. **Use RPS commands** (`scripts:` in `pubspec.yaml`, run via `rps <name>`) — don't improvise raw flutter invocations when an RPS script exists.
2. **Run `rps gen build` after ANY change** to `@riverpod`, `@Riverpod`, or `@JsonSerializable` annotations. New annotated files need `part '<file>.g.dart';`.
3. **Every app run needs matching `--flavor` AND `--dart-define=ENVIRONMENT=<env>`** — `main.dart` reads `ENVIRONMENT` to pick `.env.<env>` and Firebase options.
4. **Never add/upgrade packages** without explicit user approval — this skill never introduces new libraries (no freezed, no hive, no new lint plugins).
5. If the pre-push hook fails, fix the underlying issue — never bypass with `--no-verify`.

## RPS commands

```sh
rps install                 # flutter pub get
rps gen build               # build_runner build --delete-conflicting-outputs
rps gen code                # build_runner watch (during development)
rps gen lang                # regenerate LocaleKeys (tool/gen_locale_keys.dart)
rps gen splash              # native splash
rps analyze                 # flutter analyze
rps format                  # dart format .
rps fix                     # dart fix --apply
rps test                    # flutter test (clears libCachedImageData first, --fail-fast)
rps cov                     # coverage + filtered HTML report
rps cov_one_file <path>     # coverage for one file
rps integration_test <path> # integration test, dev flavor
```

Flutter is pinned to **3.41.6 via FVM** (`.fvmrc`) — prefix with `fvm` (`fvm flutter ...`) or have 3.41.6 installed directly.

## Entry points × environments

| Entry point | Bootstrap | Use |
|---|---|---|
| `lib/main.dart` | `app_bootstrap_api.dart` | Real backend |
| `lib/main_fake_api.dart` | `app_bootstrap_fakes_api.dart` | Fake repositories — offline/UI work |
| `lib/main_test.dart` | `app_bootstrap_test.dart` | Test harness |

Environments (each with `.env.<env>`): `dev`, `sit`, `uat`, `production`, `specialProduction` (+ `.env.test` for tests). Launch configs pre-wired in `.vscode/launch.json` (incl. `dev(fake_api)`, `sit(fake_api)`).

```sh
flutter run --flavor dev --dart-define=ENVIRONMENT=dev -t lib/main.dart
flutter run --flavor dev --dart-define=ENVIRONMENT=dev -t lib/main_fake_api.dart
```

## Bootstrap chain

`main.dart` → dotenv + Firebase for the env → `AppBootstrap.createApiProviderContainer()` → Riverpod `ProviderContainer` with overrides from `getBaseProvider()` (`app_base_provider.dart` — also where `module_registry.dart` overrides are injected) → `createRootWidget()` wires `EasyLocalization` + `MyApp`. Error handlers registered in `AppBootstrap.registerErrorHandlers` (see [error-handling.md](error-handling.md)).

## Commit strategy

Message format (mandatory): `type(featureName): concise subject in imperative mood`

- **type**: `feat` / `fix` / `refactor` / `chore` / `docs` / `test` / `perf` / `build`
- **featureName**: camelCase short scope (`recipient`, `transferFlow`); first line ≤ ~72 chars; body explains what + why.

Split rules when planning commits (see the companion skill `skills/commit-plan-from-diff/`):

- Keep a `.dart` file and its generated `.g.dart` in the **same** commit.
- Order commits dependency-first: DTOs/domain → repository + fakes → services → UI/controllers → routing → entry points → cleanup → tests.
- Small independent fixes get their own commit **before** the main feature; deletions come **after** the replacement exists.
- Never bury an unrelated fix inside a feature commit.

## Fixing analyzer errors

Workflow (see the companion skill `skills/fix-analysis/`): run `rps analyze` → `dart fix --apply` for mechanical lints → classify what remains → fix file-by-file in dependency order (domain → data → application → presentation) → re-run analyze (max 3 rounds, then report).

| Bucket | Examples | Strategy |
|---|---|---|
| Missing const | `prefer_const_constructors` | Add `const` (only when all args are const) |
| Unused | `unused_import`, `unused_local_variable` | Delete |
| Quote style | `prefer_single_quotes` | `"..."` → `'...'` |
| Null safety | `unnecessary_null_check` | Remove the check |
| Type errors | `argument_type_not_assignable` | Read the file first; minimal change; skip+report if it needs business context |
| Architecture | `ref.watch` in callback, raw `context.go('/')`, `print(` | Fix per the relevant reference file |
| Codegen stale | `undefined_identifier` on generated types | STOP — run `rps gen build`, then re-analyze (never hand-fix) |

## Branching (git flow)

Long-lived branches: `master`, `develop`, `release/*`. Feature branches are cut from `develop` (`feature/sprintN/...`); hotfixes from `master`; PRs target the corresponding `release/*` branch. Details + diagrams: `docs/git/git-flow.md`.

Optional commit trailer when the work maps to a Jira story: `Ref: MSME-XXXX` on the last body line.

## Pre-push hook (`.husky/pre-push`)

- Always: `flutter analyze` + `build_runner build`.
- Additionally `flutter test` on `release/*`, `develop`, `main`.

## Known tooling caveat — custom_lint is a no-op here

The project's `tool/lint_rules` boundary rules silently do NOT fire under the pub workspace setup. Do not rely on custom_lint to catch layer violations, and do not wire it into CI expecting enforcement — the rules in this package plus `rps analyze` are the working gate.

## Definition of done for any code change

1. `rps gen build` (if annotations/DTOs touched) — committed `.g.dart` in sync.
2. `rps analyze` exits clean.
3. Tests for touched `application/`/`presentation/` logic (see [testing.md](testing.md)); `rps test` passes.
4. `rps format` applied.

## Recap

1. RPS for everything; FVM-pinned Flutter.
2. flavor + ENVIRONMENT always together; fake_api entry for offline work.
3. gen build → analyze → test → format before yielding.
