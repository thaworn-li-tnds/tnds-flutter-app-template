import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_app_bar.dart';
import 'package:tnds_flutter_app/src/common_widgets/common_circular_progress_widget.dart';
import 'package:tnds_flutter_app/src/extensions/context_extension.dart';
import 'package:tnds_flutter_app/src/shared/application/launchable_module.dart';
import 'package:tnds_flutter_app/src/shared/application/module_controller_mixin.dart';
import 'package:tnds_flutter_app/src/shared/application/module_session.dart';
import 'package:tnds_flutter_app/src/shared/presentation/module_error_view.dart';
import 'package:tnds_flutter_app/src/shared/presentation/module_pop_scope.dart';

/// Shared shell for a launchable module's ENTRY screen. Owns the back policy
/// ([ModulePopScope]), AppBar, the [ModuleSession] switch, AND the escape
/// navigation — so every module screen renders the session states consistently
/// and is never a dead-end: the failed / not-launched states always show an
/// escapable [ModuleErrorView], and the same escape is handed to [ready] for a
/// screen's own content-load error. A screen never wires escape navigation.
///
/// Deeper screens within the module are plain [Scaffold] screens — do NOT
/// wrap them in this (their back would cancel the whole module).
class ModuleScaffold extends ConsumerWidget {
  const ModuleScaffold({
    super.key,
    required this.controllerProvider,
    required this.ready,
    this.onErrorClose,
    this.title,
    this.actionIcon,
    this.onAction,
  });

  /// The module's session controller provider. The scaffold watches it for the
  /// [ModuleSession] state and reads the notifier for the nav policy
  /// ([ModuleControllerMixin.navOptions]) and back/cancel — so the screen does
  /// NOT pass `session` / `navOptions` / `onBack`, it only names the provider.
  final NotifierProvider<ModuleControllerMixin, ModuleSession>
      controllerProvider;

  /// Builds the module's content for [ModuleSessionReady]. Receives the
  /// framework escape to reuse for the screen's own content-load error.
  final Widget Function(BuildContext context, VoidCallback onErrorClose) ready;

  /// Optional custom escape from the error / not-launched state. Defaults to
  /// pop (or the `route` back target, else the app home).
  final VoidCallback? onErrorClose;

  /// Optional AppBar title.
  final String? title;

  /// Right-side action icon shown while [ModuleSessionReady] (with [onAction]).
  final IconData? actionIcon;

  /// Tap handler for the right-side action.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(controllerProvider);
    final controller = ref.read(controllerProvider.notifier);
    final navOptions = controller.navOptions;
    final isNoBack = navOptions.backTarget == ModuleBackTarget.none;
    final isReady = session is ModuleSessionReady;

    // Framework-owned escape — the single dead-end-free exit, reused by the
    // session error/idle views and handed to `ready` for content errors.
    void escape() {
      if (onErrorClose != null) {
        onErrorClose!();
      } else if (context.canPop()) {
        context.pop();
      } else if (navOptions.backTarget == ModuleBackTarget.route &&
          (navOptions.backRouteName?.isNotEmpty ?? false)) {
        context.goNamed(navOptions.backRouteName!);
      } else {
        // Last resort (e.g. opened as the sole route): go to the app root.
        // Use the path, not the router enum, to keep shared/ off the router layer.
        context.go('/');
      }
    }

    return ModulePopScope(
      options: navOptions,
      onBack: controller.cancel,
      child: Scaffold(
        backgroundColor: context.appColors.background,
        appBar: CommonAppBar(
          titleText: title,
          isShowIconLeft: !isNoBack,
          isShowIconRight: isNoBack || (isReady && onAction != null),
          rightIcon: isNoBack ? Icons.close : (actionIcon ?? Icons.more_horiz),
          onClickIconRight: isNoBack ? controller.cancel : onAction,
        ),
        body: SafeArea(
          child: switch (session) {
            ModuleSessionFailed(:final error) => ModuleErrorView(
                error: error,
                onClose: escape,
              ),
            // Reached without a launch (deeplink / hot reload) — escapable.
            ModuleSessionIdle() => ModuleErrorView(onClose: escape),
            ModuleSessionLoading() ||
            ModuleSessionFinishing() ||
            ModuleSessionClosed() =>
              const Center(child: CommonCircularProgressWidget()),
            ModuleSessionReady() => ready(context, escape),
          },
        ),
      ),
    );
  }
}
