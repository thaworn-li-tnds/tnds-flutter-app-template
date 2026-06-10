---
name: generate-api
description: >
  Use when the user wants to scaffold a full new API layer for a new operation,
  or provides an operation name + request JSON + response JSON to scaffold.
  Triggers on: generate API, create DTO, create domain model, scaffold API stack,
  create repository method, create service, create new controller
allowed-tools: Bash, Read, Edit, Write
---

# Skill: Generate API Full Stack

Given **operationName**, **request JSON**, **response JSON**, and **feature/service name**,
generate every layer of the API stack.

## Step 0 – Gather Inputs

| Input | Example |
|---|---|
| `operationName` (camelCase) | `getProductList` |
| Feature / service name | `product` |
| Request JSON (or `"none"`) | `{ "pageSize": "10" }` |
| Response JSON (or `"void"`) | `{ "items": [...], "isLastPage": true }` |

If provided via `$ARGUMENTS`, parse in order: operationName, feature name, JSON samples.
If any input missing, ask before proceeding.

### JSON → Dart types

**Request**: all fields nullable (`String?`, `int?`) — omitted via `@jsonSerializableOmitNulls`

**Response**: nullable in DTO, non-nullable with defaults in Domain:
- `String` → domain `''`, DTO `String?`
- Amounts/balances → prefer `String` (not numbers)
- `bool` → domain `false`
- `List<object>` → nested class in domain + `{Item}Response` in DTO
- `List<primitive>` → `List<String>`, domain default `const []`

## Step 1 – Derive Names & Paths

- `operationSnake` = snake_case → `get_product_list`
- `OperationPascal` = PascalCase → `GetProductList`
- `featureSnake` / `FeaturePascal` from feature name

```
lib/src/features/{featureSnake}/domain/{operationSnake}.dart
lib/src/features/{featureSnake}/data/dto/request/{operationSnake}_request.dart
lib/src/features/{featureSnake}/data/dto/response/{operationSnake}_response.dart
lib/src/features/{featureSnake}/data/{featureSnake}_repository.dart
lib/src/features/{featureSnake}/data/fake/fake_{featureSnake}_repository.dart
lib/src/features/{featureSnake}/application/{featureSnake}_service.dart
lib/src/features/{featureSnake}/presentation/{operationSnake}_controller.dart
```

(Layout per [architecture-layers.md](../../references/architecture-layers.md); follow the feature's existing sub-folders if it deviates.)

## Step 2 – Domain Model

Plain Dart class, no annotations, all fields have **default values** (never nullable), `const` constructor.

**Domain purity rule:** Domain files must have zero imports from `flutter`, `riverpod`, `dio`, or any platform package. Pure Dart only. See [architecture-layers.md](../../references/architecture-layers.md).

## Step 3 – Request DTO

`@jsonSerializableOmitNulls`, all fields nullable, `fromJson`+`toJson`, `part '*.g.dart'`.
Skip entirely if request is `"none"`.

## Step 4 – Response DTO

`@JsonSerializable()`, all fields nullable, `to{Domain}` getter with null-coalescing defaults, `part '*.g.dart'`.

## Step 5 – Mock Data

`const mock{OperationPascal}Response` — realistic fake values (2–3 list items), keys match DTO field names.

## Step 6 – Repository Method

**If creating a NEW repository provider** (not adding a method to an existing one):
the injected Dio client (`mymoMsDio` / `viperaDio` / `viperaAppSaltDio`) CANNOT be
inferred from the spec — it is a crypto/session contract. You MUST ask the user to
confirm the client via `AskUserQuestion` before wiring the provider. See
[dio-clients.md](../../references/dio-clients.md). Do not copy whichever Dio a nearby
repo uses by default.

Add method to existing `{FeaturePascal}Repository` class. Pattern:
```dart
Future<{OperationPascal}> {operationName}({OperationPascal}Request request) async {
  const op = '{operationName}';
  final response = await postOp(op, data: request.toJson());
  return {OperationPascal}Response.fromJson(response.data).to{OperationPascal};
}
```

## Step 7 – Fake Repository

`Fake{FeaturePascal}Repository` **implements** (not extends) real class. Add `@override` method with `await delay(addDelay)`.

## Step 8 – Application Service (Service class — NEVER a function provider)

Add a method to the feature's existing `{FeaturePascal}Service` class; if the feature
has no Service class yet, create one per [service-layer.md](../../references/service-layer.md):

```dart
class {FeaturePascal}Service {
  {FeaturePascal}Service(this.ref);

  final Ref ref;

  {FeaturePascal}Repository get _repo => ref.read({featureCamel}RepositoryProvider);

  Future<{OperationPascal}> {operationName}({OperationPascal}Request request) =>
      _repo.{operationName}(request);
}

@riverpod
{FeaturePascal}Service {featureCamel}Service(Ref ref) => {FeaturePascal}Service(ref);
```

FORBIDDEN: `@riverpod Future<T> {operationName}(Ref ref)` top-level function providers
calling the repository — the legacy files that still contain them are listed in
[MIGRATION.md](../../MIGRATION.md); never add new ones, even into those files.

## Step 9 – Controller

Calls the **service method** (never the repository, never a function provider).
Choose variant based on the operation type:

| Variant | When to use | `build()` | Action method |
|---|---|---|---|
| **9a** Read/Fetch | Screen loads data automatically on entry | calls service method → `AsyncValue<T>` | none |
| **9b** Submit | User fills a form and taps a button | returns `null` (idle) | `submit()` sets loading + guard |
| **9c** Void | Fire-and-forget trigger (e.g. log event) | `void` | `submit()` awaits service, no return |

```dart
// 9a — Read/Fetch
@riverpod
class {OperationPascal}Controller extends _${OperationPascal}Controller {
  @override
  Future<{OperationPascal}> build() =>
      ref.read({featureCamel}ServiceProvider).{operationName}(request);
}

// 9b — Submit
@riverpod
class {OperationPascal}Controller extends _${OperationPascal}Controller {
  @override
  Future<{OperationPascal}?> build() async => null;

  Future<void> submit({OperationPascal}Request request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read({featureCamel}ServiceProvider).{operationName}(request),
    );
  }
}
```

**9c** Void (fire-and-forget): `build()` is void, `submit()` awaits the service method.

## Step 10 – Remind Code Generation

```bash
rps gen build
# or: dart run build_runner build --delete-conflicting-outputs
```

## Quality Checklist

- [ ] Domain: no nullable fields, all have defaults, zero Flutter/Riverpod/Dio imports
- [ ] Request DTO: all nullable, `@jsonSerializableOmitNulls`
- [ ] Response DTO: `to{Domain}` uses `?? ''`, `?? false`, `?? []` (not `?? 0` for amounts)
- [ ] Mock data keys match DTO JSON field names
- [ ] Fake: `implements` (not `extends`), uses `await delay(addDelay)`
- [ ] Repository provider: `@Riverpod(keepAlive: true)` — keepAlive for data-layer singletons
- [ ] Service: method on the `{FeaturePascal}Service` class — NO `@riverpod` function provider calling the repository
- [ ] Controller calls the service method, never `{featureCamel}RepositoryProvider`
- [ ] Controller provider: `@riverpod` (auto-dispose) — freed when screen pops
- [ ] Controller placed in `presentation/` not `application/`
- [ ] No cross-feature imports in presentation/application layers
- [ ] `part '*.g.dart'` in every annotated file — no `freezed` in this project
- [ ] Errors use `AppException` subclasses — not raw `Exception`
- [ ] If generating UI: widgets extracted as `StatelessWidget` subclasses, not `_buildX()` methods
- [ ] User reminded to run `rps gen build`
