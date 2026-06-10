import 'package:tnds_flutter_app/src/shared/application/launchable_module.dart';
import 'package:tnds_flutter_app/src/shared/application/module_launcher_registry.dart';

/// Composition root for cross-module wiring.
///
/// This is the ONLY place that imports every launchable module and binds it
/// into the generic registry. Modules stay free of any sibling import; they
/// meet only here. To add a module: create it (depending only on `shared/`),
/// then add one entry below and spread its routes into the app router.
final moduleLauncherRegistryOverride = moduleLauncherRegistryProvider
    .overrideWith((ref) {
      return <String, LaunchableModule>{};
    });
