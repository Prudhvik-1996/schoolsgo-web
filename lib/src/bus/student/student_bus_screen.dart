import 'dart:async';

import 'package:clay_containers/widgets/clay_container.dart';
// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schoolsgo_web/src/bus/modal/bus_positions.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/map_widgets/map_widget.dart';
import 'package:schoolsgo_web/src/common_components/map_widgets/modal/bus_lat_long.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class StudentBusScreen extends StatefulWidget {
  const StudentBusScreen({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;

  @override
  State<StudentBusScreen> createState() => _StudentBusScreenState();
}

class _StudentBusScreenState extends State<StudentBusScreen> {
  bool _isLoading = true;
  bool _darkMode = false;

  BusRouteInfo? busRouteInfo;
  BusBaseDetails? busBaseDetails;
  final double _defaultBusLatitude = 17.302;
  final double _defaultBusLongitude = 78.526;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => _loadBusPositions());
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetBusRouteDetailsResponse getBusRouteDetailsResponse = await getBusRouteDetails(GetBusRouteDetailsRequest(
      sectionId: widget.studentProfile.sectionId,
      studentId: widget.studentProfile.studentId,
      schoolId: widget.studentProfile.schoolId,
    ));
    if (getBusRouteDetailsResponse.httpStatus != "OK" || getBusRouteDetailsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        busRouteInfo = (getBusRouteDetailsResponse.busRouteInfoBeanList ?? []).map((e) => e!).toList().firstOrNull;
      });
    }
    if (busRouteInfo?.busId != null) {
      GetBusesBaseDetailsResponse getBusesBaseDetailsResponse = await getBusesBaseDetails(GetBusesBaseDetailsRequest(
        schoolId: widget.studentProfile.schoolId,
        busId: busRouteInfo?.busId,
      ));
      if (getBusesBaseDetailsResponse.httpStatus != "OK" || getBusesBaseDetailsResponse.responseStatus != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      } else {
        setState(() {
          busBaseDetails = getBusesBaseDetailsResponse.busBaseDetailsList?.map((e) => e!).toList().firstOrNull;
        });
      }
    }
    if (busRouteInfo != null && busBaseDetails != null) {
      await _loadBusPositions();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadBusPositions() async {
    if (busBaseDetails == null) return;
    GetBusPositionResponse getBusPositionResponse = await getBusPosition(GetBusPositionRequest(
      schoolId: widget.studentProfile.schoolId,
      busId: busRouteInfo?.busId,
      driverId: busRouteInfo?.busDriverId,
    ));
    List<BusLocation> busLocations = (getBusPositionResponse.busLocationList ?? []).where((e) => e != null).map((e) => e!).toList();
    setState(() {
      busBaseDetails?.busLatLong = busLocations
              .where((e) => e.busId == busBaseDetails?.busId)
              .map((e) => BusLatLong(
                    schoolId: busBaseDetails?.schoolId,
                    schoolName: busBaseDetails?.schoolName,
                    busId: busBaseDetails?.busId,
                    busName: busBaseDetails?.busName,
                    driverId: busBaseDetails?.busDriverId,
                    driverName: busBaseDetails?.busDriverName,
                    latitude: e.latitude ?? _defaultBusLatitude,
                    longitude: e.longitude ?? _defaultBusLongitude,
                  ))
              .toList()
              .reversed
              .firstOrNull ??
          BusLatLong(
            schoolId: busBaseDetails?.schoolId,
            schoolName: busBaseDetails?.schoolName,
            busId: busBaseDetails?.busId,
            busName: busBaseDetails?.busName,
            driverId: busBaseDetails?.busDriverId,
            driverName: busBaseDetails?.busDriverName,
            latitude: _defaultBusLatitude,
            longitude: _defaultBusLongitude,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: _darkMode
            ? Theme.of(context).textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                )
            : Theme.of(context).textTheme.apply(
                  bodyColor: Colors.black,
                  displayColor: Colors.black,
                ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bus"),
          actions: [
            buildRoleButtonForAppBar(context, widget.studentProfile),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: IconButton(
                tooltip: 'Toggle Dark Mode',
                onPressed: () {
                  setState(() {
                    _darkMode = !_darkMode;
                  });
                },
                icon: const Icon(Icons.wb_sunny),
              ),
            ),
          ],
        ),
        drawer: StudentAppDrawer(
          studentProfile: widget.studentProfile,
        ),
        body: _isLoading
            ? Center(
                child: Image.asset(
                  'assets/images/eis_loader.gif',
                  height: 500,
                  width: 500,
                ),
              )
            : busBaseDetails == null || busRouteInfo == null
                ? const Center(
                    child: Text("Seems like you re not assigned to any bus.."),
                  )
                : Stack(
                    children: [
                      MapWidget(
                        isDarkMode: _darkMode,
                        markers: [busBaseDetails!.busLatLong!],
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: busForRouteWidget(busBaseDetails),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget busForRouteWidget(BusBaseDetails? bus) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        surfaceColor: _darkMode ? darkThemeColor : lightThemeColor,
        parentColor: _darkMode ? darkThemeColor : lightThemeColor,
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            bus?.busName ?? "-",
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Registration number: ${bus?.regNo ?? "-"}",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      bus == null || bus.busDriverProfilePhotoUrl == null
                          ? SvgPicture.asset(
                              "assets/images/bus_driver.svg",
                              width: 45,
                              height: 45,
                            )
                          : Image.network(
                              bus.busDriverProfilePhotoUrl!,
                              width: 45,
                              height: 45,
                              fit: BoxFit.scaleDown,
                            ),
                      const SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: Text(
                          bus?.busDriverName ?? "-",
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
