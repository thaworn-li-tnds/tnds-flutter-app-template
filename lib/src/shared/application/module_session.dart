/// Lifecycle state of a launchable module's *session* — the long-lived part a
/// module controller owns for the whole feature: establishing the session
/// token, then ready, or failed.
///
/// Per-screen *content* does NOT live here. Screen controllers (auto-disposed)
/// watch this to know when the session token is available, then load their own
/// content. This keeps the keepAlive module controller free of any single
/// screen's state, which matters when a module spans several screens in
/// sequence that each call APIs with the session/parent token.
sealed class ModuleSession {
  const ModuleSession();
}

/// Initial state before [start] is called. A screen reached directly (deeplink /
/// hot reload / test) without a launch lands here — render it as an escapable
/// error, never an infinite spinner, since no launch params were supplied.
class ModuleSessionIdle extends ModuleSession {
  const ModuleSessionIdle();
}

/// Establishing the session (e.g. exchanging the parent token for a module
/// token). Screens show loading.
class ModuleSessionLoading extends ModuleSession {
  const ModuleSessionLoading();
}

/// Finalizing on success (`finishSession` in flight). Screens show loading; the
/// finish action is blocked from re-firing.
class ModuleSessionFinishing extends ModuleSession {
  const ModuleSessionFinishing();
}

/// Session established — the token is available via the controller's token
/// getters; screen controllers may now call their APIs.
class ModuleSessionReady extends ModuleSession {
  const ModuleSessionReady();
}

/// Session establishment failed; screen controllers surface [error].
class ModuleSessionFailed extends ModuleSession {
  const ModuleSessionFailed(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}

/// Terminal state — the module has finished (completed) or been aborted
/// (cancelled). Reached exactly once; `complete`/`cancel` become no-ops after
/// it, so a result/abort can never fire twice. Re-launching via `start` resets
/// the session back to [ModuleSessionLoading].
class ModuleSessionClosed extends ModuleSession {
  const ModuleSessionClosed();
}
