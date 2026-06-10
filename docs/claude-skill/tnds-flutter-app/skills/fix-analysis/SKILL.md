---
name: fix-analysis
description: >
  Run flutter analyze, auto-apply dart fixes, then manually fix remaining errors
  by reading and editing the affected files. Triggers on: fix analysis, fix errors,
  flutter analyze, fix lint, analyze errors, แก้ analyze, ผ่าน analyze
allowed-tools: Bash, Read, Edit, TodoWrite
---

# Skill: Fix Analysis

Run `fvm flutter analyze`, reduce errors as far as possible, report what remains.

---

## Step 1 — Set Scope

If `$ARGUMENTS` contains a path, analyze only that path. Otherwise analyze the whole project.

```bash
# Whole project:
fvm flutter analyze

# Specific path:
fvm flutter analyze lib/src/features/foo/
```

Count the total errors/warnings from the output. If **0 issues** → report clean and stop.

---

## Step 2 — Auto-fix With dart fix

Run `dart fix --apply` to resolve simple lint issues automatically:

```bash
dart fix --apply
```

Then re-run analyze on the same scope and count again. Report how many were resolved.

---

## Step 3 — Classify Remaining Errors

Parse the analyze output. Group errors into buckets:

| Bucket | Examples | Fix strategy |
|---|---|---|
| **Missing const** | `prefer_const_constructors`, `prefer_const_literals_to_create_immutables` | Add `const` keyword |
| **Unused** | `unused_import`, `unused_local_variable`, `unused_element` | Delete the import/variable |
| **Quote style** | `prefer_single_quotes` | Change `"..."` to `'...'` |
| **Null safety** | `unnecessary_null_check`, `unnecessary_null_comparison` | Remove the check |
| **Type error** | `argument_type_not_assignable`, `return_of_invalid_type` | Fix type — read file first |
| **Missing override** | `must_call_super`, `missing_return` | Add missing code |
| **Architecture** | `ref.watch` in callback, raw `context.go('/')`, `print(` in lib/src/ | Fix per [../../references/](../../references/) |
| **Codegen stale** | `undefined_identifier` on generated types, `part` directive missing | Run `rps gen build` |

---

## Step 4 — Fix In Dependency Order

Fix errors **file by file**, in dependency order (domain → data → application → presentation).
For each error:

1. Read the affected file
2. Apply the fix (Edit tool)
3. Do NOT re-run analyze after every single file — batch fixes first

**Per-bucket fix rules:**

### Missing const
Add `const` before the constructor call. Only add `const` when ALL arguments are also const.

### Unused import
Delete the entire `import '...';` line.

### prefer_single_quotes
Change every `"string"` → `'string'` in the affected lines. Escape any internal single quotes with `\'`.

### Architecture violations (per [../../references/](../../references/))
- `ref.watch` in callback → move to `build()` or use `ref.read`
- Raw `context.go('/path')` → replace with `context.goNamed(SomeRouter.value.name)`
- `print(` → delete the line (no logging replacement unless the context is an error)
- Widget `_buildX()` method → extract to `StatelessWidget` subclass

### Codegen stale
Do NOT attempt to fix. Instead stop and tell the user:
```
⚠️ Errors suggest *.g.dart files are out of date.
Run `rps gen build` first, then re-run /fix-analysis.
```

### Type errors / missing return
Read the full file to understand context before editing. Apply the minimal change.
If the fix requires understanding business logic → report it and skip (don't guess).

---

## Step 5 — Re-run Analyze

After all edits, re-run analyze on the same scope:

```bash
fvm flutter analyze [<path>]
```

If errors remain → repeat Step 3–5 up to **2 more rounds**. After 3 rounds total, stop and report what's left.

---

## Step 6 — Report

```
## Analysis Result

**Before:** {n} issue(s)
**After dart fix:** {n} issue(s) (−{delta} auto-fixed)
**After manual fixes:** {n} issue(s) (−{delta} manually fixed)

### Fixed
- `path/to/file.dart:12` prefer_const_constructors → added const
- `path/to/file.dart:34` unused_import → removed import

### Remaining (needs attention)
| File | Line | Error | Reason skipped |
|---|---|---|---|
| `path/to/file.dart` | 88 | argument_type_not_assignable | requires business logic decision |

### Next steps
- [ ] Fix remaining {n} error(s) manually
- [ ] Run `rps gen build` if any were codegen-related
```

If **0 remaining** → show:
```
✅ flutter analyze clean — {total_fixed} issue(s) resolved
```

---

## Notes

- Never edit `*.g.dart` or `*.freezed.dart` files — they are generated.
- `analysis_options.yaml` excludes `lib/**.g.dart` and `lib/**.freezed.dart` — don't worry about errors in those.
- `prefer_single_quotes` is enforced in this project — fix it when encountered.
- `avoid_print` is set to `false` in `analysis_options.yaml` — do NOT flag `print()` as a lint error (it's allowed by the linter, but rule 06 still forbids it in `lib/src/` — that's a code-review concern, not an analyze error).
- If the scope is a single file and it has 0 errors, say so clearly — don't re-run on the whole project.
