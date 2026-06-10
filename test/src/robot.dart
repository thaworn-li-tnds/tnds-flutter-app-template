import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tnds_flutter_app/src/themes/app_theme.dart';

import 'mocks.dart';

/// Test driver for widget tests — ALL interactions and assertions go through
/// this class (or a feature robot composing it). Test bodies never call
/// `tester.*` / `find.*` directly; when a helper is missing, add it here.
class Robot {
  Robot(this.tester);

  final WidgetTester tester;

  /// Mock router injected by [pumpTestWidget]; verify navigation with e.g.
  /// `verify(() => robot.goRouter.pushNamed(...))`.
  late MockGoRouter goRouter;

  /// Pumps [widget] inside the app shell (Riverpod + EasyLocalization +
  /// MaterialApp with the app theme + mock GoRouter). Inject fakes via
  /// [overrideRepos]. NOTE: `EasyLocalization.ensureInitialized()` runs once
  /// in `test/flutter_test_config.dart` — awaiting it here, inside the
  /// fake-async test zone, deadlocks on `SharedPreferences.getInstance()`.
  Future<void> pumpTestWidget(
    Widget widget, {
    List<Override> overrideRepos = const [],
    ProviderContainer? container,
  }) async {
    goRouter = MockGoRouter();
    when(
      () => goRouter.pushNamed(
        any(),
        pathParameters: any(named: 'pathParameters'),
        queryParameters: any(named: 'queryParameters'),
        extra: any(named: 'extra'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => goRouter.goNamed(
        any(),
        pathParameters: any(named: 'pathParameters'),
        queryParameters: any(named: 'queryParameters'),
        extra: any(named: 'extra'),
      ),
    ).thenAnswer((_) {});
    when(() => goRouter.canPop()).thenReturn(true);

    container ??= ProviderContainer(overrides: [...overrideRepos]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: EasyLocalization(
          supportedLocales: const [Locale('th'), Locale('en')],
          path: 'assets/translations',
          assetLoader: const TestAssetLoader(),
          child: Builder(
            builder: (context) {
              return MaterialApp(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: container!.read(lightThemeProvider),
                home: InheritedGoRouter(goRouter: goRouter, child: widget),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // ---- assertions ----------------------------------------------------------

  void expectWidgets(Finder finder, {int n = 1}) {
    if (n == 0) {
      expect(finder, findsNothing);
    } else if (n == 1) {
      expect(finder, findsOneWidget);
    } else {
      expect(finder, findsNWidgets(n));
    }
  }

  void expectKey(String key, {int n = 1}) =>
      expectWidgets(find.byKey(Key(key)), n: n);

  void expectText(String text, {int n = 1}) =>
      expectWidgets(find.text(text), n: n);

  void expectType(Type type, {int n = 1}) =>
      expectWidgets(find.byType(type), n: n);

  void expectLabelText(
    String key,
    String expectedText, {
    bool isContain = false,
  }) {
    final finder = find.byKey(Key(key));
    expect(finder, findsOneWidget);
    final Text label = tester.widget<Text>(finder);
    if (isContain) {
      expect(label.data, contains(expectedText));
    } else {
      expect(label.data, expectedText);
    }
  }

  // ---- interactions --------------------------------------------------------

  Future<void> clickWidgetByKey(String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> clickWidgetByType(Type type) async {
    await tester.tap(find.byType(type));
    await tester.pumpAndSettle();
  }

  Future<void> clickWidgetByText(String text) async {
    final finder = find.text(text);
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> enterTextByKey(String key, String text) async {
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pump();
  }

  Future<void> settle() => tester.pumpAndSettle();
}
