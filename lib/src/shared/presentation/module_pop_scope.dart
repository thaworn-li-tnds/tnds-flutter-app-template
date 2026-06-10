import 'package:flutter/material.dart';
import 'package:tnds_flutter_app/src/shared/application/launchable_module.dart';
import 'package:go_router/go_router.dart';

/// Applies a module's [ModuleNavOptions] back policy to its entry screen.
///
/// Generic and reused by any launchable module's first screen so back handling
/// isn't reimplemented per module:
/// - [ModuleBackTarget.none]   → back is blocked.
/// - [ModuleBackTarget.opener] → back pops to the opener. [canPop] is left true
///   so the native pop animation AND the iOS interactive swipe-back gesture
///   both work; [onBack] fires after the pop so the orchestrator can reset.
/// - [ModuleBackTarget.route]  → back is intercepted and navigates to
///   [ModuleNavOptions.backRouteName] (no native gesture for an arbitrary route).
class ModulePopScope extends StatelessWidget {
  const ModulePopScope({
    super.key,
    required this.options,
    required this.onBack,
    required this.child,
  });

  final ModuleNavOptions options;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final allowNativePop = options.backTarget == ModuleBackTarget.opener;
    return PopScope(
      canPop: allowNativePop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          // Native pop/swipe back to the opener already happened — just reset.
          onBack();
          return;
        }
        // Pop was blocked (none / route) — handle per policy.
        switch (options.backTarget) {
          case ModuleBackTarget.none:
          case ModuleBackTarget.opener:
            return;
          case ModuleBackTarget.route:
            onBack();
            final route = options.backRouteName;
            if (route != null && route.isNotEmpty) context.goNamed(route);
        }
      },
      child: child,
    );
  }
}
