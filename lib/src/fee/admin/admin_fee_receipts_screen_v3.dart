import 'dart:typed_data';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/fee/admin/fee_receipts_search_widget.dart';
import 'package:schoolsgo_web/src/fee/admin/new_student_fee_receipt_widget.dart';
import 'package:schoolsgo_web/src/fee/admin/stats/date_wise_fee_stats.dart';
import 'package:schoolsgo_web/src/fee/admin/stats/date_wise_receipts_stats.dart';
import 'package:schoolsgo_web/src/fee/admin/stats/section_wise_fee_stats.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/sms/modal/sms.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';
import 'package:schoolsgo_web/src/utils/print_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AdminFeeReceiptsScreenV3 extends StatefulWidget {
  const AdminFeeReceiptsScreenV3({
    Key? key,
    this.adminProfile,
    this.otherRole,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final OtherUserRoleProfile? otherRole;

  @override
  State<AdminFeeReceiptsScreenV3> createState() => _AdminFeeReceiptsScreenV3State();
}

class _AdminFeeReceiptsScreenV3State extends State<AdminFeeReceiptsScreenV3> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<StudentFeeReceipt> studentFeeReceipts = [];
  List<StudentFeeReceipt> filteredStudentFeeReceipts = [];
  final ItemScrollController _itemScrollController = ItemScrollController();

  List<RouteStopWiseStudent> routeStopWiseStudents = [];

  bool isSearchBarSelected = false;

  bool isTermWise = false;

  SchoolInfoBean? schoolInfoBean;
  List<StudentProfile> studentProfiles = [];
  List<Section> sections = [];
  List<FeeType> feeTypes = [];
  String? _renderingReceiptText;
  double? _loadingReceiptPercentage;
  Uint8List? pdfInBytes;

  bool? showOnlyDeletedReceipts = false;

  bool isAddNew = false;
  ScrollController newReceiptsListViewController = ScrollController();

  List<NewReceipt> newReceipts = [];

  SmsTemplateBean? smsTemplate;

  int? newReceiptNumber;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      studentFeeReceipts = [];
      newReceipts = [
        NewReceipt(
          schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
          agentId: widget.adminProfile?.userId ?? widget.otherRole?.userId,
          date: DateTime.now().millisecondsSinceEpoch,
          modeOfPayment: ModeOfPayment.CASH.name,
        ),
      ];
    });
    GetBusRouteDetailsResponse getBusRouteDetailsResponse = await getBusRouteDetails(GetBusRouteDetailsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
    ));
    if (getBusRouteDetailsResponse.httpStatus != "OK" || getBusRouteDetailsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        routeStopWiseStudents = (getBusRouteDetailsResponse.busRouteInfoBeanList?.map((e) => e!).toList() ?? [])
            .map((e) => (e.busRouteStopsList ?? []).whereNotNull())
            .expand((i) => i)
            .map((e) => (e.students ?? []).whereNotNull())
            .expand((i) => i)
            .toList();
      });
    }

    GetFeeTypesResponse getFeeTypesResponse = await getFeeTypes(GetFeeTypesRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
    ));
    if (getFeeTypesResponse.httpStatus != "OK" || getFeeTypesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        feeTypes = getFeeTypesResponse.feeTypesList!.map((e) => e!).toList();
      });
    }

    if (widget.adminProfile != null) {
      GetSmsTemplatesResponse getSmsTemplatesResponse = await getSmsTemplates(GetSmsTemplatesRequest(
        categoryId: 2,
        schoolId: widget.adminProfile?.schoolId,
      ));
      if (getSmsTemplatesResponse.httpStatus != "OK" ||
          getSmsTemplatesResponse.responseStatus != "success" ||
          getSmsTemplatesResponse.smsTemplateBeans == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      } else {
        smsTemplate = getSmsTemplatesResponse.smsTemplateBeans?.firstOrNull;
      }
    }
    await loadReceipts();
    newReceiptNumber = await getNewReceiptNumber();
    setState(() {
      newReceipts[newReceipts.length - 1].receiptNumber = newReceiptNumber;
      newReceipts[newReceipts.length - 1].receiptNumberController.text = "$newReceiptNumber";
      newReceipts[newReceipts.length - 1].date = newReceipts.isEmpty
          ? studentFeeReceipts.isEmpty
              ? DateTime.now().millisecondsSinceEpoch
              : convertYYYYMMDDFormatToDateTime(studentFeeReceipts[0].transactionDate).millisecondsSinceEpoch
          : (newReceipts[newReceipts.length - 1].date ?? DateTime.now().millisecondsSinceEpoch);
      _isLoading = false;
    });
  }

  Future<int> getNewReceiptNumber() async {
    if (newReceiptNumber == null) {
      newReceiptNumber = await HttpUtils.getNewReceiptNumber(widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId ?? -1);
      return newReceiptNumber!;
    } else {
      return newReceiptNumber! + newReceipts.length;
    }
  }

  Future<void> loadReceipts() async {
    setState(() {
      _isLoading = true;
    });

    GetStudentFeeReceiptsResponse studentFeeReceiptsResponse = await getStudentFeeReceipts(GetStudentFeeReceiptsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
    ));
    if (studentFeeReceiptsResponse.httpStatus != "OK" || studentFeeReceiptsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        studentFeeReceipts = studentFeeReceiptsResponse.studentFeeReceipts!.map((e) => e!).toList();
        studentFeeReceipts.sort((b, a) {
          int dateCom = convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate));
          return (dateCom == 0) ? (a.receiptNumber ?? 0).compareTo(b.receiptNumber ?? 0) : dateCom;
        });
        filteredStudentFeeReceipts = studentFeeReceiptsResponse.studentFeeReceipts!.map((e) => e!).toList();
        filteredStudentFeeReceipts.sort((b, a) {
          int dateComp = convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate));
          return (dateComp == 0) ? (a.receiptNumber ?? 0).compareTo(b.receiptNumber ?? 0) : dateComp;
        });
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> getDataReadyToPrint() async {
    setState(() {
      _isLoading = true;
    });
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      schoolInfoBean = getSchoolsResponse.schoolInfo!;
    }

    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentProfiles = (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList();
    }

    GetSectionsResponse getSectionsResponse = await getSections(GetSectionsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
    ));
    if (getSectionsResponse.httpStatus != "OK" || getSectionsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      sections = (getSectionsResponse.sections ?? []).where((e) => e != null).map((e) => e!).toList();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void scrollToReceiptNumber(int e) {
    if (e == -1) return;
    _itemScrollController.scrollTo(
      index: e,
      duration: const Duration(milliseconds: 100),
      curve: Curves.bounceInOut,
    );
  }

  void isSearchButtonSelected(bool isSelected) {
    setState(() {
      isSearchBarSelected = isSelected;
    });
  }

  Future<void> handleClick(String choice) async {
    if (choice == "Show Only Deleted Receipts") {
      // filteredStudentFeeReceipts = studentFeeReceipts.where((e) => e.status == "deleted").toList();
      setState(() => showOnlyDeletedReceipts = true);
    } else if (choice == "Hide Deleted Receipts") {
      // filteredStudentFeeReceipts = studentFeeReceipts.where((e) => e.status == "deleted").toList();
      setState(() => showOnlyDeletedReceipts = false);
    } else if (choice == "Show All Receipts") {
      // filteredStudentFeeReceipts = studentFeeReceipts.where((e) => e.status == "deleted").toList();
      setState(() => showOnlyDeletedReceipts = null);
    } else if (choice == "Today") {
      if (widget.adminProfile != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return DateWiseReceiptsStatsWidget(
            adminProfile: widget.adminProfile!,
            studentFeeReceipts: studentFeeReceipts
                .where((e) => e.status == "active" && e.transactionDate == convertDateTimeToYYYYMMDDFormat(DateTime.now()))
                .toList(),
            selectedDate: convertYYYYMMDDFormatToDateTime(convertDateTimeToYYYYMMDDFormat(DateTime.now())),
            routeStopWiseStudents: routeStopWiseStudents,
            feeTypes: feeTypes,
          );
        }));
      }
    } else if (choice == "Go to date") {
      await goToDateAction();
    } else if (choice == "Term Wise") {
      setState(() => isTermWise = !isTermWise);
    } else if (choice == "Print") {
      makePdf();
    } else if (choice == "Date wise Stats") {
      if (widget.adminProfile != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return DateWiseReceiptStats(
            adminProfile: widget.adminProfile!,
            studentFeeReceipts: studentFeeReceipts.where((e) => e.status == "active").toList(),
            routeStopWiseStudents: routeStopWiseStudents,
          );
        }));
      }
    } else if (choice == "Section wise Stats") {
      if (widget.adminProfile != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SectionWiseFeeStats(
            adminProfile: widget.adminProfile!,
            studentFeeReceipts: studentFeeReceipts.where((e) => e.status == "active").toList(),
          );
        }));
      }
    } else {
      debugPrint("Clicked on $choice");
    }
  }

  Future<void> goToDateAction() async {
    if (filteredStudentFeeReceipts.isEmpty) return;
    Set<DateTime> transactionDatesSet = filteredStudentFeeReceipts.map((e) => convertYYYYMMDDFormatToDateTime(e.transactionDate)).toSet();
    DateTime? _newDate = await showDatePicker(
      context: context,
      initialDate: transactionDatesSet.firstOrNull ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      helpText: "Select a date",
      initialEntryMode: DatePickerEntryMode.calendar,
      selectableDayPredicate: (DateTime? eachDate) {
        return transactionDatesSet.contains(eachDate);
      },
    );
    if (_newDate == null) return;
    scrollToReceiptNumber(
        filteredStudentFeeReceipts.map((e) => e.transactionDate).toList().indexWhere((e) => convertDateTimeToYYYYMMDDFormat(_newDate) == e));
  }

  Future<void> makePdf({int? transactionId}) async {
    bool isAdminCopySelected = true;
    bool isStudentCopySelected = transactionId != null;
    bool proceedPrint = true;
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: const Text('Download receipts'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text("Admin Copy"),
                    selected: isAdminCopySelected,
                    value: isAdminCopySelected,
                    onChanged: (bool value) {
                      setState(() => isAdminCopySelected = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Student Copy"),
                    selected: isStudentCopySelected,
                    value: isStudentCopySelected,
                    onChanged: (bool value) {
                      setState(() => isStudentCopySelected = value);
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Proceed to print"),
              onPressed: () async {
                if (!isAdminCopySelected && !isStudentCopySelected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("At least one in Admin Copy or Student Copy must be selected"),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async {
                setState(() => proceedPrint = false);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );

    if (!proceedPrint) return;

    setState(() {
      _renderingReceiptText = "Preparing receipts";
    });
    if (schoolInfoBean == null) await getDataReadyToPrint();
    if (schoolInfoBean == null) return;

    // pw.ImageProvider logoImageProvider;
    //
    // try {
    //   logoImageProvider = await networkImage(
    //     schoolInfoBean.logoPictureUrl ?? "https://storage.googleapis.com/storage-schools-go/Episilon%20infinity.jpg",
    //   );
    // } catch (e) {
    //   logoImageProvider = pw.MemoryImage(
    //     (await rootBundle.load('images/EISlogo.png')).buffer.asUint8List(),
    //   );
    // }

    List<StudentFeeReceipt> receiptsToPrint = filteredStudentFeeReceipts
        .where((e) =>
            (transactionId == null || e.transactionId == transactionId) &&
            e.status != "deleted" &&
            (isReceptionist ? e.transactionDate == convertDateTimeToYYYYMMDDFormat(DateTime.now()) : true))
        .toList();
    await printReceipts(
      context,
      schoolInfoBean!,
      receiptsToPrint,
      studentProfiles,
      isTermWise,
      isAdminCopySelected: isAdminCopySelected,
      isStudentCopySelected: isStudentCopySelected,
    );

    setState(() {
      _renderingReceiptText = null;
    });
  }

  Future<void> sendReceiptSms({int? transactionId}) async {
    SendFeeReceiptSmsResponse sendFeeReceiptSmsResponse = await sendFeeReceiptSms(SendFeeReceiptSmsRequest(
      schoolId: widget.adminProfile?.schoolId,
      agentId: widget.adminProfile?.userId,
      bothDateAndTime: false,
      masterTransactionId: transactionId,
    ));
    if (sendFeeReceiptSmsResponse.httpStatus != "OK" || sendFeeReceiptSmsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("SMS sent successfully.."),
        ),
      );
      setState(() {
        StudentFeeReceipt? studentFeeReceipt = studentFeeReceipts.firstWhereOrNull((eachReceipt) => eachReceipt.transactionId == transactionId);
        int noOfTimesNotified = (studentFeeReceipt?.noOfTimesNotified ?? 0) + 1;
        studentFeeReceipt?.noOfTimesNotified = noOfTimesNotified;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<StudentFeeReceipt> filteredReceiptsAsPerDeletedStatus = filteredStudentFeeReceipts
        .where((er) => showOnlyDeletedReceipts == null
            ? true
            : showOnlyDeletedReceipts!
                ? er.status == "deleted"
                : er.status != "deleted")
        .where((efr) => isReceptionist ? efr.transactionDate == convertDateTimeToYYYYMMDDFormat(DateTime.now()) : true)
        .toList();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Fee Receipts"),
        actions: _isLoading || filteredReceiptsAsPerDeletedStatus.isEmpty || isAddNew
            ? []
            : [
                if (!isSearchBarSelected)
                  SearchWidget(
                    isSearchBarSelectedByDefault: false,
                    onComplete: scrollToReceiptNumber,
                    receiptNumbers: filteredReceiptsAsPerDeletedStatus.map((e) => "${e.receiptNumber ?? ""}").toList(),
                    isSearchButtonSelected: isSearchButtonSelected,
                  ),
                if (_renderingReceiptText != null)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                PopupMenuButton<String>(
                  onSelected: (String choice) async => await handleClick(choice),
                  itemBuilder: (BuildContext context) {
                    return {
                      if (filteredReceiptsAsPerDeletedStatus
                          .where((e) => e.transactionDate == convertDateTimeToYYYYMMDDFormat(DateTime.now()))
                          .isNotEmpty)
                        "Today",
                      if (!isReceptionist && !(showOnlyDeletedReceipts == true)) "Show Only Deleted Receipts",
                      if (!isReceptionist && !(showOnlyDeletedReceipts == false)) "Hide Deleted Receipts",
                      if (!isReceptionist && !(showOnlyDeletedReceipts == null)) "Show All Receipts",
                      if (!isReceptionist) "Go to date",
                      "Term Wise",
                      if (!isReceptionist) "Date wise Stats",
                      if (!isReceptionist) "Section wise Stats",
                      if (_renderingReceiptText == null) "Print",
                    }.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: choice == "Term Wise"
                            ? isTermWise
                                ? const Text("Disable Term Wise")
                                : const Text("Enable Term Wise")
                            : Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
      ),
      drawer: widget.adminProfile != null
          ? AdminAppDrawer(
              adminProfile: widget.adminProfile!,
            )
          : null,
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : isAddNew
              ? ListView(
                  controller: newReceiptsListViewController,
                  children: [
                    ...newReceipts.where((e) => e.status != "deleted").toList().reversed.map(
                          (e) => NewStudentFeeReceiptWidget(
                            context: _scaffoldKey.currentContext!,
                            setState: setState,
                            feeTypesForSelectedSection: feeTypes,
                            newReceipt: e,
                            schoolInfoBean: schoolInfoBean!,
                            sections: sections,
                            studentProfiles: studentProfiles
                              ..sort(
                                (a, b) {
                                  int sectionComp = (a.sectionId ?? 0).compareTo(b.sectionId ?? 0);
                                  int rollNumberComp = (int.tryParse(a.rollNumber ?? "0") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "0") ?? 0);
                                  return sectionComp == 0
                                      ? rollNumberComp == 0
                                          ? (a.studentFirstName ?? "").compareTo((b.studentFirstName ?? ""))
                                          : rollNumberComp
                                      : sectionComp;
                                },
                              ),
                          ),
                        ),
                    SizedBox(height: MediaQuery.of(context).size.height / 2),
                  ],
                )
              : filteredReceiptsAsPerDeletedStatus.isEmpty
                  ? const Center(
                      child: Text("No Transactions to display"),
                    )
                  : Stack(
                      children: [
                        ScrollablePositionedList.builder(
                          initialScrollIndex: 0,
                          physics: const BouncingScrollPhysics(),
                          itemScrollController: _itemScrollController,
                          itemCount: filteredReceiptsAsPerDeletedStatus.length,
                          itemBuilder: (BuildContext context, int index) {
                            return filteredReceiptsAsPerDeletedStatus[index].widget(
                              _scaffoldKey.currentContext ?? context,
                              adminId: widget.adminProfile?.userId ?? widget.otherRole?.userId,
                              isTermWise: isTermWise,
                              setState: setState,
                              reload: _loadData,
                              makePdf: filteredReceiptsAsPerDeletedStatus[index].isEditMode
                                  ? null
                                  : (int? transactionId) async {
                                      makePdf(transactionId: transactionId);
                                    },
                              routeStopWiseStudent:
                                  routeStopWiseStudents.where((e) => e.studentId == filteredReceiptsAsPerDeletedStatus[index].studentId).firstOrNull,
                              canSendSms: !filteredReceiptsAsPerDeletedStatus[index].isEditMode && smsTemplate != null,
                              updateModeOfPayment: (String? modeOfPayment) => setState(() {
                                filteredReceiptsAsPerDeletedStatus[index].modeOfPayment = modeOfPayment;
                              }),
                              sendReceiptSms: (int? transactionId) async => sendReceiptSms(transactionId: transactionId),
                            );
                          },
                        ),
                        if (isSearchBarSelected)
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              height: 75,
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
                              child: Container(
                                color: clayContainerColor(context),
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                child: SearchWidget(
                                  isSearchBarSelectedByDefault: true,
                                  onComplete: scrollToReceiptNumber,
                                  receiptNumbers: filteredReceiptsAsPerDeletedStatus.map((e) => "${e.receiptNumber ?? ""}").toList(),
                                  isSearchButtonSelected: isSearchButtonSelected,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
      floatingActionButton: _isLoading
          ? null
          : (isAddNew && (newReceipts.isEmpty || newReceipts.map((e) => e.status).contains("inactive")))
              ? buildCloseAddNewReceiptButton(context)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAddNew && newReceipts.map((e) => e.status).contains("active") && !newReceipts.map((e) => e.status).contains("inactive"))
                      buildSubmitReceiptsButton(context),
                    const SizedBox(height: 20),
                    if (isAddNew) buildCloseAddNewReceiptButton(context),
                    const SizedBox(height: 20),
                    buildAddNewReceiptButton(context),
                  ],
                ),
    );
  }

  Widget buildCloseAddNewReceiptButton(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isAddNew = false),
      child: ClayButton(
        surfaceColor: Colors.red[300],
        parentColor: clayContainerColor(context),
        borderRadius: 20,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.close),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    String? errorText;
    if (errorText != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorText),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }
    List<NewReceiptBean> newReceiptsToBePaid = newReceipts
        .where((e) => e.status == "active")
        .map((eachNewReceipt) => NewReceiptBean(
              agentId: widget.adminProfile?.userId ?? widget.otherRole?.userId,
              date: eachNewReceipt.date,
              receiptNumber: eachNewReceipt.receiptNumber,
              schoolId: eachNewReceipt.schoolId,
              sectionId: eachNewReceipt.sectionId,
              studentId: eachNewReceipt.studentId,
              subBeans: (eachNewReceipt.subBeans ?? [])
                  .where((e) => e != null)
                  .map((e) => e!)
                  .map((eachSubBean) => NewReceiptBeanSubBean(
                        customFeeTypeId: eachSubBean.customFeeTypeId,
                        feePaying: eachSubBean.feePaying,
                        feeTypeId: eachSubBean.feeTypeId,
                      ))
                  .toList(),
              busFeePaidAmount: eachNewReceipt.busFeePaidAmount,
              modeOfPayment: eachNewReceipt.modeOfPayment,
              comments: eachNewReceipt.comments,
              sendSms: eachNewReceipt.shouldSendSms ? "Y" : "N",
            ))
        .toList();
    if (newReceiptsToBePaid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please check all the necessary details correctly"),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }
    CreateNewReceiptsResponse createNewReceiptsResponse = await createNewReceipts(CreateNewReceiptsRequest(
      newReceiptBeans: newReceiptsToBePaid,
      schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
      agent: widget.adminProfile?.userId ?? widget.otherRole?.userId,
    ));
    if (createNewReceiptsResponse.httpStatus != "OK" || createNewReceiptsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Receipts submitted successfully, Please wait while we load your data.."),
        ),
      );
      await _loadData();
    }
    setState(() => isAddNew = false);
    setState(() => _isLoading = false);
  }

  Widget buildSubmitReceiptsButton(BuildContext context) {
    return GestureDetector(
      onTap: _saveChanges,
      child: ClayButton(
        surfaceColor: Colors.green[300],
        parentColor: clayContainerColor(context),
        borderRadius: 20,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.check),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addNewReceiptAction() async {
    if (schoolInfoBean == null) await getDataReadyToPrint();
    if (!isAddNew) {
      setState(() => isAddNew = true);
    } else if (newReceipts.map((e) => e.status).contains("inactive")) {
      return;
    } else {
      int latestReceiptNumber = await getNewReceiptNumber();
      setState(() {
        newReceipts.add(
          NewReceipt(
            schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
            agentId: widget.adminProfile?.userId ?? widget.otherRole?.userId,
            date: newReceipts.isEmpty
                ? studentFeeReceipts.isEmpty
                    ? (DateTime.now().millisecondsSinceEpoch)
                    : convertYYYYMMDDFormatToDateTime(studentFeeReceipts[0].transactionDate).millisecondsSinceEpoch
                : (newReceipts[newReceipts.length - 1].date ?? (DateTime.now().millisecondsSinceEpoch)),
            modeOfPayment: ModeOfPayment.CASH.name,
          ),
        );
        newReceipts.last.receiptNumber = latestReceiptNumber;
        newReceipts.last.receiptNumberController.text = "${newReceipts.last.receiptNumber}";
        newReceiptsListViewController.animateTo(
          newReceiptsListViewController.position.minScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
        );
      });
    }
  }

  GestureDetector buildAddNewReceiptButton(BuildContext context) {
    return GestureDetector(
      onTap: addNewReceiptAction,
      child: ClayButton(
        surfaceColor: Colors.blue[300],
        parentColor: clayContainerColor(context),
        borderRadius: 20,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.add),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Add new"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get isReceptionist => widget.otherRole?.roleId == 8;
}
