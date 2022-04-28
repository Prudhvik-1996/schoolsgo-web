import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/bus/modal/bus_positions.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/map_widgets/map_widget.dart';
import 'package:schoolsgo_web/src/common_components/map_widgets/modal/bus_lat_long.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminBusTrackingScreen extends StatefulWidget {
  const AdminBusTrackingScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  _AdminBusTrackingScreenState createState() => _AdminBusTrackingScreenState();
}

class _AdminBusTrackingScreenState extends State<AdminBusTrackingScreen> {
  bool _isLoading = true;
  List<BusBaseDetails> buses = [];

  final double _defaultBusLatitude = 17.302;
  final double _defaultBusLongitude = 78.526;
  bool _darkMode = false;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => _loadBusPositions());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetBusesBaseDetailsResponse getBusesBaseDetailsResponse = await getBusesBaseDetails(GetBusesBaseDetailsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getBusesBaseDetailsResponse.httpStatus != "OK" || getBusesBaseDetailsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        buses = getBusesBaseDetailsResponse.busBaseDetailsList?.map((e) => e!).toList() ?? [];
      });
    }
    await _loadBusPositions();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadBusPositions() async {
    GetBusPositionResponse getBusPositionResponse = await getBusPosition(GetBusPositionRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    List<BusLocation> busLocations = (getBusPositionResponse.busLocationList ?? []).where((e) => e != null).map((e) => e!).toList();
    for (var eachBus in buses) {
      setState(() {
        eachBus.busLatLong = busLocations
                .where((e) => e.busId == eachBus.busId)
                .map((e) => BusLatLong(
                      schoolId: eachBus.schoolId,
                      schoolName: eachBus.schoolName,
                      busId: eachBus.busId,
                      busName: eachBus.busName,
                      driverId: eachBus.busDriverId,
                      driverName: eachBus.busDriverName,
                      latitude: e.latitude ?? _defaultBusLatitude,
                      longitude: e.longitude ?? _defaultBusLongitude,
                    ))
                .toList()
                .reversed
                .firstOrNull ??
            BusLatLong(
              schoolId: eachBus.schoolId,
              schoolName: eachBus.schoolName,
              busId: eachBus.busId,
              busName: eachBus.busName,
              driverId: eachBus.busDriverId,
              driverName: eachBus.busDriverName,
              latitude: _defaultBusLatitude,
              longitude: _defaultBusLongitude,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Tracking"),
        actions: [
          IconButton(
            tooltip: 'Toggle Dark Mode',
            onPressed: () {
              setState(() {
                _darkMode = !_darkMode;
              });
            },
            icon: const Icon(Icons.wb_sunny),
          ),
        ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : MapWidget(
              isDarkMode: _darkMode,
              markers: buses.map((e) => e.busLatLong!).toList(),
            ),
    );
  }
}
