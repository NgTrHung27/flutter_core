enum AppRoute {
  splash(path: "/"),
  auth(path: "/auth"),
  login(path: "login"),
  register(path: "register"),
  home(path: "/home"),
  createProduct(path: "/product/add"),
  updateProduct(
    path: "/product/update/:product_id/:product_name/:product_price",
  ),
  profiling(path: "/profiling"),
  repaintBoundary(path: "/repaint-boundary"),
  isolateDemo(path: "isolate-demo"),
  memoryLeak(path: "memory-leak"),
  nativeAndroid(path: "native-android"),
  nativeIos(path: "native-ios"),
  permission(path: "permission");

  final String path;
  const AppRoute({required this.path});
}
