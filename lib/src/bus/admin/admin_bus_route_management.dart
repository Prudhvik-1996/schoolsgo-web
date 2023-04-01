import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_stepper/custom_stepper.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class AdminRouteManagementScreen extends StatefulWidget {
  const AdminRouteManagementScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  _AdminRouteManagementScreenState createState() => _AdminRouteManagementScreenState();
}

class _AdminRouteManagementScreenState extends State<AdminRouteManagementScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<BusBaseDetails> buses = [];
  List<BusRouteInfo> busRouteInfoBeans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
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
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Bus Management"),
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
          : ListView(
              children: busRouteInfoBeans.map((e) => busRouteWidget(e)).toList(),
            ),
      floatingActionButton: _isLoading || widget.adminProfile.isMegaAdmin
          ? null
          : _isEditMode && busRouteInfoBeans.where((e) => e.isEditMode).isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _addNewButton(),
                    const SizedBox(
                      height: 10,
                    ),
                    _editButton(),
                  ],
                )
              : _editButton(),
    );
  }

  Widget _addNewButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          busRouteInfoBeans.add(BusRouteInfo(
            schoolId: widget.adminProfile.schoolId,
            agent: widget.adminProfile.userId,
            status: 'active',
          )
            ..isExpanded = true
            ..isEditMode = true
            ..expandAllStops = true);
        });
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 100,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _editButton() {
    return GestureDetector(
      onTap: () {
        if (_isEditMode) {
          if (busRouteInfoBeans.where((e) => e.isEditMode).firstOrNull != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text("Save changes for route: ${busRouteInfoBeans.where((e) => e.isEditMode).firstOrNull?.busRouteName ?? "-"} to continue.."),
              ),
            );
          } else {
            setState(() {
              _isEditMode = false;
            });
          }
        } else {
          setState(() {
            _isEditMode = true;
          });
        }
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 100,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: _isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
        ),
      ),
    );
  }

  Widget busRouteWidget(BusRouteInfo busRouteInfo) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              routeWidget(busRouteInfo),
              busRouteInfo.isEditMode
                  ? busForRouteWidgetEditMode(buses.where((e) => e.busId == busRouteInfo.busId).firstOrNull, busRouteInfo)
                  : busForRouteWidgetReadMode(buses.where((e) => e.busId == busRouteInfo.busId).firstOrNull, busRouteInfo),
              if (busRouteInfo.isExpanded) busRouteStopsStepper(busRouteInfo),
              if (busRouteInfo.isEditMode &&
                  busRouteInfo.isExpanded &&
                  (busRouteInfo.busRouteStopsList ?? [])
                          .where((e) => (e?.status == 'active') && (e?.terminalName ?? "").isNotEmpty)
                          .map((e) => e?.terminalName ?? "")
                          .toSet()
                          .length ==
                      (busRouteInfo.busRouteStopsList ?? []).where((e) => (e?.status == 'active')).length)
                addBusStop(busRouteInfo),
            ],
          ),
        ),
      ),
    );
  }

  Widget addBusStop(BusRouteInfo busRouteInfo) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () async {
              setState(() {
                _isLoading = true;
              });
              setState(() {
                busRouteInfo.busRouteStopsList ??= [];
                busRouteInfo.busRouteStopsList!.add(BusRouteStop(
                    status: 'active',
                    agent: widget.adminProfile.userId,
                    schoolId: widget.adminProfile.schoolId,
                    routeId: busRouteInfo.busRouteId,
                    routeName: busRouteInfo.busRouteName,
                    terminalNumber: (busRouteInfo.busRouteStopsList ?? []).length + 1,
                    busRouteStopId: null,
                    terminalName: ""));
              });
              setState(() {
                _isLoading = false;
              });
            },
            child: ClayButton(
              depth: 40,
              surfaceColor: _circleColor(),
              parentColor: clayContainerColor(context),
              spread: 2,
              borderRadius: 10,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  "Add Bus Stop",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Expanded(
          child: Text(""),
        )
      ],
    );
  }

  Color _circleColor() {
    if (!(Theme.of(context).brightness == Brightness.dark)) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.secondary;
    }
  }

  Widget busForRouteWidgetEditMode(BusBaseDetails? bus, BusRouteInfo busRouteInfo) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: DropdownButton(
            isExpanded: true,
            itemHeight: 100,
            underline: Container(),
            value: busRouteInfo.busRouteId == null ? null : buses.where((e) => e.busId == busRouteInfo.busId).firstOrNull,
            hint: const Text("Bus"),
            icon: Container(),
            onChanged: (BusBaseDetails? newBus) {
              setState(() {
                busRouteInfo.busDriverId = newBus?.busDriverId;
                busRouteInfo.busDriverProfilePhotoUrl = newBus?.busDriverProfilePhotoUrl;
                busRouteInfo.busDriverName = newBus?.busDriverName;
                busRouteInfo.busName = newBus?.busName;
                busRouteInfo.busId = newBus?.busId;
              });
            },
            items: buses
                .where((eachBus) => eachBus.busRouteInfo != null)
                .map(
                  (e) => DropdownMenuItem(
                    child: ClayButton(
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 10,
                      depth: 40,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(e.busName ?? "-"),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    height: 20,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text("Registration Number: ${e.regNo ?? "-"}"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                SizedBox(
                                  height: 20,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Driver: ${e.busDriverName ?? "-"}",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    value: e,
                  ),
                )
                .toList(),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: InkWell(
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                Icons.clear,
              ),
            ),
            onTap: () {
              setState(() {
                busRouteInfo.busDriverId = null;
                busRouteInfo.busDriverProfilePhotoUrl = null;
                busRouteInfo.busDriverName = null;
                busRouteInfo.busName = null;
                busRouteInfo.busId = null;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget busForRouteWidgetReadMode(BusBaseDetails? bus, BusRouteInfo busRouteInfo) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
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

  Widget routeWidget(BusRouteInfo busRouteInfo) {
    return Column(
      children: [
        const SizedBox(
          height: 12,
        ),
        if (_isEditMode) buttonsForBusRouteInfo(busRouteInfo),
        if (_isEditMode)
          const SizedBox(
            height: 12,
          ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              if ((_isEditMode && busRouteInfo.isEditMode) || !_isEditMode) {
                setState(() {
                  busRouteInfo.isExpanded = !busRouteInfo.isExpanded;
                });
              }
            },
            child: busRouteInfo.isEditMode
                ? TextField(
                    controller: busRouteInfo.routeNameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      errorText: _errorTextForBusRouteNameController(busRouteInfo),
                      border: const UnderlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      labelText: 'Route Name',
                      hintText: 'Route Name',
                      contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    ),
                    onChanged: (String e) {
                      setState(() {
                        busRouteInfo.busRouteName = e;
                      });
                    },
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    autofocus: true,
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          busRouteInfo.busRouteName ?? "-",
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: busRouteInfo.isExpanded ? const Icon(Icons.keyboard_arrow_up) : const Icon(Icons.keyboard_arrow_down),
                      )
                    ],
                  ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }

  Widget buttonsForBusRouteInfo(BusRouteInfo busRouteInfo) {
    return Row(
      children: [
        const Expanded(
          child: Text(""),
        ),
        if (busRouteInfo.isEditMode) cancelButtonForBusRouteInfo(busRouteInfo),
        if (busRouteInfo.isEditMode)
          const SizedBox(
            width: 10,
          ),
        if (busRouteInfo.isEditMode && busRouteInfo.busRouteId != null) deleteButtonForBusRouteInfo(busRouteInfo),
        if (busRouteInfo.isEditMode && busRouteInfo.busRouteId != null)
          const SizedBox(
            width: 10,
          ),
        editButtonForBusRouteInfo(busRouteInfo),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Widget cancelButtonForBusRouteInfo(BusRouteInfo busRouteInfo) {
    return GestureDetector(
      onTap: () async {
        if (busRouteInfo.busRouteId == null) {
          setState(() {
            busRouteInfoBeans.remove(busRouteInfo);
          });
          return;
        }
        setState(() {
          _isLoading = true;
        });
        setState(() {
          BusRouteInfo.deepCloneFromOriginalJson(busRouteInfo);
        });
        setState(() {
          busRouteInfo.isEditMode = false;
        });
        setState(() {
          _isLoading = false;
        });
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 100,
        child: Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(5),
          child: const Icon(Icons.clear),
        ),
      ),
    );
  }

  Widget deleteButtonForBusRouteInfo(BusRouteInfo busRouteInfo) {
    return GestureDetector(
      onTap: () async {
        // TODO await _deleteBus(bus);
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 100,
        child: Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(5),
          child: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget editButtonForBusRouteInfo(BusRouteInfo busRouteInfo) {
    return GestureDetector(
      onTap: () async {
        if (busRouteInfo.isEditMode) {
          if ((busRouteInfo.busRouteName ?? '') == '') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Route name is mandatory.."),
              ),
            );
            return;
          } else if (busRouteInfoBeans
              .where((e) =>
                  busRouteInfoBeans.indexOf(e) != busRouteInfoBeans.indexOf(busRouteInfo) &&
                  busRouteInfo.routeNameController.text.trim().toLowerCase() == e.routeNameController.text.trim().toLowerCase())
              .isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Route name should be unique for a route.."),
              ),
            );
            return;
          } else if ((busRouteInfo.busRouteStopsList?.map((e) => e?.terminalNameController.text.trim()))?.contains("") ?? true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Stop Name is mandatory"),
              ),
            );
            return;
          } else {
            BusRouteInfo oldBusRouteInfo = BusRouteInfo.fromJson(busRouteInfo.origJson());
            if (oldBusRouteInfo.toJson() != busRouteInfo.toJson()) {
              await _saveChanges(busRouteInfo);
            }
          }
        } else {
          if (busRouteInfoBeans.where((e) => e.isEditMode).isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("First save changes for route: ${busRouteInfoBeans.where((e) => e.isEditMode).firstOrNull?.busRouteName ?? "-"}.."),
              ),
            );
            return;
          } else {
            for (var eachBusRouteInfo in busRouteInfoBeans) {
              setState(() {
                eachBusRouteInfo.isExpanded = false;
              });
            }
            setState(() {
              busRouteInfo.isEditMode = true;
              busRouteInfo.isExpanded = true;
            });
          }
        }
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 100,
        child: Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(5),
          child: busRouteInfo.isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
        ),
      ),
    );
  }

  Future<void> _saveChanges(BusRouteInfo busRouteInfo) async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (dialogueContext) {
        return AlertDialog(
          content: const Text("Are you sure you want to save changes"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _isLoading = true;
                });
                CreateOrUpdateBusRouteDetailsResponse createOrUpdateBusRouteDetailsResponse =
                    await createOrUpdateBusRouteDetails(CreateOrUpdateBusRouteDetailsRequest(
                  schoolId: widget.adminProfile.schoolId,
                  agent: widget.adminProfile.userId,
                  status: busRouteInfo.status,
                  busId: busRouteInfo.busId,
                  regNo: busRouteInfo.regNo,
                  rc: busRouteInfo.rc,
                  noOfSeats: busRouteInfo.noOfSeats,
                  busName: busRouteInfo.busName,
                  busDriverId: busRouteInfo.busDriverId,
                  busDriverName: busRouteInfo.busDriverName,
                  busDriverProfilePhotoUrl: null,
                  busRouteId: busRouteInfo.busRouteId,
                  busRouteName: busRouteInfo.busRouteName,
                  busRouteStopsList:
                      busRouteInfo.busRouteStopsList?.where((e) => !(const DeepCollectionEquality()).equals(e?.toJson(), e?.origJson())).toList(),
                  routeInChargeId: busRouteInfo.routeInChargeId,
                  routeInChargeName: busRouteInfo.routeInChargeName,
                ));
                if (createOrUpdateBusRouteDetailsResponse.httpStatus != "OK" || createOrUpdateBusRouteDetailsResponse.responseStatus != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                } else {
                  setState(() {
                    busRouteInfo.isEditMode = false;
                  });
                  _loadData();
                }
                setState(() {
                  _isLoading = false;
                });
              },
              child: const Text("YES"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                _loadData();
              },
              child: const Text("No"),
            ),
          ],
        );
      },
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
          title: busRouteInfo.isEditMode
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: busStops[stepIndex].terminalNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          errorText: _errorTextForBusStopNameController(busStops, stepIndex),
                          border: const UnderlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          labelText: 'Stop Name',
                          hintText: 'Stop Name',
                          contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        ),
                        onChanged: (String e) {
                          setState(() {
                            busStops[stepIndex].terminalName = e;
                          });
                        },
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        autofocus: busStops[stepIndex].terminalNameController.text.trim().isEmpty,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          busStops[stepIndex].status = 'inactive';
                          if (busRouteInfo.busRouteId == null) {
                            busStops.remove(busStops[stepIndex]);
                          }
                          for (int i = 0; i < busStops.where((eachStop) => eachStop.status == 'active').toList().length; i++) {
                            busStops.where((eachStop) => eachStop.status == 'active').toList()[i].terminalNumber = i + 1;
                            busStops.where((eachStop) => eachStop.status == 'active').toList()[i].agent = widget.adminProfile.userId;
                          }
                        });
                      },
                      child: ClayButton(
                        depth: 40,
                        surfaceColor: clayContainerColor(context),
                        parentColor: clayContainerColor(context),
                        spread: 1,
                        borderRadius: 100,
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(5),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                )
              : Text(
                  busStops[stepIndex].terminalName ?? "-",
                ),
          subtitle: Container(),
          content: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(8),
              child: ClayContainer(
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                depth: 40,
                emboss: true,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                            child: const Text("Pick up time:    "),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                            child: const Text("Drop time:    "),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          stopWisePickUpTimeWidget(busStops, stepIndex, busRouteInfo.isEditMode),
                          const SizedBox(
                            height: 8,
                          ),
                          stopWiseDropTimeWidget(busStops, stepIndex, busRouteInfo.isEditMode),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return CustomStepper(
      areAllStepsExpanded: busRouteInfo.expandAllStops,
      physics: const BouncingScrollPhysics(),
      canRequestFocus: false,
      lineHeight: 8.0,
      type: StepperType.vertical,
      steps: widgets,
      length: widgets.length,
      currentStep: busRouteInfo.currentStep,
      onStepTapped: (int newStep) {
        setState(() {
          busRouteInfo.expandAllStops = !busRouteInfo.expandAllStops;
          busRouteInfo.currentStep = newStep;
        });
      },
      // physics: const BouncingScrollPhysics(),
      onStepContinue: () {
        if (busRouteInfo.currentStep < busStops.length - 1) {
          setState(() {
            busRouteInfo.currentStep += 1;
          });
        }
      },
      onStepCancel: () {
        setState(() {
          busRouteInfo.isExpanded = false;
        });
      },
      controlsBuilder: (BuildContext context, CustomControlsDetails details) {
        return Container();
      },
    );
  }

  String? _errorTextForBusRouteNameController(BusRouteInfo busRouteInfo) {
    if ((busRouteInfo.routeNameController.text.trim()) == "") {
      return "Route Name is mandatory";
    }
    if (busRouteInfoBeans
        .where((e) =>
            busRouteInfoBeans.indexOf(e) != busRouteInfoBeans.indexOf(busRouteInfo) &&
            busRouteInfo.routeNameController.text.trim().toLowerCase() == e.routeNameController.text.trim().toLowerCase())
        .isNotEmpty) {
      return "Route name should be unique for a route";
    }
    return null;
  }

  String? _errorTextForBusStopNameController(List<BusRouteStop> busStops, int stepIndex) {
    if ((busStops[stepIndex].terminalNameController.text.trim()) == "") {
      return "Stop Name is mandatory";
    }
    if (busStops
        .where((e) =>
            busStops.indexOf(e) != stepIndex &&
            e.terminalName?.trim().toLowerCase() == busStops[stepIndex].terminalNameController.text.trim().toLowerCase())
        .isNotEmpty) {
      return "Stop name should be unique for a route";
    }
    return null;
  }

  Widget stopWisePickUpTimeWidget(List<BusRouteStop> busStops, int stepIndex, bool isEditMode) {
    if (isEditMode) {
      return GestureDetector(
        onTap: () async {
          TimeOfDay? _pickupTimePicker = await showTimePicker(
            context: context,
            initialTime: busStops[stepIndex].pickUpTime == null
                ? const TimeOfDay(hour: 0, minute: 0)
                : formatHHMMSSToTimeOfDay(busStops[stepIndex].pickUpTime!),
          );
          if (_pickupTimePicker == null || busStops[stepIndex].pickUpTime == timeOfDayToHHMMSS(_pickupTimePicker)) return;
          setState(() {
            busStops[stepIndex].pickUpTime = timeOfDayToHHMMSS(_pickupTimePicker);
          });
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text(busStops[stepIndex].pickUpTime == null ? "-" : convert24To12HourFormat(busStops[stepIndex].pickUpTime!)),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Text(busStops[stepIndex].pickUpTime == null ? "-" : convert24To12HourFormat(busStops[stepIndex].pickUpTime!)),
    );
  }

  Widget stopWiseDropTimeWidget(List<BusRouteStop> busStops, int stepIndex, bool isEditMode) {
    if (isEditMode) {
      return GestureDetector(
        onTap: () async {
          TimeOfDay? _dropTimePicker = await showTimePicker(
            context: context,
            initialTime:
                busStops[stepIndex].dropTime == null ? const TimeOfDay(hour: 0, minute: 0) : formatHHMMSSToTimeOfDay(busStops[stepIndex].dropTime!),
          );
          if (_dropTimePicker == null || busStops[stepIndex].dropTime == timeOfDayToHHMMSS(_dropTimePicker)) return;
          setState(() {
            busStops[stepIndex].dropTime = timeOfDayToHHMMSS(_dropTimePicker);
          });
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Text(busStops[stepIndex].dropTime == null ? "-" : convert24To12HourFormat(busStops[stepIndex].dropTime!))),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Text(busStops[stepIndex].dropTime == null ? "-" : convert24To12HourFormat(busStops[stepIndex].dropTime!)),
    );
  }
}
