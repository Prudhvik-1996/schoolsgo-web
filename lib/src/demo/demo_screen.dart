import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:pdfx/pdfx.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/demo/demo.dart';
import 'package:schoolsgo_web/src/demo/demo_action_screen.dart';
import 'package:schoolsgo_web/src/demo/demo_json.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({
    Key? key,
    required this.adminProfile,
    required this.studentProfile,
    required this.teacherProfile,
    required this.demoFile,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final StudentProfile? studentProfile;
  final TeacherProfile? teacherProfile;
  final String? demoFile;

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  late PdfControllerPinch? pdfPinchController;

  @override
  void initState() {
    super.initState();
    if (widget.demoFile != null) {
      pdfPinchController = PdfControllerPinch(
        document: PdfDocument.openAsset(widget.demoFile!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.adminProfile != null) {
      return adminDemoScreen();
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (widget.studentProfile != null)
            buildRoleButtonForAppBar(
              context,
              widget.studentProfile!,
            ),
        ],
      ),
      drawer: widget.studentProfile != null
          ? StudentAppDrawer(
              studentProfile: widget.studentProfile!,
            )
          : null, // body: widget.demoFile == null
      //     ? const Center(child: Text("We are coming soon.."))
      //     : PdfViewPinch(
      //         builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
      //           options: const DefaultBuilderOptions(),
      //           documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
      //           pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
      //           errorBuilder: (_, error) => Center(child: Text(error.toString())),
      //         ),
      //         controller: pdfPinchController!,
      //       ),
      body: ListView(
        children: const [
          HtmlWidget(
            // '''
            // '''
            '''
            <div style="position:relative;height:0;width:100%;overflow:hidden;z-index:99999;box-sizing:border-box;padding-bottom:calc(45.75000000% + 32px)"><iframe src="https://www.guidejar.com/embed/bfcb3675-22d8-4eef-bed2-43f703bd6148?type=1&controls=on" width="100%" height="100%" style="position:absolute;inset:0" allowfullscreen frameborder="0"></iframe></div>
            <iframe id="guidejar-embed-f74fbf66-1b5d-4c1d-9658-de762e7f2893" src="https://www.guidejar.com/embed/f74fbf66-1b5d-4c1d-9658-de762e7f2893?type=0&height=parent" loading="lazy" fetchpriority="auto" width="100%" height="100%" style="min-height:640px;z-index:99999;box-sizing:border-box;" allowfullscreen frameborder="0"></iframe>
            ''',
            enableCaching: true,
          ),
        ],
      ),
    );
  }

  Widget adminDemoScreen() {
    List<DemoModule> adminModulesToDisplay = (adminModules.modules ?? []).whereNotNull().toList();
    int perRowCount = MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Demo"),
      ),
      body: ListView(
        children: [
          // ...adminDemoWidgets,
          for (int i = 0; i < (adminModules.modules ?? []).length / perRowCount; i = i + 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int j = 0; j < perRowCount; j++)
                  Expanded(
                    child: ((i * perRowCount + j) >= adminModulesToDisplay.length)
                        ? Container()
                        : eachModuleCard(adminModulesToDisplay[(i * perRowCount + j)]),
                  ),
              ],
            ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Padding eachModuleCard(DemoModule eachDemoModule) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ClayContainer(
        emboss: false,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  eachDemoModule.module ?? "-",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            ...(eachDemoModule.subModules ?? []).whereNotNull().map(
              (SubModule eachSubModule) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClayContainer(
                    emboss: true,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 10,
                    depth: 40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Text(
                            eachSubModule.subModule ?? "-",
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        ...(eachSubModule.actions ?? []).whereNotNull().map((ModuleAction eachAction) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return DemoActionScreen(
                                    action: eachAction,
                                  );
                                }));
                              },
                              child: ClayButton(
                                surfaceColor: clayContainerColor(context),
                                parentColor: clayContainerColor(context),
                                spread: 1,
                                borderRadius: 10,
                                depth: 40,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(eachAction.action ?? "-")),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
