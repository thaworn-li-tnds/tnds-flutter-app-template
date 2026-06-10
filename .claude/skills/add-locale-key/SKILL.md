---
name: add-locale-key
description: >
  Add one or more locale keys to the correct translation JSON files (th/ and en/)
  then regenerate locale_keys.g.dart. Triggers on: add locale key, add translation,
  add locale, เพิ่ม locale, เพิ่ม translation, add text key, add string key
allowed-tools: Bash, Read, Edit
---

# Skill: Add Locale Key

Add keys to `assets/translations/th/<file>.json` and the matching `en/<file>.json`,
then run `rps gen lang` to regenerate `lib/generated/locale_keys.g.dart`.

---

## Step 0 — Parse Arguments

From `$ARGUMENTS`, extract:

| Input | Example |
|---|---|
| Feature file name (without `.json`) | `fr`, `transfer`, `common` |
| Key path (dot-separated) | `tutorial.title`, `error.retry_button` |
| Thai text | `"ยืนยัน"` |
| English text | `"Confirm"` — or `"same"` if same as Thai |

If not enough info is provided, ask before continuing.

Multiple keys can be added in one call — accept them as a list.

---

## Step 1 — Read Existing JSON

Read both files in parallel:

```bash
cat assets/translations/th/<file>.json
cat assets/translations/en/<file>.json
```

Find the correct nesting level for the key path. For `tutorial.title`:
- Navigate to the `"tutorial"` object
- Insert `"title": "<value>"` inside it
- If the `"tutorial"` object doesn't exist yet, create it

---

## Step 2 — Insert Key

Edit **both** files — `th/` and `en/` — in the same step.

Rules:
- Maintain alphabetical order within the same nesting level if the existing file uses it
- Use 2-space indentation (match the file's existing indentation)
- Trailing comma on the last entry is not used in JSON — but do add a comma after the new entry if there are entries after it

For `"same"` English text: copy the Thai value verbatim (same as existing pattern in this codebase — `en/` mirrors `th/` for Thai-only content).

**Example — adding `tutorial.confirm_button: "ยืนยัน"` to `fr.json`:**

Before (th):
```json
{
  "tutorial": {
    "title": "ยืนยันตัวตนด้วยใบหน้า",
    "scan_button": "สแกนใบหน้า"
  }
}
```

After (th + en):
```json
{
  "tutorial": {
    "title": "ยืนยันตัวตนด้วยใบหน้า",
    "confirm_button": "ยืนยัน",
    "scan_button": "สแกนใบหน้า"
  }
}
```

---

## Step 3 — Regenerate Locale Keys

```bash
rps gen lang
```

This runs `dart run tool/gen_locale_keys.dart` and overwrites `lib/generated/locale_keys.g.dart`.

If `rps` is not installed, fall back to:
```bash
dart run tool/gen_locale_keys.dart
```

---

## Step 4 — Show Generated Constant

The generated constant name follows: `{file}_{key_path_with_underscores}`

| File | Key path | Generated constant |
|---|---|---|
| `fr.json` | `tutorial.confirm_button` | `LocaleKeys.fr_tutorial_confirm_button` |
| `common.json` | `ok_button` | `LocaleKeys.common_ok_button` |
| `transfer.json` | `error.insufficient_balance` | `LocaleKeys.transfer_error_insufficient_balance` |

Report to the user:

```
✅ Locale key added

Key path:  fr.tutorial.confirm_button
Thai:      ยืนยัน
English:   ยืนยัน

Use in code:
  LocaleKeys.fr_tutorial_confirm_button.tr()

Files updated:
  assets/translations/th/fr.json
  assets/translations/en/fr.json
  lib/generated/locale_keys.g.dart  (regenerated)
```

---

## Notes

- **Always update both `th/` and `en/`** in one step — never update one without the other.
- `lib/generated/locale_keys.g.dart` is generated — never hand-edit it.
- If the feature file doesn't exist yet (e.g. `assets/translations/th/foo.json`), create both `th/foo.json` and `en/foo.json` with the new key before running `rps gen lang`.
- Key paths use dot notation in JSON (`"tutorial.title"`) but underscore in Dart (`LocaleKeys.fr_tutorial_title`).
- `rps gen lang` reads only from `th/` — `en/` must be kept in sync manually (this skill handles that).
