import 'package:clay_containers/clay_containers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminBusManagementScreen extends StatefulWidget {
  const AdminBusManagementScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  _AdminBusManagementScreenState createState() => _AdminBusManagementScreenState();
}

class _AdminBusManagementScreenState extends State<AdminBusManagementScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;

  List<BusBaseDetails> buses = [];
  List<BusDriverBean> drivers = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetDriversResponse getDriversResponse = await getDrivers(GetDriversRequest(schoolId: widget.adminProfile.schoolId));
    if (getDriversResponse.httpStatus != "OK" || getDriversResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        drivers = getDriversResponse.drivers?.map((e) => e!).toList() ?? [];
      });
    }
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
              children: buses.map((e) => eachBusWidget(e)).toList(),
            ),
      floatingActionButton: _isLoading || widget.adminProfile.isMegaAdmin
          ? null
          : _isEditMode && buses.where((e) => e.busId == null).isEmpty
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
          buses.add(BusBaseDetails(
            schoolId: widget.adminProfile.schoolId,
            status: 'active',
          )
            ..isEditMode = true
            ..busNameController.text = ""
            ..regNoController.text = "");
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
          if (buses.where((e) => e.busId == null).isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Save changes for bus: ${buses.where((e) => e.isEditMode).firstOrNull?.busName ?? "-"} to continue.."),
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

  Widget eachBusWidget(BusBaseDetails bus) {
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
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isEditMode)
                Row(
                  children: [
                    const Expanded(
                      child: Text(""),
                    ),
                    if (bus.isEditMode) cancelButtonForBus(bus),
                    if (bus.isEditMode)
                      const SizedBox(
                        width: 10,
                      ),
                    if (bus.isEditMode && bus.busId != null) deleteButtonForBus(bus),
                    if (bus.isEditMode)
                      const SizedBox(
                        width: 10,
                      ),
                    editButtonForBus(bus),
                  ],
                ),
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
                          busNameWidget(bus),
                          const SizedBox(
                            height: 10,
                          ),
                          registrationNumberWidget(bus),
                          const SizedBox(
                            height: 10,
                          ),
                          busRouteWidget(bus),
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
                      bus.busDriverProfilePhotoUrl == null
                          ? SvgPicture.asset(
                              "assets/images/bus_driver.svg",
                              width: 75,
                              height: 75,
                            )
                          : Image.network(
                              bus.busDriverProfilePhotoUrl!,
                              width: 75,
                              height: 75,
                              fit: BoxFit.scaleDown,
                            ),
                      const SizedBox(
                        height: 5,
                      ),
                      busDriverNameWidget(bus)
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

  Widget busDriverNameWidget(BusBaseDetails bus) {
    return bus.isEditMode
        ? Row(
            children: [
              DropdownButton(
                  value: drivers.where((e) => e.userId == bus.busDriverId).firstOrNull,
                  hint: const Text("Driver"),
                  items: drivers
                      .map((e) => DropdownMenuItem(
                            child: Text(e.userName ?? "-"),
                            value: e,
                          ))
                      .toList(),
                  onChanged: (BusDriverBean? newDriver) {
                    if (newDriver?.userId != null && buses.where((e) => e.status == 'active').map((e) => e.busDriverId).contains(newDriver?.userId)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Bus driver already mapped to another bus.."),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      bus.busDriverId = newDriver?.userId;
                      bus.busDriverName = newDriver?.userName;
                      bus.busDriverProfilePhotoUrl = newDriver?.userPhotoUrl;
                    });
                  }),
              InkWell(
                child: const Icon(
                  Icons.clear,
                ),
                onTap: () {
                  setState(() {
                    bus.busDriverId = null;
                    bus.busDriverProfilePhotoUrl = null;
                    bus.busDriverName = null;
                  });
                },
              ),
            ],
          )
        : Center(
            child: Text(
              bus.busDriverName ?? "-",
            ),
          );
  }

  Widget editButtonForBus(BusBaseDetails bus) {
    return GestureDetector(
      onTap: () async {
        if (bus.isEditMode) {
          if ((bus.busName ?? '') == '') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Bus name is mandatory.."),
              ),
            );
            return;
          }
          _createOrUpdateBus(bus);
        } else {
          setState(() {
            bus.isEditMode = true;
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
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(5),
          child: bus.isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
        ),
      ),
    );
  }

  Future<void> _createOrUpdateBus(BusBaseDetails bus) async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Bus Management'),
          content: Text("Are you sure to save bus ${bus.busName}?"),
          actions: <Widget>[
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _isLoading = true;
                });
                if (bus.toJson() != bus.origJson()) {
                  CreateOrUpdateBusRequest createOrUpdateBusRequest = CreateOrUpdateBusRequest(
                    schoolId: widget.adminProfile.schoolId,
                    agent: widget.adminProfile.userId,
                    status: bus.status,
                    busDriverId: bus.busDriverId,
                    busId: bus.busId,
                    busName: bus.busName,
                    noOfSeats: bus.noOfSeats,
                    regNo: bus.regNo,
                  );
                  CreateOrUpdateBusResponse createOrUpdateBusResponse = await createOrUpdateBus(createOrUpdateBusRequest);
                  if (createOrUpdateBusResponse.httpStatus != "OK" || createOrUpdateBusResponse.responseStatus != "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Something went wrong! Try again later.."),
                      ),
                    );
                  } else {
                    setState(() {
                      bus.busId = createOrUpdateBusResponse.busId;
                      bus.isEditMode = false;
                    });
                  }
                }
                setState(() {
                  _isLoading = false;
                });
                setState(() {
                  bus.isEditMode = false;
                });
              },
            ),
            TextButton(
              child: const Text("NO"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Widget deleteButtonForBus(BusBaseDetails bus) {
    return GestureDetector(
      onTap: () async {
        await _deleteBus(bus);
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

  Future<void> _deleteBus(BusBaseDetails bus) async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Bus Management'),
          content: Text("Are you sure to delete bus ${bus.busName ?? ""}?"),
          actions: <Widget>[
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                Navigator.pop(context);
                if (bus.busId == null) {
                  setState(() {
                    buses.remove(bus);
                  });
                  return;
                }
                setState(() {
                  _isLoading = true;
                });
                CreateOrUpdateBusResponse createOrUpdateBusResponse = await createOrUpdateBus(CreateOrUpdateBusRequest(
                  busId: bus.busId,
                  status: "inactive",
                  agent: widget.adminProfile.userId,
                ));
                if (createOrUpdateBusResponse.httpStatus != "OK" || createOrUpdateBusResponse.responseStatus != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                } else {
                  setState(() {
                    bus.isEditMode = false;
                    buses.remove(bus);
                  });
                }
                setState(() {
                  _isLoading = false;
                });
                setState(() {
                  bus.isEditMode = false;
                });
              },
            ),
            TextButton(
              child: const Text("NO"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Widget cancelButtonForBus(BusBaseDetails bus) {
    return GestureDetector(
      onTap: () async {
        if (bus.busId == null) {
          setState(() {
            buses.remove(bus);
          });
          return;
        }
        setState(() {
          _isLoading = true;
        });
        BusBaseDetails oldBusState = BusBaseDetails.fromJson(bus.origJson());
        setState(() {
          bus.busName = oldBusState.busName;
          bus.regNo = oldBusState.regNo;
          bus.busDriverId = oldBusState.busDriverId;
          bus.busDriverName = oldBusState.busDriverName;
          bus.busDriverProfilePhotoUrl = oldBusState.busDriverProfilePhotoUrl;
        });
        setState(() {
          _isLoading = false;
        });
        setState(() {
          bus.isEditMode = false;
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

  Widget busRouteWidget(BusBaseDetails bus) {
    return Text(
      "Bus Route: ${bus.busRouteInfo?.busRouteName ?? "-"}",
    );
  }

  Widget registrationNumberWidget(BusBaseDetails bus) {
    return bus.isEditMode
        ? TextField(
            controller: bus.regNoController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              labelText: 'Registration Number',
              hintText: 'Registration Number',
              contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
            ),
            onChanged: (String e) {
              setState(() {
                bus.regNo = e;
              });
            },
            style: const TextStyle(
              fontSize: 12,
            ),
            autofocus: true,
          )
        : Text(
            "Registration number: ${bus.regNo ?? "-"}",
          );
  }

  Widget busNameWidget(BusBaseDetails bus) {
    return bus.isEditMode
        ? TextField(
            controller: bus.busNameController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              labelText: 'Bus Name',
              hintText: 'Bus Name',
              contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
            ),
            onChanged: (String e) {
              setState(() {
                bus.busName = e;
              });
            },
            style: const TextStyle(
              fontSize: 12,
            ),
            autofocus: true,
          )
        : Text(
            bus.busName ?? "-",
            style: const TextStyle(
              fontSize: 18,
            ),
          );
  }
}
