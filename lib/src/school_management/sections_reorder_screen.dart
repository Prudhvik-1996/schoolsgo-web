import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/hover_effect_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class SectionsReorderScreen extends StatefulWidget {
  const SectionsReorderScreen({
    Key? key,
    required this.adminProfile,
    required this.sections,
    required this.teachers,
    required this.students,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<Section> sections;
  final List<Teacher> teachers;
  final List<StudentProfile> students;

  @override
  State<SectionsReorderScreen> createState() => _SectionsReorderScreenState();
}

class _SectionsReorderScreenState extends State<SectionsReorderScreen> {
  List<Section> sectionsList = [];
  List<Teacher> teachersList = [];
  List<StudentProfile> studentsList = [];

  @override
  void initState() {
    super.initState();
    sectionsList = widget.sections;
    teachersList = widget.teachers;
    studentsList = widget.students;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sections Info"),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Save the new order
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: sectionsDataTable(),
    );
  }

  Widget sectionsDataTable() {
    return Container(
      margin: const EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 650,
          child: ReorderableListView(
            clipBehavior: Clip.none,
            buildDefaultDragHandles: true,
            physics: const BouncingScrollPhysics(),
            scrollController: ScrollController(),
            onReorder: (int oldIndex, int newIndex) async {
              setState(() {
                sectionsList[oldIndex].seqOrder = newIndex + 1;
                sectionsList.sort((a, b) => (a.seqOrder ?? 0).compareTo(b.seqOrder ?? 0));
                sectionsList.mapIndexed((index, es) {
                  es.seqOrder = index + 1;
                });
              });
            },
            children: [
              ...sectionsList.mapIndexed(
                (index, section) => OnHoverColorChangeWidget(
                  key: Key(index.toString()),
                  child: sectionRow(section, index),
                  hoverColor: Colors.grey.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionRow(Section section, int index) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          padding: const EdgeInsets.all(2),
          child: Row(
            children: [
              tableCell(
                const Icon(Icons.back_hand_outlined),
                width: 50,
                alignment: Alignment.centerRight,
              ),
              tableCell(
                Text("${index + 1}"),
                width: 50,
                alignment: Alignment.centerRight,
              ),
              tableCell(
                Text(section.sectionName ?? "-"),
                width: 150,
              ),
              tableCell(
                Text(teachersList.where((et) => et.teacherId == section.classTeacherId).firstOrNull?.teacherName ?? "-"),
                width: 250,
              ),
              tableCell(
                Text(studentsList.where((es) => es.sectionId == section.sectionId && es.status == 'active').length.toString()),
                width: 70,
                alignment: Alignment.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row headersRow() {
    return Row(
      children: [
        tableCell(
          const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
          width: 50,
        ),
        tableCell(
          const Text('Order', style: TextStyle(fontWeight: FontWeight.bold)),
          width: 50,
        ),
        tableCell(
          const Text('Section Name', style: TextStyle(fontWeight: FontWeight.bold)),
          width: 150,
        ),
        tableCell(
          const Text('Class Teacher', style: TextStyle(fontWeight: FontWeight.bold)),
          width: 250,
        ),
        tableCell(
          const Text('Students', style: TextStyle(fontWeight: FontWeight.bold)),
          width: 70,
        ),
      ],
    );
  }

  Widget tableCell(
    Widget child, {
    double height = 50,
    double width = 150,
    bool emboss = true,
    double margin = 2.0,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Container(
      margin: EdgeInsets.all(margin),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 5,
        depth: 40,
        height: height,
        width: width,
        emboss: emboss,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );
  }

  DataTable dataTableV1() {
    return DataTable(
      key: UniqueKey(), // Add a key to the DataTable
      columns: const [
        DataColumn(label: Text('Seq. No.')),
        DataColumn(label: Text('Section Name')),
        DataColumn(label: Text('Class Teacher')),
        DataColumn(label: Text('No. Of Students')),
      ],
      rows: sectionsList.map((section) {
        return DataRow(
          key: ValueKey(section.sectionId),
          cells: [
            DataCell(Text(section.seqOrder?.toString() ?? "-")),
            DataCell(Text(section.sectionName ?? "-")),
            DataCell(Text(teachersList.where((et) => et.teacherId == section.classTeacherId).firstOrNull?.teacherName ?? "-")),
            DataCell(Text(studentsList.where((es) => es.sectionId == section.sectionId && es.status == 'active').length.toString())),
          ],
        );
      }).toList(),
    );
  }
}
