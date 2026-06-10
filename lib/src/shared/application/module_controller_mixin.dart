import 'package:tnds_flutter_app/src/shared/application/launchable_module.dart';
import 'package:tnds_flutter_app/src/shared/application/module_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared lifecycle for a launchable module's session controller — the part
/// every module repeats. Mix it into a keepAlive code-generated notifier whose
/// state is [ModuleSession]:
///
/// ```dart
/// @Riverpod(keepAlive: true)
/// class XModuleController extends _$XModuleController
///     with ModuleControllerMixin<XLaunchParams, XResult> {
///   @override
///   ModuleSession build() => const ModuleSessionLoading();
///
///   @override
///   Future<String> openSession(XLaunchParams p) => ...; // module token ('' if none)
///   @override
///   Future<XResult> finishSession() => ...;
/// }
/// ```
///
/// The mixin owns the result callbacks, nav policy, token and the enforced
/// `start` / `complete` / `cancel` state machine so a module only fills in the
/// service-specific hooks. `build()` must stay in the concrete class (returning
/// `const ModuleSessionIdle()`) — riverpod_generator reads its return type there.
///
/// The caller is notified through exactly ONE of `onCompleted` / `onCancelled` /
/// `onFailed` (guarded by [_terminated]); a session/finish failure auto-reports
/// `onFailed` so an orchestrator never hangs waiting for a callback.
mixin ModuleControllerMixin<P, R> on Notifier<ModuleSession> {
  void Function(R)? _onCompleted;
  void Function()? _onCancelled;
  void Function(Object error, StackTrace stackTrace)? _onFailed;
  ModuleNavOptions _navOptions = const ModuleNavOptions();
  P? _params;
  String _moduleToken = '';

  /// True once a result (completed / cancelled / failed) has been delivered to
  /// the caller. Guarantees exactly-once delivery across the lifecycle methods.
  bool _terminated = false;

  /// Navigation policy for this launch (read by the screen for its back behavior).
  ModuleNavOptions get navOptions => _navOptions;

  /// Launch params screens read to drive their own content calls.
  P get launchParams => _params as P;

  /// This module's own session token (from [openSession]); '' if the module
  /// has none.
  String get moduleToken => _moduleToken;

  // ---- hooks each module implements (the only freedom) --------------------

  /// Open the module session and return its token. Return '' when the module
  /// has no token to fetch (session is ready immediately).
  Future<String> openSession(P params);

  /// Finalize the flow on success and produce the module's result. Called by
  /// `complete()` (no argument) — override ONLY when finishing needs a server
  /// call (the result comes from the server, e.g. `finishOTP`). If the result
  /// is known client-side, pass it to `complete(result)` instead and you do not
  /// need to override this.
  Future<R> finishSession() => throw UnimplementedError(
    'override finishSession() (server finalize) or call complete(result) '
    '(client-determined result)',
  );

  /// Release/clean up the session when the user exits mid-way (back/close).
  /// Called by [cancel]. Default is a no-op — override to tell the server to
  /// abort (e.g. invalidate the [moduleToken]).
  Future<void> abortSession() async {}

  // ---- enforced lifecycle -------------------------------------------------

  /// Public entry point — opens the module session. Called by the launcher.
  /// Resets the terminal guard so a keepAlive controller can be re-launched.
  Future<void> start({
    required P params,
    required void Function(R) onCompleted,
    void Function()? onCancelled,
    void Function(Object error, StackTrace stackTrace)? onFailed,
    ModuleNavOptions navOptions = const ModuleNavOptions(),
  }) async {
    _params = params;
    _onCompleted = onCompleted;
    _onCancelled = onCancelled;
    _onFailed = onFailed;
    _navOptions = navOptions;
    _terminated = false;
    _moduleToken = '';
    state = const ModuleSessionLoading();
    final result = await AsyncValue.guard(() => openSession(params));
    result.when(
      data: (token) {
        _moduleToken = token;
        state = const ModuleSessionReady();
      },
      error: _fail,
      loading: () {},
    );
  }

  /// Called when the flow finishes successfully. Two ways to produce the result:
  /// - pass [result] (the result is known client-side, e.g. the user's choice)
  ///   → it is reported directly, no server call;
  /// - omit it → `finishSession()` runs (server finalize) and produces the result.
  ///
  /// Runs at most once (transitions to [ModuleSessionFinishing] then terminal
  /// [ModuleSessionClosed], so a double-tap / late tap from any screen is
  /// ignored). A `finishSession` failure auto-reports `onFailed`.
  Future<void> complete([R? result]) async {
    if (state is! ModuleSessionReady || _terminated) return;
    // Client-determined result — report directly, no finishSession.
    if (result != null) {
      _terminated = true;
      state = const ModuleSessionClosed();
      _onCompleted?.call(result);
      return;
    }
    // Server finalize.
    state = const ModuleSessionFinishing();
    final r = await AsyncValue.guard(finishSession);
    r.when(
      data: (value) {
        _terminated = true;
        state = const ModuleSessionClosed();
        _onCompleted?.call(value);
      },
      error: _fail,
      loading: () {},
    );
  }

  /// Called when the user backs out / cancels mid-way. Runs at most once:
  /// closes the session, lets the module clean up via [abortSession], then
  /// notifies the caller. A [complete] / [_fail] that already terminated wins.
  Future<void> cancel() async {
    if (_terminated) return;
    _terminated = true;
    state = const ModuleSessionClosed();
    await abortSession();
    _onCancelled?.call();
  }

  /// Terminal failure path — auto-reports `onFailed` exactly once and leaves the
  /// session in [ModuleSessionFailed] so the screen can show an escapable error.
  void _fail(Object error, StackTrace stackTrace) {
    if (_terminated) return;
    _terminated = true;
    state = ModuleSessionFailed(error, stackTrace);
    _onFailed?.call(error, stackTrace);
  }
}
