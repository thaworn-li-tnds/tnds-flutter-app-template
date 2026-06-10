# Architecture & Layers

## Trigger

Signals: new feature, new file placement, import direction, cross-feature import, "where does this file go", folder structure
Before generating code in this area, output verbatim: `Reading: architecture-layers.md`

## Rules — NEVER Violate

1. **Dependency direction**: `Presentation → Application → Domain ← Data`. Unidirectional, no reverse imports.
2. **Domain is pure Dart** — zero imports of `flutter`, `riverpod`, `dio`, or any platform package. Models, value objects, enums only.
3. **Data does I/O mapping only** — no business logic. DTO ↔ domain via `json_serializable`. Uses the shared Dio clients only.
4. **Application must not import Flutter widgets.** Services and notifiers orchestrate use-cases and transform domain → state.
5. **Presentation never calls Dio or a repository.** `ConsumerWidget`/`ConsumerStatefulWidget` + controllers only.
6. **No cross-feature imports** of another feature's `application/` or `presentation/`. Shared state/contracts live in `lib/src/shared/`; cross-module wiring happens only at the composition root (`lib/src/router/module_registry.dart`).

## Feature folder skeleton

Every feature under `lib/src/features/<name>/`:

```
<feature>/
├── application/      # Services (*_service.dart), module controllers/launchers
├── data/             # Repositories (*_repository.dart)
│   ├── dto/
│   │   ├── request/  # *_request.dart
│   │   └── response/ # *_response.dart
│   └── fake/         # fake_*_repository.dart (offline/test impls)
├── domain/           # Pure Dart models (nouns), launch params, results
├── presentation/     # Screens (*_screen.dart), controllers (*_controller.dart), widgets/
└── router/           # *_router.dart (enum with MymoRouter + GoRoute list)
```

Sub-domain features (`payment/transfer`, `payment/recipient`, `authentication/auth_module`) repeat the same internal structure one level down.

Not every feature needs every folder (e.g. `app_config` has no `presentation/`; a feature whose navigation is owned by its caller may have no `router/`) — but a folder that exists must obey its layer rules.

## The full chain (real example: face recognition)

```
presentation/controllers/fr_home_controller.dart   FrHomeController (@riverpod, auto-dispose)
        │  ref.read(frScreenServiceProvider)
        ▼
application/fr_screen_service.dart                  FrScreenService (plain class + Ref)
        │  _repo getter → ref.read(faceRecognitionRepositoryProvider)
        ▼
data/face_recognition_repository.dart               FaceRecognitionRepository extends ViperaBaseRepository
        │  postOp(op, data: requestDto.toJson()) → ResponseDto.fromJson → domain model
        ▼
domain/fr_actions_result.dart                       FrActionsResult (pure Dart noun)
```

Every new API/feature follows this chain. Details per hop: [service-layer.md](service-layer.md), [data-layer.md](data-layer.md), [riverpod-state.md](riverpod-state.md).

## Implementation order (dependency-first)

When building a feature/API end-to-end, write layers in this order — each step compiles against the previous one and commits cleanly (see [tooling-workflow.md](tooling-workflow.md)):

1. Domain model (`domain/`)
2. DTOs + repository method + fake (`data/`) — confirm the Dio client first ([dio-clients.md](dio-clients.md))
3. Service method (`application/`)
4. Controller (`presentation/`)
5. Screen/widgets (`presentation/`)
6. Route (`router/`) + registration
7. Locale keys ([localization.md](localization.md))
8. Tests ([testing.md](testing.md))

## Cross-cutting locations

| Concern | Location |
|---|---|
| Shared layers (same 4-way split, used by 2+ features) | `lib/src/shared/{application,data,domain,presentation}/` |
| Dio clients, interceptors, crypto | `lib/src/shared/data/remote/` |
| Secure storage / shared prefs wrappers | `lib/src/shared/data/local/` |
| Module launcher framework | `lib/src/shared/application/module_*.dart` |
| Reusable widgets | `lib/src/common_widgets/` |
| Exceptions, error logging | `lib/src/exceptions/` |
| Router config + composition root | `lib/src/router/` |
| Themes, constants, enums, extensions, utils | `lib/src/{themes,constants,enums,extensions,utils}/` |

## Cross-feature rule

```dart
// ❌ feature A importing feature B's internals
import 'package:flutter_mymo_sme/src/features/authentication/application/auth_service.dart';

// ✅ share via a provider/contract exposed from shared/
import 'package:flutter_mymo_sme/src/shared/application/launchable_module.dart';
```

When two features must talk (e.g. auth orchestrator → FR/OTP factors), they meet only through a neutral contract in `shared/` (`LaunchableModule`) wired at `lib/src/router/module_registry.dart` — the ONLY file allowed to import every module. See [module-launcher.md](module-launcher.md).

## Recap

1. `Presentation → Application → Domain ← Data`; domain stays pure Dart.
2. Feature = `{application, data(dto,fake), domain, presentation, router}`.
3. No cross-feature internals imports; shared contract + composition root instead.
4. Presentation never sees Dio, repositories, or DTOs.
