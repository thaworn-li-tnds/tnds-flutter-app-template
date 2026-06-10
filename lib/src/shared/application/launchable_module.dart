/// Neutral cross-module launch contract.
///
/// This is the single seam that lets one feature module drive another without
/// either side importing the other. An orchestrator (e.g. the authentication
/// module) depends only on [LaunchableModule]; each launchable feature module
/// provides an adapter that implements it. Sibling modules are wired together
/// at the app composition root (see `lib/src/router/module_registry.dart`),
/// never by importing each other directly.
///
/// Must stay free of any `features/` import — only this keeps modules portable.
library;

/// How a module's entry screen is presented relative to the opener.
enum ModuleEntryMode {
  /// Replace the current route — the opener is closed, no stack (no back to it).
  replace,

  /// Push on top of the opener — stacks (back can return to the opener).
  push,
}

/// What the back gesture does on a module's entry screen.
enum ModuleBackTarget {
  /// Back is blocked.
  none,

  /// Back returns to the screen that opened the module.
  opener,

  /// Back navigates to a specific route ([ModuleNavOptions.backRouteName]).
  route,
}

/// Per-launch navigation policy for a module. Lets each launch configure
/// whether the entry screen stacks or replaces, and what back does. Generic so
/// any module / caller can use it via [ModuleLaunchContext].
class ModuleNavOptions {
  const ModuleNavOptions({
    this.entryMode = ModuleEntryMode.replace,
    this.backTarget = ModuleBackTarget.none,
    this.backRouteName,
  });

  final ModuleEntryMode entryMode;
  final ModuleBackTarget backTarget;

  /// Route name to go to on back when [backTarget] is [ModuleBackTarget.route].
  final String? backRouteName;
}

/// Generic input handed to a module when it is launched.
///
/// A few fields are universal (used by every factor) and stay typed:
/// [parentToken] / [flowId] / [username] / [navOptions]. Anything else a
/// specific module needs is passed through the single untyped [args] bag.
///
/// FUTURE-PROOF RULE: to pass a new module-specific launch parameter, put it in
/// [args] — the [launch] signature and this class never change, and modules that
/// don't read the key are unaffected. Promote a key to a typed field here only
/// when it becomes universal across modules.
class ModuleLaunchContext {
  const ModuleLaunchContext({
    this.parentToken,
    this.args = const {},
    this.flowId = '',
    this.username = '',
    this.navOptions = const ModuleNavOptions(),
  });

  /// Token of whoever launched this module (onboarding→auth: activationToken;
  /// auth→FR: authToken). Optional.
  final String? parentToken;

  /// Caller → module launch arguments (untyped bag). The launcher reads these in
  /// `mapParams` to build its typed LaunchParams; the module's service decides
  /// which (if any) go to the backend. Standard fields above stay typed.
  final Map<String, dynamic> args;

  /// Flow type, e.g. `ACTIVATION` / `FIRST_ACTIVATION`.
  final String flowId;
  final String username;

  /// Navigation policy (back/stack) for this launch.
  final ModuleNavOptions navOptions;
}

/// Outcome a module reports back to whoever launched it.
enum ModuleResultStatus { completed, cancelled, failed }

/// Result handed back through [ModuleResultCallback] when a module finishes.
class ModuleResult {
  const ModuleResult({
    required this.status,
    this.token = '',
    this.data,
    this.error,
  });

  final ModuleResultStatus status;

  /// Module-produced token (e.g. `frToken` / `otpToken`).
  final String token;

  /// Optional extra payload (e.g. `callbackModule`).
  final Map<String, dynamic>? data;

  /// Set when [status] is [ModuleResultStatus.failed] — the cause, so the
  /// caller can surface it (e.g. parse into an AppException).
  final Object? error;
}

typedef ModuleResultCallback = void Function(ModuleResult result);

/// A feature module that can be launched generically by an orchestrator.
///
/// Implementations start the module's own sub-flow (navigating its own
/// screens) and report the outcome through [onResult]. They must not know what
/// the caller does with the result.
abstract interface class LaunchableModule {
  void launch(ModuleLaunchContext context, ModuleResultCallback onResult);
}
