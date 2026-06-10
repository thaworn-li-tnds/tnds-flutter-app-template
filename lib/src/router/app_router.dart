import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tnds_flutter_app/src/features/expense/router/expense_router.dart';
import 'package:tnds_flutter_app/src/features/home/presentation/home_screen.dart';
import 'package:tnds_flutter_app/src/router/tnds_route.dart';

part 'app_router.g.dart';

enum AppRouter with TndsRouter {
  home;

  @override
  String get routerName => 'app_router';

  @override
  String get path {
    switch (this) {
      case AppRouter.home:
        return '/';
    }
  }
}

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRouter.home.path,
    routes: [
      GoRoute(
        path: AppRouter.home.path,
        name: AppRouter.home.name,
        builder: (context, state) => const HomeScreen(),
      ),
      ...expenseRouter,
    ],
  );
}
