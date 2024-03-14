import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
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
      body: DataTable(
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
      ),
    );
  }
}
