# Data Layer — Repositories, DTOs, Fakes

## Trigger

Signals: repository, DTO, `@JsonSerializable`, `fromJson` / `toJson`, `postOp`, domain model, fake repository, new API operation
Before generating code in this area, output verbatim: `Reading: data-layer.md`

## Rules — NEVER Violate

1. **Repositories are concrete classes** extending `ViperaBaseRepository` (or wrapping `mymoMsDio` directly for MS APIs), exposed by a `@Riverpod(keepAlive: true)` provider. **No abstract interfaces** — the provider override is the test/fake seam (project decision; do not "improve" this with interfaces).
2. **Before wiring a new repository's Dio client, STOP and read [dio-clients.md](dio-clients.md)** — the client choice is a backend crypto contract and MUST be confirmed with the user.
3. **json_serializable only — NO freezed.** Every DTO has a `fromJson` factory and `toJson()`; `@JsonKey(name: ...)` whenever the wire name differs; `explicitToJson: true` when a DTO nests other DTOs.
4. **Repositories map DTO → domain inside the repository method** and return domain models (nouns). DTOs never leak past the data layer.
5. **No business logic in repositories** — request building, `postOp`, response parsing, domain mapping. That's all.
6. Every repository gets a fake in `data/fake/fake_<x>_repository.dart` for `main_fake_api.dart` and tests.
7. After modifying any `@JsonSerializable` class, run `rps gen build`.

## ViperaBaseRepository contract

`lib/src/shared/data/remote/vipera_base_repository.dart` (complete):

```dart
abstract class ViperaBaseRepository {
  final Dio _dio;
  final String _srv;

  ViperaBaseRepository(this._dio, this._srv);

  Future<Response<T>> postOp<T>(
    String op, {
    Map<String, dynamic>? data,
    String? sid,
    String? overrideSrv,
  }) {
    final actualSrv = overrideSrv ?? _srv;
    final path = '/json/$actualSrv/$op';
    final extra = <String, dynamic>{
      'srv': actualSrv,
      'op': op,
      if (sid != null) 'sid': sid,
    };
    return _dio.post<T>(path, data: data, options: Options(extra: extra));
  }
}
```

The `ViperaInterceptor` on the injected Dio wraps/encrypts the request envelope and decrypts/unwraps the response — repository code only ever sees plain `Map` payloads.

## Canonical repository

```dart
class PaymentRepository extends ViperaBaseRepository {
  PaymentRepository(Dio dio) : super(dio, ViperaService.transfer.value);

  Future<Banks> getBanks() async {
    const op = 'getBanks';
    final response = await postOp(op);
    final result = GetBanksResponse.fromJson(response.data);
    return result.toGetBanks; // DTO → domain mapper
  }
}

@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(ref.watch(viperaDioProvider)); // client per dio-clients.md
}
```

(From `lib/src/features/payment/data/payment_repository.dart:89,390`.)

## DTO conventions

Locations: `features/<name>/data/dto/request/*_request.dart`, `features/<name>/data/dto/response/*_response.dart`. Shared wrappers (`MymoBaseHeaderResponse` etc.) and the annotation presets in `lib/src/shared/data/dto/`.

Prefer the shared presets from `json_serializable_presets.dart` (`@jsonSerializableOmitNulls`, `@jsonSerializableOmitNullsExplicit` for nested DTOs) over raw `@JsonSerializable(...)`:

```dart
// lib/src/features/face_recognition/data/dto/request/save_fr_action_no_sess_request.dart
import 'package:flutter_mymo_sme/src/shared/data/dto/json_serializable_presets.dart';

part 'save_fr_action_no_sess_request.g.dart';

@jsonSerializableOmitNulls
class SaveFrActionNoSessRequest {
  const SaveFrActionNoSessRequest({
    required this.moduleToken,
    required this.actionIndex,
    required this.imageBase64,
    required this.isRetry,
  });

  final String moduleToken;
  final String actionIndex;
  final String imageBase64;
  final bool isRetry;

  factory SaveFrActionNoSessRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveFrActionNoSessRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SaveFrActionNoSessRequestToJson(this);
}
```

Use `@JsonKey(name: 'wire_name')` whenever the server field name differs from the Dart camelCase name.

Naming: `<Operation>Request`, `<Operation>Response`. Domain models are **nouns** (`Banks`, `StatementRequest`, `FrActionsResult`) — never verb-prefixed (`GetBanks` ❌). See [naming-conventions.md](naming-conventions.md).

Mapping style: a `to<Domain>` getter/extension on the response DTO, or constructing the domain object inline in the repository method. Either is fine; keep it in the data layer.

## Fakes

One fake per repository, same public surface, deterministic data:

```
lib/src/features/<name>/data/fake/fake_<name>_repository.dart
```

Real examples: `fake_account_repository.dart`, `fake_authentication_repository.dart`, `fake_onboard_repository.dart`. They are wired in two places:

- `lib/src/app_bootstrap_fakes_api.dart` → `main_fake_api.dart` (offline/UI development)
- Tests, via `overrideRepos: [xRepositoryProvider.overrideWith(...)]` (see [testing.md](testing.md))

When you add a repository method, update its fake in the same change — a missing fake method breaks `main_fake_api` silently at runtime.

## Anti-patterns

- ❌ Abstract `XRepository` interface + `XRepositoryImpl` — not this project's pattern.
- ❌ Conditionals/derivations beyond mapping inside a repository (business logic → Service).
- ❌ Returning a DTO from a repository method or importing a DTO in `presentation/`.
- ❌ freezed, `copyWith` codegen, sealed DTOs — json_serializable only.
- ❌ Picking a Dio client by copying a neighboring repository — read [dio-clients.md](dio-clients.md).

## Recap

1. Concrete repo + keepAlive provider; provider override is the only seam.
2. `postOp(op, data:)` → `Response.fromJson` → domain noun.
3. json_serializable with explicit `fromJson`/`toJson`; `rps gen build` after edits.
4. Fake updated in the same PR as the repository.
