import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/settings/model/app_version.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class AppUpdatesLogScreen extends StatefulWidget {
  const AppUpdatesLogScreen({super.key});

  @override
  State<AppUpdatesLogScreen> createState() => _AppUpdatesLogScreenState();
}

class _AppUpdatesLogScreenState extends State<AppUpdatesLogScreen> {
  bool _isLoading = true;
  List<AppVersion> updateLogs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetAppUpdateLogResponse? getAppUpdateLogResponse = await getAppUpdateLog();
    // if (getAppUpdateLogResponse?.httpStatus != "OK" || getAppUpdateLogResponse?.responseStatus != "success") {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Something went wrong! Try again later.."),
    //     ),
    //   );
    // } else {
    updateLogs = (getAppUpdateLogResponse?.appVersionBeans ?? []);
    // }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Log"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                ...updateLogs.map((e) => eachUpdateLog(e)),
              ],
            ),
    );
  }

  Widget eachUpdateLog(AppVersion e) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: true,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      e.versionName ?? "-",
                      style: GoogleFonts.archivoBlack(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Chip(
                    label: Text(
                      e.comment ?? "-",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(e.description ?? "-"),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Expanded(
                    child: Text(""),
                  ),
                  Text(
                    convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(e.createTime ?? DateTime.now().millisecondsSinceEpoch)),
                    style: const TextStyle(fontSize: 14),
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
