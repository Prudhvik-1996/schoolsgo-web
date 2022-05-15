import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:schoolsgo_web/src/common_components/network_status/constants/network_status.dart';

class NetworkStatusService {
  StreamController<NetworkStatus> networkStatusController = StreamController<NetworkStatus>();

  NetworkStatusService() {
    Connectivity().onConnectivityChanged.listen((status) {
      networkStatusController.add(getNetworkStatus(status));
    });
  }

  NetworkStatus getNetworkStatus(ConnectivityResult status) {
    return status == ConnectivityResult.none ? NetworkStatus.Offline : NetworkStatus.Online;
  }

  Future<NetworkStatus> getInitialStatus() async {
    var status = await Connectivity().checkConnectivity();
    return getNetworkStatus(status);
  }
}
