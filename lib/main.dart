import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tnds_flutter_app/src/exceptions/async_error_logger.dart';
import 'package:tnds_flutter_app/src/localization/folder_asset_loader.dart';
import 'package:tnds_flutter_app/src/router/app_router.dart';
import 'package:tnds_flutter_app/src/router/module_registry.dart';
import 'package:tnds_flutter_app/src/themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [moduleLauncherRegistryOverride],
      observers: [AsyncErrorLogger()],
      child: EasyLocalization(
        supportedLocales: const [Locale('th'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('th'),
        assetLoader: const FolderAssetLoader(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'TNDS Flutter App',
      theme: ref.watch(lightThemeProvider),
      routerConfig: ref.watch(goRouterProvider),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
