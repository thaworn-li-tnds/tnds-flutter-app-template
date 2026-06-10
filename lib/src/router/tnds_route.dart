/// Route-enum contract — every route group is an `enum X with TndsRouter`
/// declaring [routerName] and [path]; [name] is derived so route names are
/// never hand-written. Navigate with `context.goNamed(XRouter.y.name)`.
mixin TndsRouter {
  String get routerName;
  String get path;
  String get parent => '';

  String get name {
    if (path == '/') {
      // For home route
      return 'app_router';
    }

    // Remove `/` and replace `-` with `_` from path
    final generatePath = path.replaceAll('/', '').replaceAll('-', '_');

    if (parent.isNotEmpty) {
      // For nested route
      return '$routerName.$parent$generatePath';
    }

    return '$routerName.$generatePath';
  }
}
