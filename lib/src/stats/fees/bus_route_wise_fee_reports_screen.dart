import 'dart:convert';
import 'dart:html';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class BusRouteWiseFeeReportsScreen extends StatefulWidget {
  const BusRouteWiseFeeReportsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<BusRouteWiseFeeReportsScreen> createState() => _BusRouteWiseFeeReportsScreenState();
}

class _BusRouteWiseFeeReportsScreenState extends State<BusRouteWiseFeeReportsScreen> {
  bool _isLoading = true;
  bool _isFileDownloading = false;
  final String reportName = "Bus Route Wise Fee Report.xlsx";

  List<BusRouteInfo> busRouteInfoBeans = [];
  Set<int> selectedRoutes = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isFileDownloading = false;
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
        selectedRoutes.addAll(busRouteInfoBeans.map((e) => e.busRouteId!));
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _downloadFile() async {
    if (selectedRoutes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select at least one route to continue.."),
        ),
      );
    }
    setState(() {
      _isFileDownloading = true;
    });
    List<int> bytes = await getBusWiseFeesSummaryReport(GetBusRouteDetailsRequest(
      schoolId: widget.adminProfile.schoolId,
      routeIds: selectedRoutes.toList(),
    ));
    AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", reportName)
      ..click();
    setState(() {
      _isFileDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Route Wise Fees Stats"),
        actions: _isLoading || _isFileDownloading
            ? []
            : [
                InkWell(
                  onTap: _downloadFile,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Icon(Icons.download),
                  ),
                ),
              ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : _isFileDownloading
              ? Column(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Center(
                        child: Text("Report download in progress"),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Image.asset(
                        'assets/images/eis_loader.gif',
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(reportName),
                      ),
                    ),
                  ],
                )
              : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRoutes.clear();
                                      selectedRoutes.addAll(busRouteInfoBeans.map((e) => e.busRouteId!));
                                    });
                                  },
                                  child: ClayButton(
                                    color: clayContainerColor(context),
                                    borderRadius: 20,
                                    spread: 2,
                                    child: const Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Center(
                                        child: Text(
                                          "Select All",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRoutes.clear();
                                    });
                                  },
                                  child: ClayButton(
                                    color: clayContainerColor(context),
                                    borderRadius: 20,
                                    spread: 2,
                                    child: const Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Center(
                                        child: Text(
                                          "Clear All",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ...busRouteInfoBeans
                              .map((eachRoute) => Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: ClayContainer(
                                      color: clayContainerColor(context),
                                      borderRadius: 10,
                                      spread: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: CheckboxListTile(
                                          controlAffinity: ListTileControlAffinity.leading,
                                          isThreeLine: true,
                                          value: selectedRoutes.contains(eachRoute.busRouteId),
                                          onChanged: (bool? isSelected) {
                                            if (isSelected == null || !isSelected) {
                                              setState(() {
                                                selectedRoutes.remove(eachRoute.busRouteId);
                                              });
                                            } else {
                                              setState(() {
                                                selectedRoutes.add(eachRoute.busRouteId!);
                                              });
                                            }
                                          },
                                          title: Text(eachRoute.busRouteName ?? "-"),
                                          subtitle: buildBusFareDetailsWidget(eachRoute),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget buildBusFareDetailsWidget(BusRouteInfo busRouteInfo) {
    List<RouteStopWiseStudent> students = (busRouteInfo.busRouteStopsList ?? [])
        .where((e) => e != null)
        .map((e) => e!)
        .map((e) => e.students ?? [])
        .expand((i) => i)
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
    students.sort(
      (a, b) => (a.sectionId ?? 0).compareTo(b.sectionId ?? 0) == 0
          ? (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))
          : (a.sectionId ?? 0).compareTo(b.sectionId ?? 0),
    );
    int totalFee = students.isEmpty ? 0 : students.map((e) => e.busFee ?? 0).reduce((a, b) => a + b);
    int totalFeePaid = students.isEmpty ? 0 : students.map((e) => e.busFeePaid ?? 0).reduce((a, b) => a + b);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                "Total Bus Fee:",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            Text(
              "$INR_SYMBOL ${doubleToStringAsFixedForINR(totalFee / 100.0)} /-",
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                "Total Bus Fee Collected",
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
            Text(
              "$INR_SYMBOL ${doubleToStringAsFixedForINR(totalFeePaid / 100.0)} /-",
              style: const TextStyle(
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                "Total Due",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            Text(
              "$INR_SYMBOL ${doubleToStringAsFixedForINR((totalFee - totalFeePaid) / 100.0)} /-",
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
