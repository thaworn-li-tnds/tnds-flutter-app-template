# Testing

## Trigger

Signals: any test file, `testWidgets`, Robot, fake, mock, mocktail, ProviderContainer, coverage, CachedNetworkImage in tests, MissingPluginException
Before generating code in this area, output verbatim: `Reading: testing.md`

## Rules — NEVER Violate

1. **Widget tests are Robot-only.** A `testWidgets` body contains ONLY calls on `Robot` / a feature robot (plus plain `expect` on values a robot returned). Direct `tester.*` or `find.*` in a test body is a violation.
2. **Missing helper ⇒ extend the Robot** (`test/src/robot.dart`) or the feature robot — adding the method is part of the test task, not a reason to call `tester` inline.
3. **Repositories are faked via `overrideRepos`**, never by mocking Riverpod providers/notifiers:
   `overrideRepos: [myRepositoryProvider.overrideWith((ref) => FakeMyRepository())]`
4. **Tests mirror `lib/src/` under `test/src/`.** mocktail mocks live centrally in `test/src/mocks.dart`; fakes live with the feature in `lib/src/features/<name>/data/fake/`.
5. **Any test rendering `CachedNetworkImage`** initializes sqflite-ffi with a fresh temp DB path (recipe below). Never `deleteDatabase` in `tearDown`.
6. **Provider/controller unit tests** use a `ProviderContainer` with `addTearDown(container.dispose)`.
7. Coverage effort targets `application/` and `presentation/` — `rps cov` already excludes `*.g.dart`, `fake_*.dart`, `*_repository.dart`, DTOs, themes, env, `shared/`.

## Robot API (`test/src/robot.dart`)

```dart
final r = Robot(tester);

await r.pumpTestWidget(MyScreen(), overrideRepos: [
  myRepositoryProvider.overrideWith((ref) => FakeMyRepository()),
]);

r.expectKey('my-list-key');            // find.byKey + count
r.expectText('Submit');                // find.text + count
r.expectType(CommonButtonWidget);      // find.byType + count
r.expectLabelText('total_label', '1,000.00', isContain: true);
await r.clickWidgetByKey('submit_button');   // tap + pumpAndSettle
await r.clickWidgetByType(CommonButtonWidget);
await r.clickWidgetByText('OK');             // tap + pump
```

`pumpTestWidget` already: clears SharedPreferences, mocks `path_provider` + `url_launcher` channels, loads `.env.test`, builds the container via `AppBootstrap.createTestProviderContainer(addDelay: false, overrideRepos: ...)`, and wraps in `EasyLocalization` (mock loader) + `LoaderOverlay` + `MockGoRouterProvider`.

## Feature robots

3+ tests for one feature ⇒ create `test/src/features/<name>/<name>_robot.dart` composing the core Robot, with semantic steps:

```dart
class SettingRobot {
  SettingRobot(this.robot);
  final Robot robot;

  Future<void> pumpSettingScreen({AppUser? user}) async { ... }
  Future<void> tapLogout() => robot.clickWidgetByKey('logout_row');
}
```

Existing: `onboard_robot.dart`, `setting_robot.dart`, `daily_limit_robot.dart`. When the Robot-only rule needs a new primitive (enterText, drag, runAsync-wrapped pump...), add it to the core `Robot` so every feature benefits.

## Test shapes

**Widget test:**

```dart
testWidgets('shows accounts', (tester) async {
  final r = Robot(tester);
  await r.pumpTestWidget(
    const BusinessAccountsScreen(),
    overrideRepos: [
      accountRepositoryProvider.overrideWith((ref) => FakeAccountRepository()),
    ],
  );
  r.expectKey('account-list');
});
```

**Controller/provider unit test** (no UI — `test/src/features/sample_module/sample_module_controller_test.dart` shape):

```dart
test('complete closes the session', () async {
  final container = ProviderContainer(overrides: [...]);
  addTearDown(container.dispose);

  final controller = container.read(sampleModuleControllerProvider.notifier);
  await controller.start(params: ..., onCompleted: ...);
  await controller.complete();

  expect(container.read(sampleModuleControllerProvider), isA<ModuleSessionClosed>());
});
```

**Pure-Dart unit test** (utils/formatters): plain `test()` + `expect()`, no Robot needed.

## CachedNetworkImage / sqflite recipe (required verbatim)

```dart
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

setUp(() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  // unique temp dir per test → no cross-isolate SQLite lock conflicts
  await databaseFactory.setDatabasesPath(
    Directory.systemTemp.createTempSync('sq').path,
  );
  HttpOverrides.global = null;
});
```

Do NOT call `databaseFactory.deleteDatabase(...)` in `tearDown` — flutter_cache_manager's in-flight queries then throw `Bad state: This database has already been closed`. Wrap network-image renders with `mockNetworkImages(() => ...)` (`mocktail_image_network`).

## Native plugin mocking

Symptom `MissingPluginException ... after the test had completed` ⇒ a screen fires a plugin post-test. Fix inside `pumpTestWidget` in `test/src/robot.dart` (not per-test):

```dart
TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler(
  const MethodChannel('plugins.flutter.io/<plugin-channel>'),
  (MethodCall methodCall) async => <return-value>,
);
```

## Gotcha: fake-async vs `Future.delayed`

`testWidgets` runs in fake-async — an `unawaited(...)` + `Future.delayed` in production code deadlocks the test. Seed controllers via a debug method or wrap with `tester.runAsync` **inside a Robot helper**, never raw in the test body.

## Recap

1. Robot-only bodies; extend the Robot instead of calling `tester`.
2. Fakes via `overrideRepos`; mocks only for non-repo seams in `mocks.dart`.
3. sqflite-ffi recipe for image tests; plugin mocks in `pumpTestWidget`.
4. `addTearDown(container.dispose)` in provider tests.
