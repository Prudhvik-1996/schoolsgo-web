import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/sms/modal/sms.dart';

class AdminSmsConfigScreen extends StatefulWidget {
  const AdminSmsConfigScreen({
    super.key,
    required this.adminProfile,
    required this.smsCategoryList,
    required this.smsConfigList,
    required this.smsTemplates,
    required this.fromSettings,
  });

  final AdminProfile adminProfile;
  final List<SmsCategoryBean> smsCategoryList;
  final List<SmsConfigBean> smsConfigList;
  final List<SmsTemplateBean> smsTemplates;
  final bool fromSettings;

  @override
  State<AdminSmsConfigScreen> createState() => _AdminSmsConfigScreenState();
}

class _AdminSmsConfigScreenState extends State<AdminSmsConfigScreen> {
  bool _isLoading = true;

  List<SmsCategoryBean> smsCategoryList = [];
  List<SmsConfigBean> smsConfigList = [];
  List<SmsTemplateBean> smsTemplates = [];

  @override
  void initState() {
    super.initState();
    smsCategoryList = widget.smsCategoryList;
    smsConfigList = widget.smsConfigList;
    smsTemplates = widget.smsTemplates;
    if (widget.fromSettings) {
      _loadData();
    }
    _isLoading = false;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSmsCategoriesResponse getSmsCategoriesResponse = await getSmsCategories(GetSmsCategoriesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSmsCategoriesResponse.httpStatus != "OK" || getSmsCategoriesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      smsCategoryList = getSmsCategoriesResponse.smsCategoryList?.map((e) => e!).toList() ?? [];
    }
    GetSmsConfigResponse getSmsConfigResponse = await getSmsConfig(GetSmsConfigRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSmsConfigResponse.httpStatus != "OK" || getSmsConfigResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      smsConfigList = getSmsConfigResponse.smsConfigBeans?.map((e) => e!).toList() ?? [];
    }
    GetSmsTemplatesResponse getSmsTemplatesResponse = await getSmsTemplates(GetSmsTemplatesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSmsTemplatesResponse.httpStatus != "OK" || getSmsTemplatesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      smsTemplates = getSmsTemplatesResponse.smsTemplateBeans?.map((e) => e!).toList() ?? [];
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMS Config"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                DataTable(
                  columns: [
                    ...["Category", "Sub Category", "Enabled", "Default", "Template"].map((e) => DataColumn(label: Text(e)))
                  ],
                  rows: [
                    ...smsCategoryList.map((eachCategory) {
                      SmsConfigBean? eachConfigBean =
                          smsConfigList.firstWhereOrNull((eachConfig) => eachConfig.categoryId == eachCategory.categoryId);
                      return DataRow(
                        cells: [
                          DataCell(Text(eachCategory.category ?? "")),
                          DataCell(Text(eachCategory.subCategory ?? "")),
                          DataCell(
                            Checkbox(
                              value: eachConfigBean?.enabled ?? false,
                              onChanged: (bool? value) async {
                                if (value == null) return;
                                bool newValue = value;
                                bool isUpdated = await updateConfig(UpdateSmsConfigRequest(
                                  schoolId: widget.adminProfile.schoolId,
                                  agent: widget.adminProfile.userId,
                                  automatic: eachConfigBean?.automatic ?? false,
                                  enabled: newValue,
                                  categoryId: eachCategory.categoryId,
                                ));
                                if (isUpdated) {
                                  _loadData();
                                }
                              },
                            ),
                          ),
                          DataCell(
                            Checkbox(
                              value: eachConfigBean?.automatic ?? false,
                              onChanged: (bool? value) async {
                                if (value == null) return;
                                bool newValue = value;
                                bool isUpdated = await updateConfig(UpdateSmsConfigRequest(
                                  schoolId: widget.adminProfile.schoolId,
                                  agent: widget.adminProfile.userId,
                                  automatic: newValue,
                                  enabled: eachConfigBean?.enabled ?? false,
                                  categoryId: eachCategory.categoryId,
                                ));
                                if (isUpdated) {
                                  _loadData();
                                }
                              },
                            ),
                          ),
                          DataCell(IconButton(
                            icon: Icon(Icons.message),
                            onPressed: () async {
                              await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext dialogueContext) {
                                  return AlertDialog(
                                    title: const Text('Default Template'),
                                    content: StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        SmsTemplateBean? smsTemplate = smsTemplates
                                            .firstWhereOrNull((eachTemplate) => eachCategory.defaultTemplateId == eachTemplate.templateId);
                                        if (smsTemplate == null) return const Text("Default template not configured for this category");
                                        return Text(smsTemplate.message ?? "");
                                      },
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text("Close"),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          )),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
    );
  }

  Future<bool> updateConfig(UpdateSmsConfigRequest updateSmsConfigRequest) async {
    setState(() => _isLoading = true);
    UpdateSmsConfigResponse updateSmsConfigResponse = await updateSmsConfig(updateSmsConfigRequest);
    if (updateSmsConfigResponse.httpStatus != "OK" || updateSmsConfigResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      return true;
    }
    return false;
  }
}
