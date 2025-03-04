import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_stepper/custom_stepper.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class AdminAssignBusFeeScreen extends StatefulWidget {
  const AdminAssignBusFeeScreen({Key? key, required this.adminProfile}) : super(key: key);

  final AdminProfile adminProfile;

  @override
  _AdminAssignBusFeeScreenState createState() => _AdminAssignBusFeeScreenState();
}

class _AdminAssignBusFeeScreenState extends State<AdminAssignBusFeeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  bool _isEditMode = false;

  late TransportFeeAssignmentTypeBean transportFeeAssignmentTypeBean;
  List<BusRouteInfo> busRouteInfoBeans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      transportFeeAssignmentTypeBean = TransportFeeAssignmentTypeBean(
        schoolId: widget.adminProfile.schoolId,
      );
    });
    GetBusRouteDetailsResponse getBusRouteDetailsResponse = await getBusRouteDetails(GetBusRouteDetailsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getBusRouteDetailsResponse.httpStatus != "OK" || getBusRouteDetailsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        busRouteInfoBeans = getBusRouteDetailsResponse.busRouteInfoBeanList?.map((e) => e!).toList() ?? [];
      });
    }
    GetTransportFeeAssignmentTypeResponse getTransportFeeAssignmentTypeResponse = await getTransportFeeAssignmentType(TransportFeeAssignmentTypeBean(
      schoolId: widget.adminProfile.schoolId,
      status: "active",
    ));
    if (getTransportFeeAssignmentTypeResponse.httpStatus != "OK" || getTransportFeeAssignmentTypeResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      if (getTransportFeeAssignmentTypeResponse.transportFeeAssignmentTypeBean != null) {
        setState(() {
          transportFeeAssignmentTypeBean = getTransportFeeAssignmentTypeResponse.transportFeeAssignmentTypeBean!;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Assign Bus Fees"),
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled()
          ? null
          : AdminAppDrawer(
              adminProfile: widget.adminProfile,
            ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                _assignBusFeesOverWidget(),
                if (transportFeeAssignmentTypeBean.assignmentType == "b") _routeWiseFeeWidget(),
                if (transportFeeAssignmentTypeBean.assignmentType == "c") _stopWiseFeeWidgets(),
              ],
            ),
      floatingActionButton: _buildEditButton(context),
    );
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });
    UpdateBusFaresRequest? updateBusFaresRequest;
    if (transportFeeAssignmentTypeBean.assignmentType == "a") {
      List<BusRouteInfo> updateBusFares = [];
      busRouteInfoBeans.forEach((eachRoute) {
        BusRouteInfo updatedRouteFare = BusRouteInfo(
          busRouteId: eachRoute.busRouteId,
          agent: widget.adminProfile.userId,
          schoolId: widget.adminProfile.schoolId,
          fare: 0,
          busRouteStopsList: [],
        );
        eachRoute.busRouteStopsList?.forEach((eachStop) {
          if (eachStop != null) {
            updatedRouteFare.busRouteStopsList!.add(BusRouteStop(
              schoolId: eachStop.schoolId,
              agent: widget.adminProfile.userId,
              fare: 0,
              routeId: eachStop.routeId,
              busRouteStopId: eachStop.busRouteStopId,
            ));
          }
        });
        updateBusFares.add(updatedRouteFare);
      });
      List<StopWiseStudentUpdateBean> stopWiseStudentBeans = busRouteInfoBeans
          .map((e) => e.busRouteStopsList ?? [])
          .expand((i) => i)
          .map((e) => (e?.students) ?? [])
          .expand((i) => i)
          .where((e) => e != null)
          .map((e) => e!)
          .map((e) {
        return StopWiseStudentUpdateBean(
          newStopId: e.busStopId,
          oldStopId: e.busStopId,
          studentId: e.studentId,
        );
      }).toList();
      updateBusFaresRequest = UpdateBusFaresRequest(
        schoolId: widget.adminProfile.schoolId,
        agent: widget.adminProfile.userId,
        amount: transportFeeAssignmentTypeBean.amount,
        assignmentType: transportFeeAssignmentTypeBean.assignmentType,
        routes: updateBusFares,
        stopWiseStudents: stopWiseStudentBeans,
      );
    } else if (transportFeeAssignmentTypeBean.assignmentType == "b") {
      List<BusRouteInfo> updateBusFares = [];
      busRouteInfoBeans.forEach((eachRoute) {
        BusRouteInfo updatedRouteFare = BusRouteInfo(
          busRouteId: eachRoute.busRouteId,
          agent: widget.adminProfile.userId,
          schoolId: widget.adminProfile.schoolId,
          fare: eachRoute.fare,
          busRouteStopsList: [],
        );
        eachRoute.busRouteStopsList?.forEach((eachStop) {
          if (eachStop != null) {
            updatedRouteFare.busRouteStopsList!.add(BusRouteStop(
              schoolId: eachStop.schoolId,
              agent: widget.adminProfile.userId,
              fare: 0,
            ));
          }
        });
        updateBusFares.add(updatedRouteFare);
      });
      List<StopWiseStudentUpdateBean> stopWiseStudentBeans = busRouteInfoBeans
          .map((e) => e.busRouteStopsList ?? [])
          .expand((i) => i)
          .map((e) => (e?.students) ?? [])
          .expand((i) => i)
          .where((e) => e != null)
          .map((e) => e!)
          .map((e) {
        return StopWiseStudentUpdateBean(
          newStopId: e.busStopId,
          oldStopId: e.busStopId,
          studentId: e.studentId,
        );
      }).toList();
      updateBusFaresRequest = UpdateBusFaresRequest(
        schoolId: widget.adminProfile.schoolId,
        agent: widget.adminProfile.userId,
        amount: null,
        assignmentType: transportFeeAssignmentTypeBean.assignmentType,
        routes: updateBusFares,
        stopWiseStudents: stopWiseStudentBeans,
      );
    } else if (transportFeeAssignmentTypeBean.assignmentType == "c") {
      List<BusRouteInfo> updateBusFares = [];
      busRouteInfoBeans.forEach((eachRoute) {
        BusRouteInfo updatedRouteFare = BusRouteInfo(
          busRouteId: eachRoute.busRouteId,
          agent: widget.adminProfile.userId,
          schoolId: widget.adminProfile.schoolId,
          fare: 0,
          busRouteStopsList: [],
        );
        eachRoute.busRouteStopsList?.forEach((eachStop) {
          if (eachStop != null) {
            updatedRouteFare.busRouteStopsList!.add(eachStop
              ..schoolId = eachStop.schoolId
              ..agent = widget.adminProfile.userId
              ..fare = eachStop.fare);
          }
        });
        updateBusFares.add(updatedRouteFare);
      });
      List<StopWiseStudentUpdateBean> stopWiseStudentBeans = busRouteInfoBeans
          .map((e) => e.busRouteStopsList ?? [])
          .expand((i) => i)
          .map((e) => (e?.students) ?? [])
          .expand((i) => i)
          .where((e) => e != null)
          .map((e) => e!)
          .map((e) {
        return StopWiseStudentUpdateBean(
          newStopId: e.busStopId,
          oldStopId: e.busStopId,
          studentId: e.studentId,
        );
      }).toList();
      updateBusFaresRequest = UpdateBusFaresRequest(
        schoolId: widget.adminProfile.schoolId,
        agent: widget.adminProfile.userId,
        amount: null,
        assignmentType: transportFeeAssignmentTypeBean.assignmentType,
        routes: updateBusFares,
        stopWiseStudents: stopWiseStudentBeans,
      );
    }
    if (updateBusFaresRequest != null) {
      UpdateBusFaresResponse updateBusFaresResponse = await updateBusFares(updateBusFaresRequest);
      if (updateBusFaresResponse.httpStatus != "OK" || updateBusFaresResponse.responseStatus != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Updated successfully.."),
          ),
        );
        _loadData();
        setState(() {
          _isEditMode = false;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isEditMode) {
          showDialog(
            context: _scaffoldKey.currentContext!,
            builder: (currentContext) {
              return AlertDialog(
                title: const Text("Student - Bus Assignment"),
                content: const Text("Are you sure you want to save changes?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _saveChanges();
                    },
                    child: const Text("YES"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _loadData();
                      setState(() {
                        _isEditMode = false;
                      });
                    },
                    child: const Text("NO"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            _isEditMode = !_isEditMode;
          });
        }
      },
      child: _isEditMode
          ? ClayButton(
              color: clayContainerColor(context),
              height: 50,
              width: 50,
              borderRadius: 100,
              spread: 2,
              child: const Icon(
                Icons.check,
              ),
            )
          : ClayButton(
              color: clayContainerColor(context),
              height: 50,
              width: 50,
              borderRadius: 100,
              spread: 2,
              child: const Icon(
                Icons.edit,
              ),
            ),
    );
  }

  Widget _assignBusFeesOverWidget() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: const Text("Assign Bus Fees Over: "),
              ),
            ),
            if (!_isEditMode)
              Container(
                margin: const EdgeInsets.all(20),
                child: Text(
                  transportFeeAssignmentTypeBean.assignmentType == null
                      ? "-"
                      : transportFeeAssignmentTypeBean.assignmentType == "a"
                          ? "School"
                          : transportFeeAssignmentTypeBean.assignmentType == "b"
                              ? "Routes"
                              : "Stops",
                ),
              ),
            if (_isEditMode)
              Container(
                margin: const EdgeInsets.all(20),
                child: DropdownButton(
                  value: transportFeeAssignmentTypeBean.assignmentType,
                  items: ["a", "b", "c"]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e == "a"
                              ? "School"
                              : e == "b"
                                  ? "Routes"
                                  : "Stops"),
                        ),
                      )
                      .toList(),
                  onChanged: (String? e) {
                    setState(() {
                      transportFeeAssignmentTypeBean.assignmentType = e;
                    });
                  },
                ),
              ),
            if (transportFeeAssignmentTypeBean.assignmentType == "a")
              SizedBox(
                width: 100,
                height: 75,
                child: Center(
                  child: TextField(
                    enabled: _isEditMode,
                    controller: transportFeeAssignmentTypeBean.amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      prefixText: INR_SYMBOL,
                      label: const Text(
                        'Amount',
                        textAlign: TextAlign.end,
                      ),
                      hintText: 'Amount',
                      contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        try {
                          final text = newValue.text;
                          if (text.isNotEmpty) double.parse(text);
                          return newValue;
                        } catch (e) {}
                        return oldValue;
                      }),
                    ],
                    onChanged: (String e) {
                      setState(() {
                        transportFeeAssignmentTypeBean.amount = ((double.tryParse(e) ?? 0) * 100).toInt();
                      });
                    },
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    autofocus: true,
                  ),
                ),
              ),
            if (transportFeeAssignmentTypeBean.assignmentType == "a")
              const SizedBox(
                width: 15,
              ),
          ],
        ),
      ),
    );
  }

  Widget _routeWiseFeeWidget() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        emboss: true,
        child: Column(
          children: busRouteInfoBeans
              .map((e) => Container(
                    margin: const EdgeInsets.all(20),
                    child: ClayContainer(
                      depth: 20,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 2,
                      borderRadius: 10,
                      emboss: false,
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Text(e.busRouteName ?? "-"),
                            ),
                            SizedBox(
                              width: 100,
                              height: 75,
                              child: Center(
                                child: TextField(
                                  enabled: _isEditMode,
                                  controller: e.fareEditingController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    prefixText: INR_SYMBOL,
                                    label: const Text(
                                      'Amount',
                                      textAlign: TextAlign.end,
                                    ),
                                    hintText: 'Amount',
                                    contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                                    TextInputFormatter.withFunction((oldValue, newValue) {
                                      try {
                                        final text = newValue.text;
                                        if (text.isNotEmpty) double.parse(text);
                                        return newValue;
                                      } catch (e) {}
                                      return oldValue;
                                    }),
                                  ],
                                  onChanged: (String t) {
                                    setState(() {
                                      e.fare = ((double.tryParse(t) ?? 0) * 100).toInt();
                                    });
                                  },
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                  autofocus: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _stopWiseFeeWidgets() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        emboss: true,
        child: Column(
          children: busRouteInfoBeans
              .map(
                (e) => Container(
                  margin: const EdgeInsets.all(20),
                  child: ClayContainer(
                    depth: 20,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 2,
                    borderRadius: 10,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(20),
                          child: Text(
                            e.busRouteName ?? "-",
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                        busRouteStopsStepper(e),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  CustomStepper busRouteStopsStepper(BusRouteInfo busRouteInfo) {
    List<BusRouteStop> busStops = (busRouteInfo.busRouteStopsList ?? []).where((e) => e != null && e.status == 'active').map((e) => e!).toList();
    busStops.sort((a, b) => (a.terminalNumber ?? 0).compareTo(b.terminalNumber ?? 0));
    List<CustomStep> widgets = [];
    for (int stepIndex = 0; stepIndex < busStops.length; stepIndex++) {
      widgets.add(
        CustomStep(
          isActive: busRouteInfo.expandAllStops,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  busStops[stepIndex].terminalName ?? "-",
                ),
              ),
              SizedBox(
                width: 100,
                height: 75,
                child: Center(
                  child: TextField(
                    enabled: _isEditMode,
                    controller: busStops[stepIndex].fareEditingController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      prefixText: INR_SYMBOL,
                      label: const Text(
                        'Amount',
                        textAlign: TextAlign.end,
                      ),
                      hintText: 'Amount',
                      contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        try {
                          final text = newValue.text;
                          if (text.isNotEmpty) double.parse(text);
                          return newValue;
                        } catch (e) {}
                        return oldValue;
                      }),
                    ],
                    onChanged: (String t) {
                      setState(() {
                        busStops[stepIndex].fare = ((double.tryParse(t) ?? 0) * 100).toInt();
                      });
                    },
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    autofocus: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return CustomStepper(
      areAllStepsExpanded: true,
      physics: const BouncingScrollPhysics(),
      canRequestFocus: false,
      lineHeight: 8.0,
      type: StepperType.vertical,
      steps: widgets,
      length: widgets.length,
      onStepTapped: (int newStep) {},
      controlsBuilder: (BuildContext context, CustomControlsDetails details) {
        return Container();
      },
    );
  }
}
