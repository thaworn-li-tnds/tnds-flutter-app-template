import 'package:tnds_flutter_app/src/shared/application/launchable_module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'module_launcher_registry.g.dart';

/// Generic, auth-free registry of launchable modules keyed by a string id.
///
/// Lets any feature launch any other module without importing it: the caller
/// reads `moduleLauncherRegistry[id]` (depending only on `shared/`) and calls
/// [LaunchableModule.launch]. The real entries are injected at the app
/// composition root (`lib/src/router/module_registry.dart`).
///
/// This is the non-auth counterpart of `authFactorRegistry` — same neutral
/// contract, but with no start-link/advance semantics; the caller decides
/// which module to launch and handles the [ModuleResult] itself.
@Riverpod(keepAlive: true)
Map<String, LaunchableModule> moduleLauncherRegistry(Ref ref) {
  return const <String, LaunchableModule>{};
}
