# Localization

## Trigger

Signals: user-facing string, LocaleKeys, translation, `.tr()`, ARB-like JSON, easy_localization, th/en, hardcoded text
Before generating code in this area, output verbatim: `Reading: localization.md`

## Rules — NEVER Violate

1. **Every user-facing string is `LocaleKeys.<key>.tr()`** (easy_localization). No bare string literals in UI, exceptions, enum display names, or snackbar text.
2. **A temporarily-unlocalized string MUST be marked `.hardcoded`** (`lib/src/localization/string_hardcoded.dart`) so it is greppable for cleanup. Bare literals without the marker are violations.
3. **`lib/generated/locale_keys.g.dart` is generated** by `tool/gen_locale_keys.dart` — never hand-edit. Regenerate with `rps gen lang` after editing translation JSON.
4. **Translations are remote-loaded at runtime** via `RemoteAssetLoader` (`lib/src/utils/remote_asset_loader.dart`) from the CDN. A key added locally must also exist in the server-side translation files — **flag this to the user on every new key**; a locally-added key that is missing remotely silently falls back.
5. Supported locales: `th`, `en`. Both JSON trees under `assets/translations/{th,en}/` must receive every new key.

## Key generation model

`tool/gen_locale_keys.dart` reads every JSON file in `assets/translations/th/`, flattens nested maps with dot notation, prefixes the filename, and emits constants:

```
common.json  { "camera": { "title": "..." } }
→ static const common_camera_title = 'common.camera.title';
```

Usage:

```dart
Text(LocaleKeys.transfer_schedule_order_status_success.tr())

// with args / plurals per easy_localization
Text(LocaleKeys.home_greeting.tr(args: [username]))
```

Exception classes take LocaleKeys-resolved titles/descriptions (see `lib/src/exceptions/app_exception.dart`) so error UI is localized for free — pass `.tr()` results into `AppException` constructors, not raw text.

## Adding a new string — checklist

(Automated by the companion skill `skills/add-locale-key/`.)

1. Add the key to `assets/translations/th/<file>.json` AND `assets/translations/en/<file>.json` — **always both in one step**; `rps gen lang` reads only `th/`, so `en/` stays in sync only by discipline. If no English copy exists yet, mirror the Thai text.
2. Insert at the correct nesting level (dot path `tutorial.title` → inside the `"tutorial"` object; create the object if missing). Keep alphabetical order within a level when the file uses it; match the file's 2-space indentation. A new feature file means creating both `th/<file>.json` and `en/<file>.json`.
3. Run `rps gen lang` → constant named `{file}_{key_path_with_underscores}` (e.g. `fr.json` + `tutorial.confirm_button` → `LocaleKeys.fr_tutorial_confirm_button`).
4. Use `LocaleKeys.x.tr()` at the call site.
5. **Tell the user** the key must be added to the remote/CDN translation source before release.

## Temporary strings

```dart
// acceptable mid-development — explicitly marked, greppable
Text('MyMoSME'.hardcoded)
```

`grep -rn "\.hardcoded" lib/src/` is the cleanup backlog. Never use `.hardcoded` to dodge localization on a string that ships.

## In tests

The Robot pumps `EasyLocalization` with `CustomAssetLoader` (a local mock loader in `test/src/mocks.dart`) — translated lookups resolve to keys/fixtures, so tests assert on keys or fixture text, not production copy. See [testing.md](testing.md).

## Recap

1. `LocaleKeys.x.tr()` or `.hardcoded` — nothing else.
2. Both locales + `rps gen lang` + remind the user about the remote source.
3. Never edit `locale_keys.g.dart`.
