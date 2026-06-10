import 'dart:async';

import 'package:tnds_flutter_app/src/shared/application/module_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gates a screen content controller's load on its module session — the pattern
/// every per-screen controller repeats. Call it from `build()`:
///
/// ```dart
/// @riverpod
/// class XHomeController extends _$XHomeController {
///   @override
///   Future<XData> build() => loadWhenSessionReady(
///         ref,
///         xModuleControllerProvider,
///         () => ref.read(xServiceProvider).load(...),
///       );
/// }
/// ```
///
/// While the session is loading it stays in loading (a non-completing future)
/// and rebuilds when the session changes — the race-free way to wait for the
/// session token without the keepAlive controller's `build()` auto-completing.
Future<T> loadWhenSessionReady<T>(
  Ref ref,
  ProviderListenable<ModuleSession> sessionProvider,
  Future<T> Function() load,
) {
  final session = ref.watch(sessionProvider);
  return switch (session) {
    ModuleSessionReady() => load(),
    ModuleSessionFailed(:final error) => Future<T>.error(error),
    // Not ready yet, finishing, idle, or closing as the screen pops → stay
    // loading; rebuilds when the session changes.
    ModuleSessionIdle() ||
    ModuleSessionLoading() ||
    ModuleSessionFinishing() ||
    ModuleSessionClosed() => Completer<T>().future,
  };
}
