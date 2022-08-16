import 'dart:async';
import 'dart:html';

import 'package:firebase/firebase.dart' as firebase;

class FBMessaging {
  FBMessaging._();
  static FBMessaging _instance = FBMessaging._();
  static FBMessaging get instance => _instance;
  late firebase.Messaging _mc;
  String? _token;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void close() {
    _controller.close();
  }

  Future<void> init() async {
    print("20");
    _mc = firebase.messaging();
    print("22");
    print("24");
    try {
      String x = await _mc.getToken();
      print("26: $x");
    } on DomException catch (e) {
      print("29: ${e.toString()}");
    } catch (e) {
      print("32: ${e.toString()}");
    }
    print("34");
    _mc.onMessage.listen((event) {
      print("36");
      _controller.add(event.data);
    });
    print("36");
  }

  Future requestPermission() {
    return _mc.requestPermission();
  }

  Future<String> getToken([bool force = false]) async {
    if (force || _token == null) {
      await requestPermission();
      _token = await _mc.getToken();
    }
    return _token ?? "BOOOOO";
  }
}
