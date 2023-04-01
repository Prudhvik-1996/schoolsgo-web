import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
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
          : null,
      body: widget.demoFile == null
          ? const Center(child: Text("We are coming soon.."))
          : PdfViewPinch(
              builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(),
                documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
                pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, error) => Center(child: Text(error.toString())),
              ),
              controller: pdfPinchController!,
            ),
    );
  }
}
