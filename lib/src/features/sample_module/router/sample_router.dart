import 'package:tnds_flutter_app/src/features/sample_module/presentation/sample_screen.dart';
import 'package:tnds_flutter_app/src/features/sample_module/presentation/sample_screen2.dart';
import 'package:tnds_flutter_app/src/router/tnds_route.dart';
import 'package:go_router/go_router.dart';

enum SampleModuleRouter with TndsRouter {
  home,
  screen2;

  @override
  String get routerName => 'sample_module_router';

  @override
  String get path {
    switch (this) {
      case SampleModuleRouter.home:
        return '/sample-module';
      case SampleModuleRouter.screen2:
        return '/sample-module/screen2';
    }
  }
}

final sampleModuleRouter = <RouteBase>[
  GoRoute(
    path: SampleModuleRouter.home.path,
    name: SampleModuleRouter.home.name,
    builder: (context, state) => const SampleScreen(),
  ),
  GoRoute(
    path: SampleModuleRouter.screen2.path,
    name: SampleModuleRouter.screen2.name,
    builder: (context, state) => const SampleScreen2(),
  ),
];
