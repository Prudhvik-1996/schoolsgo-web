import 'package:flutter/material.dart';

class RouteObserverService extends NavigatorObserver {
  static String? currentRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    print("New route pushed from: ${previousRoute?.settings.name} to: ${route.settings.name}");
    currentRoute = route.settings.name;
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    print("New route replaced from: ${oldRoute?.settings.name} to: ${newRoute?.settings.name}");
    currentRoute = newRoute?.settings.name;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  static bool shouldSkipSplashScreen() {
    return ["/install", "/about", "google", "sitemap", "robots", "privacy_policy", "delete_data"].contains(currentRoute);
  }
}
