// import 'package:clay_containers/widgets/clay_container.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:schoolsgo_web/src/common_components/clay_button.dart';
// import 'package:schoolsgo_web/src/constants/colors.dart';
// import 'package:schoolsgo_web/src/fee/model/fee_old.dart';
// import 'package:schoolsgo_web/src/model/sections.dart';
// import 'package:schoolsgo_web/src/model/user_roles_response.dart';
//
// class AdminManageFeeTypesScreen extends StatefulWidget {
//   const AdminManageFeeTypesScreen({Key? key, required this.adminProfile}) : super(key: key);
//
//   final AdminProfile adminProfile;
//
//   @override
//   _AdminManageFeeTypesScreenState createState() => _AdminManageFeeTypesScreenState();
// }
//
// class _AdminManageFeeTypesScreenState extends State<AdminManageFeeTypesScreen> {
//   bool _isLoading = true;
//
//   List<Section> _sectionsList = [];
//   Section? _selectedSection;
//   bool _isSectionPickerOpen = false;
//
//   List<FeeType> feeTypes = [];
//
//   List<FeeMap> feeMaps = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     GetSectionsRequest getSectionsRequest = GetSectionsRequest(
//       schoolId: widget.adminProfile.schoolId,
//     );
//     GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);
//
//     if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
//       setState(() {
//         _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
//       });
//     }
//
//     GetFeeTypesRequest getFeeTypesRequest = GetFeeTypesRequest(
//       schoolId: widget.adminProfile.schoolId,
//     );
//     GetFeeTypesResponse getFeeTypesResponse = await getFeeTypes(getFeeTypesRequest);
//
//     if (getFeeTypesResponse.httpStatus == "OK" && getFeeTypesResponse.responseStatus == "success") {
//       setState(() {
//         feeTypes = getFeeTypesResponse.feeTypeBeans!.map((e) => e!).toList();
//       });
//     }
//
//     GetFeeMapRequest getFeeMapRequest = GetFeeMapRequest(
//       schoolId: widget.adminProfile.schoolId,
//     );
//     GetFeeMapResponse getFeeMapResponse = await getFeeMap(getFeeMapRequest);
//
//     if (getFeeMapResponse.httpStatus == "OK" && getFeeMapResponse.responseStatus == "success") {
//       setState(() {
//         feeMaps = getFeeMapResponse.feeMapBeans!.map((e) => e!).toList();
//       });
//     }
//
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   Widget _selectSectionExpanded() {
//     return ClayContainer(
//       depth: 40,
//       color: clayContainerColor(context),
//       spread: 2,
//       borderRadius: 10,
//       child: Container(
//         padding: const EdgeInsets.all(15),
//         width: double.infinity,
//         child: ListView(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           children: [
//             InkWell(
//               onTap: () {
//                 HapticFeedback.vibrate();
//                 if (_isLoading) return;
//                 setState(() {
//                   _isSectionPickerOpen = !_isSectionPickerOpen;
//                 });
//               },
//               child: Container(
//                 margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
//                 child: Text(
//                   _selectedSection == null ? "Select a section" : "Sections:",
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 15,
//             ),
//             GridView.count(
//               childAspectRatio: 2.25,
//               crossAxisCount: MediaQuery.of(context).size.width ~/ 125,
//               shrinkWrap: true,
//               children: _sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _selectSectionCollapsed() {
//     return ClayContainer(
//       depth: 20,
//       color: clayContainerColor(context),
//       spread: 5,
//       borderRadius: 10,
//       child: _selectedSection != null
//           ? Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       HapticFeedback.vibrate();
//                       if (_isLoading) return;
//                       setState(() {
//                         _isSectionPickerOpen = !_isSectionPickerOpen;
//                       });
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.fromLTRB(5, 14, 10, 14),
//                       child: Center(
//                         child: FittedBox(
//                           fit: BoxFit.scaleDown,
//                           child: Text(
//                             _selectedSection == null ? "Select a section" : "Section: ${_selectedSection!.sectionName!}",
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: const EdgeInsets.all(5),
//                   child: InkWell(
//                     child: const Icon(Icons.close),
//                     onTap: () {
//                       setState(() {
//                         _selectedSection = null;
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             )
//           : InkWell(
//               onTap: () {
//                 HapticFeedback.vibrate();
//                 if (_isLoading) return;
//                 setState(() {
//                   _isSectionPickerOpen = !_isSectionPickerOpen;
//                 });
//               },
//               child: Container(
//                 margin: const EdgeInsets.fromLTRB(5, 14, 5, 14),
//                 child: Center(
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       _selectedSection == null ? "Select a section" : "Section: ${_selectedSection!.sectionName!}",
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
//
//   Widget buildSectionCheckBox(Section section) {
//     return Container(
//       margin: const EdgeInsets.all(5),
//       child: ClayButton(
//         depth: 40,
//         color: _selectedSection != null && _selectedSection!.sectionId == section.sectionId ? Colors.blue[200] : clayContainerColor(context),
//         spread: _selectedSection != null && _selectedSection!.sectionId == section.sectionId! ? 0 : 2,
//         borderRadius: 10,
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           padding: const EdgeInsets.all(5),
//           margin: const EdgeInsets.all(5),
//           child: InkWell(
//             onTap: () {
//               HapticFeedback.vibrate();
//               if (_isLoading) return;
//               setState(() {
//                 if (_selectedSection != null && _selectedSection!.sectionId == section.sectionId) {
//                   _selectedSection = null;
//                 } else {
//                   _selectedSection = section;
//                 }
//                 _isSectionPickerOpen = false;
//               });
//             },
//             child: Center(
//               child: FittedBox(
//                 fit: BoxFit.scaleDown,
//                 child: Text(
//                   section.sectionName!,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _sectionPicker() {
//     return AnimatedSize(
//       curve: Curves.fastOutSlowIn,
//       duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
//       child: Container(
//         padding: const EdgeInsets.all(25),
//         child: _isSectionPickerOpen ? _selectSectionExpanded() : _selectSectionCollapsed(),
//       ),
//     );
//   }
//
//   // Widget _getFeeMapWidget(FeeMap feeMap) {
//   //   return Container(
//   //     margin: const EdgeInsets.all(10),
//   //     child: ClayContainer(
//   //       depth: 40,
//   //       color: clayContainerColor(context),
//   //       spread: 2,
//   //       borderRadius: 10,
//   //       child: Container(
//   //         margin: const EdgeInsets.all(10),
//   //         child: Column(
//   //           children: [
//   //             Row(
//   //               children: [
//   //                 const Text("Fee Type:"),
//   //                 Expanded(
//   //                   child: Text((feeMap.feeType ?? "-") +
//   //                       "    " +
//   //                       (feeMap.customFeeDescription ?? "")),
//   //                 ),
//   //                 Text(
//   //                   feeMap.customFeeId != null
//   //                       ? feeMap.customFeeAmount == null
//   //                           ? "-"
//   //                           : (feeMap.customFeeAmount! / 100.0).toString()
//   //                       : feeMap.feeTypeAmount == null
//   //                           ? "-"
//   //                           : (feeMap.feeTypeAmount! / 100.0).toString(),
//   //                 ),
//   //               ],
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   Widget _getCustomFeeTypeWidget(CustomFee customFee, FeeType feeType, Section section) {
//     List<FeeMap> _feeMaps = feeMaps.where((eachFeeMap) => eachFeeMap.sectionId == section.sectionId && eachFeeMap.customFeeId != null).toList();
//     if (_feeMaps.isEmpty) return Container();
//     debugPrint("${section.sectionName} ${feeType.feeType} ${customFee.customFeeDescription} ${_feeMaps.length}");
//     FeeMap feeMap = _feeMaps.first;
//     return Container(
//       margin: const EdgeInsets.fromLTRB(50, 10, 0, 10),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(feeMap.customFeeDescription ?? "-"),
//               ),
//               Text(((feeMap.feeMapAmount ?? feeMap.customFeeAmount ?? feeMap.feeMapAmount ?? 0) / 100.0).toString()),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _getFeeTypeWidget(FeeType feeType, Section section) {
//     List<FeeMap> _feeMaps = feeMaps.where((eachFeeMap) => eachFeeMap.sectionId == section.sectionId).toList();
//     if (_feeMaps.isEmpty) return Container();
//     debugPrint("${section.sectionName} ${feeType.feeType} ${_feeMaps.length}");
//     FeeMap feeMap = _feeMaps.first;
//     return Container(
//       margin: const EdgeInsets.fromLTRB(40, 10, 0, 10),
//       child: Column(
//         children: <Widget>[
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(feeMap.feeType ?? "-"),
//                   ),
//                   Text(
//                     ((feeMap.feeMapAmount ?? feeMap.feeTypeAmount ?? 0) / 100.0).toString(),
//                   ),
//                 ],
//               ),
//             ] +
//             feeType.customFeeBeans!
//                 .where((eachCustomFeeType) => feeMaps
//                     .where((eachFeeMap) => eachFeeMap.sectionId == section.sectionId && eachFeeMap.customFeeId != null)
//                     .map((e) => e.customFeeId!)
//                     .contains(eachCustomFeeType!.customFeeId))
//                 .map((e) => e!)
//                 .map((e) => _getCustomFeeTypeWidget(e, feeType, section))
//                 .toList(),
//       ),
//     );
//   }
//
//   Widget _getSectionWiseFeeMaps(Section section) {
//     return Container(
//       margin: const EdgeInsets.all(10),
//       padding: MediaQuery.of(context).orientation == Orientation.landscape
//           ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
//           : const EdgeInsets.all(20),
//       child: ClayContainer(
//         depth: 40,
//         color: clayContainerColor(context),
//         spread: 2,
//         borderRadius: 10,
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(5, 5, 50, 5),
//           child: ListView(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             children: <Widget>[
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(section.sectionName ?? "-"),
//                     ],
//                   ),
//                 ] +
//                 feeTypes
//                     .where((eachFeeType) => feeMaps
//                         .where((eachFeeMap) =>
//                             eachFeeMap.sectionId == section.sectionId &&
//                             eachFeeMap.studentId != null &&
//                             eachFeeMap.feeTypeId == eachFeeType.feeTypeId)
//                         .map((e) => e.feeTypeId)
//                         .contains(eachFeeType.feeTypeId))
//                     .map((e) => _getFeeTypeWidget(e, section))
//                     .toList(),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Manage Fee",
//         ),
//       ),
//       body: _isLoading
//           ? Center(
//               child: Image.asset('assets/images/eis_loader.gif'),
//             )
//           : ListView(
//               children: [
//                     _sectionPicker(),
//                   ] +
//                   _sectionsList
//                       .map(
//                         (e) => _getSectionWiseFeeMaps(e),
//                       )
//                       .toList(),
//             ),
//     );
//   }
// }
