import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:schoolsgo_web/src/common_components/network_status/constants/network_status.dart';

class NetworkStatusService {
  StreamController<NetworkStatus> networkStatusController = BehaviorSubject();

  NetworkStatusService() {
    // if (defaultTargetPlatform != TargetPlatform.iOS) {
    //   Connectivity().onConnectivityChanged.listen((status) {
    //     networkStatusController.add(getNetworkStatus(status));
    //   });
    // } else {
    //   networkStatusController.add(NetworkStatus.Online);
    // }
  }

  NetworkStatus getNetworkStatus(ConnectivityResult status) {
    // return defaultTargetPlatform == TargetPlatform.iOS
    //     ? NetworkStatus.Online
    //     : status == ConnectivityResult.none
    //         ? NetworkStatus.Offline
    //         : NetworkStatus.Online;
    return NetworkStatus.Online;
  }

  Future<NetworkStatus> getInitialStatus() async {
    // if (defaultTargetPlatform != TargetPlatform.iOS) {
    //   var status = await Connectivity().checkConnectivity();
    //   return getNetworkStatus(status);
    // } else {
    //   return NetworkStatus.Online;
    // }
    return NetworkStatus.Online;
  }
}
