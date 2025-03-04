import 'dart:html' as html;
import 'dart:ui';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class HybridUrlStrategy extends UrlStrategy {
  final UrlStrategy hashUrlStrategy;
  final UrlStrategy pathUrlStrategy;

  HybridUrlStrategy(this.hashUrlStrategy, this.pathUrlStrategy);

  @override
  String getPath() {
    if (html.window.location.hash.isNotEmpty) {
      return hashUrlStrategy.getPath();
    }
    return pathUrlStrategy.getPath();
  }

  @override
  Object? getState() {
    if (html.window.location.hash.isNotEmpty) {
      return hashUrlStrategy.getState();
    }
    return pathUrlStrategy.getState();
  }

  @override
  String prepareExternalUrl(String internalUrl) {
    if (internalUrl.startsWith('#')) {
      return hashUrlStrategy.prepareExternalUrl(internalUrl);
    }
    return pathUrlStrategy.prepareExternalUrl(internalUrl);
  }

  @override
  Future<void> go(int count) async {
    if (html.window.location.hash.isNotEmpty) {
      await hashUrlStrategy.go(count);
    } else {
      await pathUrlStrategy.go(count);
    }
  }

  @override
  void pushState(Object? state, String title, String url) {
    if (url.startsWith('#')) {
      hashUrlStrategy.pushState(state, title, url);
    } else {
      pathUrlStrategy.pushState(state, title, url);
    }
  }

  @override
  void replaceState(Object? state, String title, String url) {
    if (url.startsWith('#')) {
      hashUrlStrategy.replaceState(state, title, url);
    } else {
      pathUrlStrategy.replaceState(state, title, url);
    }
  }

  @override
  VoidCallback addPopStateListener(EventListener fn) {
    if (html.window.location.hash.isNotEmpty) {
      return hashUrlStrategy.addPopStateListener(fn);
    } else {
      return pathUrlStrategy.addPopStateListener(fn);
    }
  }
}

void setHybridUrlStrategy() {
  setUrlStrategy(HybridUrlStrategy(const HashUrlStrategy(), PathUrlStrategy()));
}
