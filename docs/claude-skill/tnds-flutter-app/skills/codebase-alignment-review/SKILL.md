---
name: codebase-alignment-review
description: >
  Use when the user wants to review whether code aligns with the project's patterns,
  or asks to check naming conventions, layer placement, hardcoded sizes, or widget reuse.
  Triggers on: alignment review, code review pattern, check convention,
  check naming, hardcoded size, can we reuse a widget
allowed-tools: Bash, Read
---

# Codebase Alignment Review

Review code against **existing nearby patterns**, not ideal architecture.

## Step 1: Scope

1. Identify files under review (changed files, or files the user names).
2. If no files specified, run `git diff --name-only` to find them.
3. For each file, find **one** nearby reference file doing the same job. Read it.
4. If no reference found, ask the user before reviewing.

**Hard rule:** Review only target files. Do not review unrelated files.

## Step 2: Check (11 items)

Read [../../references/](../../references/) for the full rule set before reviewing.

| # | Check | Pass when |
|---|-------|-----------|
| 1 | **Layer placement** | `*_controller.dart` in `presentation/`; `*_service.dart` in `application/`; `*_screen.dart` in `presentation/`; domain files in `features/<name>/domain/`. UI has no repo/service logic. Controller has no rendering. |
| 2 | **Domain purity** | Domain files have zero imports from `flutter`, `riverpod`, `dio`, or platform packages. Pure Dart only. |
| 3 | **Cross-feature imports** | No feature imports from another feature's `presentation/` or `application/`. Shared concerns go through `lib/src/shared/` or Riverpod providers. |
| 4 | **Naming match** | File name, class name, provider name follow suffix rules: `*_screen`, `*_service`, `*_controller`, `*_router`, `*_repository`, `fake_*`. |
| 5 | **Riverpod annotation** | `@Riverpod(keepAlive: true)` for repositories/singletons. `@riverpod` for per-screen controllers. `ref.watch` only in `build()`; `ref.read` in callbacks. Async screens use `AsyncValue.when`. |
| 6 | **Navigation** | All navigation uses enum-based named routes: `context.goNamed(SomeRouter.value.name)`. No raw string paths like `context.go('/path')`. |
| 7 | **Reuse** | Uses existing shared widgets (`lib/src/common_widgets`), theme extensions, `AppException` for errors. No `print()` statements. |
| 8 | **DTO and serialization** | `@JsonSerializable` with `fromJson`/`toJson`. No `freezed`. `explicitToJson: true` for nested DTOs. Errors are `AppException` subclasses. |
| 9 | **Widget conventions** | Sub-widgets extracted as `StatelessWidget` subclasses, not `Widget _buildX()` methods. `if (cond) Widget()` not `cond ? Widget() : SizedBox()`. `SizedBox` over `Container()` for spacing. |
| 10 | **No hardcoded sizes** | All sizing uses constants from `lib/src/constants/app_sizes.dart` (`Sizes.kP*`, `kGapH*`, `kGapW*`, `kRadius*`). Every violation gets its own row. |
| 11 | **Service layer** | Every repository access goes through a Service class ([service-layer.md](../../references/service-layer.md)). No `ref.read(*RepositoryProvider)` in `presentation/`; no `@riverpod` function provider calling a repository (legacy ones are listed in [MIGRATION.md](../../MIGRATION.md) — flag as note, but new ones are violations). |

## Step 3: Output

```
## Review: [feature or file name]

Reference file: `[path]`

### Findings

| # | Severity | File | Issue | Fix |
|---|----------|------|-------|-----|
| 1 | High/Med/Low | `path/to/file.dart:42` | [what is wrong] | [smallest fix] |

#### Hardcoded sizes (if any)

| # | File | Line | Hardcoded value | Suggested constant |
|---|------|------|-----------------|--------------------|
| 1 | `path` | 42 | `width: 80` | `Sizes.kP80` |

### Checklist

- [ ] Layer placement correct (`*_controller` in `presentation/`, not `application/`)
- [ ] Domain purity (no Flutter/Riverpod/Dio imports in `domain/`)
- [ ] No cross-feature imports
- [ ] Naming matches rules (`*_screen`, `*_service`, `*_controller`, `*_router`)
- [ ] Riverpod annotation correct (keepAlive vs auto-dispose)
- [ ] Navigation uses enum-based routes (no raw strings)
- [ ] Reuses existing widgets/helpers/errors (`AppException`, no `print()`)
- [ ] DTO serialization consistent (`@JsonSerializable`, no `freezed`)
- [ ] Widget conventions (StatelessWidget subclasses, no `_buildX()`, no SizedBox ternary)
- [ ] No hardcoded sizes
- [ ] Service layer (Controller → Service → Repository; no function providers calling repos)
```

Severity: High = layer violation, domain purity, cross-feature import · Medium = naming mismatch, wrong annotation, hardcoded size, raw navigation · Low = minor inconsistency

## Rules

1. Always read the reference file before reviewing.
2. Every File cell must include `:line` after the path.
3. Do not suggest rewrites — suggest the smallest change only.
4. Do not review files the user did not ask about.
5. Full project rules are in [../../references/](../../references/) — read the relevant file when a check needs detail.

## No Hardcoded Sizes Detail

Read `lib/src/constants/app_sizes.dart` at the start. Scan for raw numeric literals in:
`SizedBox`, `EdgeInsets`, `Padding`, `Container`, `BoxConstraints`, `BorderRadius`, `Radius.circular`, `width:`, `height:`, `minHeight:`, `minWidth:`, `maxHeight:`, `maxWidth:`

Constants: `Sizes.kP*` (values) · `kGapH*` (vertical SizedBox) · `kGapW*` (horizontal SizedBox) · `kRadius*` (border radius)

Exempt: `opacity`, `flex`, `maxLines`, `duration`, `aspectRatio`, `elevation`
