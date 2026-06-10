# JSON Serialization Rules

> Full rules: [.claude/skills/tnds-flutter-app/references/data-layer.md](../skills/tnds-flutter-app/references/data-layer.md) — read before writing DTOs or repository mappings.

Non-negotiables:

- json_serializable only — **no freezed**. Every DTO has a `fromJson` factory and `toJson()`; `@JsonKey(name:)` when wire names differ; `explicitToJson: true` (or the shared `@jsonSerializableOmitNullsExplicit` preset) for nested DTOs.
- DTOs live in `features/<name>/data/dto/{request,response}/`; repositories map DTO → domain noun and DTOs never leak past the data layer.
- Run `rps gen build` after modifying any `@JsonSerializable` class.
