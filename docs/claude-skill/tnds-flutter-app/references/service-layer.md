# Service Layer

## Trigger

Signals: any data access from presentation, new `*_service.dart`, `ref.read(xRepositoryProvider)` anywhere outside `data/`, use-case orchestration, "where do I put this logic"
Before generating code in this area, output verbatim: `Reading: service-layer.md`

## Rules — NEVER Violate

1. **ALL repository access goes through a Service class** in `features/<name>/application/`. No exceptions for "simple reads".
2. **A Service is a plain class** holding `Ref`, with a private `_repo` getter and domain-typed methods, exposed via exactly one `@riverpod` provider.
3. **`@riverpod Future<T> getXxx(Ref ref)` function providers that call a repository are FORBIDDEN.** The codebase still contains many (see `MIGRATION.md`) — never replicate them, even when the surrounding file does.
4. **Presentation NEVER touches a repository.** A `*_controller.dart` reads a service provider only. Importing `features/<x>/data/...` from `presentation/` is a violation.
5. **Business logic lives in the Service** (orchestration, multi-step flows, transformation of domain models). UI state lives in the Controller. I/O mapping (DTO ↔ domain) lives in the Repository. Keep each at its own altitude.
6. Services must NOT import Flutter widgets (`package:flutter/material.dart` etc.). They are application layer.

## Canonical Service class

From `lib/src/features/sample_module/application/sample_screen_service.dart` — copy this shape verbatim:

```dart
import 'package:flutter_mymo_sme/src/features/sample_module/data/sample_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sample_screen_service.g.dart';

class SampleScreenService {
  SampleScreenService(this.ref);

  final Ref ref;

  SampleRepository get _repo => ref.read(sampleRepositoryProvider);

  Future<String> loadData(String id) => _repo.loadData(id);

  Future<String> doAction(String token) => _repo.doAction(token);
}

@riverpod
SampleScreenService sampleScreenService(Ref ref) => SampleScreenService(ref);
```

A richer real example mapping request DTOs inside the service: `lib/src/features/face_recognition/application/fr_screen_service.dart` (`FrScreenService.saveFRAction` builds `SaveFrActionNoSessRequest` from named params so the screen never sees the DTO shape).

Even a one-line pass-through method is correct: it keeps the seam consistent (DIP via the service provider) and gives orchestration a place to grow without moving call sites later.

## Canonical Controller → Service usage

```dart
// presentation/*_controller.dart
@riverpod
class StatementController extends _$StatementController {
  @override
  Future<StatementRequest?> build() async => null;

  Future<void> execute(RequestStatementRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(accountServiceProvider).requestStatement(request),
    );
  }
}
```

For module screens, the load is gated on the module session instead — see `loadWhenSessionReady` in [module-launcher.md](module-launcher.md) and the real example `lib/src/features/face_recognition/presentation/controllers/fr_home_controller.dart`.

## Anti-patterns (real code — do NOT replicate)

❌ **Function provider calling a repository** (`lib/src/features/payment/application/payment_service.dart`):

```dart
@riverpod
Future<Banks?> getBanks(Ref ref) async {
  final result = await ref.read(paymentRepositoryProvider).getBanks();
  return result;
}
```

This is legacy. It skips the service seam, scatters use-cases across loose functions, and couples every watcher to the repository provider. Listed for conversion in `MIGRATION.md`.

❌ **Controller reading a repository directly** (`lib/src/features/user/presentation/validate_pin_biometric_controller.dart`):

```dart
state = await AsyncValue.guard(() async {
  return await ref.read(userRepositoryProvider).setBiometric(request); // presentation → data
});
```

✅ Correct version: add `setBiometric` to a `UserService` class in `features/user/application/`, and have the controller call `ref.read(userServiceProvider).setBiometric(request)`.

## Conversion recipes (when touching legacy code)

**A. Read-load that UI currently `ref.watch`es** (`ref.watch(getBanksProvider)`):

1. Add `Future<Banks?> getBanks() => _repo.getBanks();` to the feature's Service class (create the class if the file only has function providers).
2. Create/extend a screen controller: `@riverpod class BankListController extends _$BankListController { @override Future<Banks?> build() => ref.read(paymentServiceProvider).getBanks(); }`
3. Screen switches `ref.watch(getBanksProvider)` → `ref.watch(bankListControllerProvider)`; rendering via `AsyncValue.when` / `SystemAsyncValueWidget` is unchanged.
4. Delete the function provider, run `rps gen build`, update tests in the same PR.

**B. Mutation currently wrapped by a controller calling the function provider** (`ref.read(requestStatementProvider(request).future)`):

1. Move the body into a Service method.
2. Controller's `AsyncValue.guard` closure calls the service method directly.
3. Delete the function provider.

Each conversion changes the UI watch pattern — screen + controller + tests must move in the same PR. Never leave both the function provider and the service method alive.

## Naming

- `<Feature>Service` — feature work (content, actions). Plain name.
- `<Feature>ModuleService` — module session lifecycle IO only (`startX`/`finishX`). See [module-launcher.md](module-launcher.md) and [naming-conventions.md](naming-conventions.md).

## Recap

1. Controller → Service → Repository. Always all three hops.
2. Service = plain class + `Ref` + `_repo` getter + one `@riverpod` provider.
3. No function providers that touch repositories; convert on contact per the recipes.
4. Presentation never imports `data/`.
