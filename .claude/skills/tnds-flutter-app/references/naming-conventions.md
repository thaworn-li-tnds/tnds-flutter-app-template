# Naming Conventions

## Trigger

Signals: new file, new class, rename, file suffix, "what should I call this"
Before generating code in this area, output verbatim: `Reading: naming-conventions.md`

## Rules — NEVER Violate

1. **File suffix encodes the layer** — see the table; a suffix in the wrong folder is a violation.
2. **Domain models are nouns.** A domain class name starting with a verb (`Get`, `Fetch`, `Load`, `Create`, `Update`, `Delete`) is a violation.
   Domain nouns come in two roles — both live flat in `domain/`, the NAME and doc comment carry the distinction:
   - **Entity / value object** (the business model): has its own identity or value semantics, independent of any screen — `Expense`, `Budget`, `Money`, `ExpenseCategory`. Doc comment starts with `Entity —` / `Value object —`.
   - **Read model** (a projection): composed by a Service to answer ONE query; no identity, never persisted or sent to the wire. Suffix signals it: `*Overview`, `*Summary`, `*Status` — `ExpenseOverview`, `CategoryBudgetStatus`. Doc comment starts with `Read model —`.
   True UI state (selected filter, form input) is NEITHER — it lives in a controller, not in `domain/`.
3. **`Module` in a class name = module-control machinery only** (launcher / session controller / lifecycle service). Feature work stays plain. `Module` is a naming signal, **not** a folder rule: a `*_module_controller.dart` still lives in `presentation/` (it is a controller); only the launcher and module service sit in `application/`. See [module-launcher.md](module-launcher.md).
4. Route paths kebab-case; enum values camelCase; providers follow the class name (`sampleScreenServiceProvider`).

## File suffix → layer → location

| Suffix | Layer | Location |
|---|---|---|
| `*_screen.dart` / `*_page.dart` | Presentation | `features/<name>/presentation/` |
| `*_controller.dart` / `*_module_controller.dart` | Presentation | `features/<name>/presentation/` (NOT `application/`) |
| `*_service.dart` | Application | `features/<name>/application/` |
| `*_module_launcher.dart` / `*_module_service.dart` | Application | `features/<name>/application/` |
| `*_repository.dart` | Data | `features/<name>/data/` |
| `*_request.dart` / `*_response.dart` | Data (DTO) | `features/<name>/data/dto/{request,response}/` |
| `fake_*.dart` | Data (fake) | `features/<name>/data/fake/` |
| `*_router.dart` | Router | `features/<name>/router/` |
| `*.g.dart` | Generated | Beside source — never hand-edit |
| domain models | Domain | `features/<name>/domain/` |

## Class naming

| Type | Convention | Example |
|---|---|---|
| Screen | `<Feature>Screen` | `TransferInputScreen` |
| Service | `<Feature>Service` | `TransferService` |
| Controller | `<Feature>Controller` | `BankListController` |
| Repository | `<Feature>Repository` | `PaymentRepository` |
| Route enum | `<Feature>Router with TndsRouter` | `FaceRecognitionRouter` |
| DTO | `<Operation>Request` / `<Operation>Response` | `RequestStatementRequest`, `LoginWithPinResponse` |
| Module launcher / controller / service | `<Feature>Module{Launcher,Controller,Service}` | `SampleModuleLauncher` |
| Launch params / result (domain) | `<Feature>LaunchParams` / `<Feature>Result` | `SampleLaunchParams`, `SampleResult` |
| Private sub-widget | `_PascalCase` | `_HeaderSection` |

## Domain = nouns

| ✅ Noun | ❌ Verb phrase |
|---|---|
| `BusinessAccountItem` | `GetBusinessAccountItem` |
| `TransferRecipient` | `FetchTransferRecipient` |
| `StatementPeriod` | `GetStatementPeriod` |

The operation name belongs to the repository method (`getBusinessAccounts()`), the DTO (`GetBusinessAccountsResponse`), and the LocaleKeys — never to the domain model.

## Common mistakes

- `*_controller.dart` placed in `application/` — controllers are presentation. This includes a module session controller (`*_module_controller.dart`): despite the `Module` name, it is still a controller and belongs in `presentation/`.
- Screen file without the `_screen` suffix.
- A "common" widget that is actually a full screen — name it `*_screen.dart` and place accordingly.
- `Module` added to a feature-internal class (screen content controller, repository) — it is a signal, not decoration.
- Verb-prefixed domain class smuggled in from a DTO name.

## Recap

1. Suffix = layer = folder; controllers live in presentation.
2. Domain nouns; operations live on repos/DTOs.
3. `Module` only on module-control classes.
