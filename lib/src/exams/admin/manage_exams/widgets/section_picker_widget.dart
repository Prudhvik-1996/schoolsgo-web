import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';

// ignore: must_be_immutable
class MultipleSectionPickerWidget extends StatefulWidget {
  MultipleSectionPickerWidget({
    Key? key,
    required this.selectedSectionsList,
    required this.availableSections,
  }) : super(key: key);

  List<Section> selectedSectionsList;
  List<Section> availableSections;

  @override
  _MultipleSectionPickerWidgetState createState() => _MultipleSectionPickerWidgetState();
}

class _MultipleSectionPickerWidgetState extends State<MultipleSectionPickerWidget> {
  bool isSectionPickerOpen = false;

  @override
  Widget build(BuildContext context) {
    return _sectionPicker();
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.all(10),
        child: isSectionPickerOpen
            ? Container(
                margin: const EdgeInsets.all(10),
                child: ClayContainer(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: _selectSectionExpanded(),
                ),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ClayButton(
        depth: 40,
        spread: widget.selectedSectionsList.contains(section) ? 0 : 2,
        surfaceColor: widget.selectedSectionsList.contains(section) ? Colors.blue.shade300 : clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(5),
          child: InkWell(
            onTap: () {
              HapticFeedback.vibrate();
              setState(() {
                if (widget.selectedSectionsList.contains(section)) {
                  widget.selectedSectionsList.remove(section);
                } else {
                  widget.selectedSectionsList.add(section);
                }
              });
              // _applyFilters();
            },
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  section.sectionName!,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectSectionExpanded() {
    return Container(
      width: double.infinity,
      // margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.vibrate();
              setState(() {
                isSectionPickerOpen = !isSectionPickerOpen;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      widget.selectedSectionsList.isEmpty
                          ? "Select a section"
                          : "Sections: ${widget.selectedSectionsList.map((e) => e.sectionName).join(", ")}",
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: const Icon(Icons.expand_less),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          GridView.count(
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery.of(context).size.width ~/ 125,
            shrinkWrap: true,
            children: widget.availableSections.map((e) => buildSectionCheckBox(e)).toList(),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.selectedSectionsList.map((e) => e).toList().forEach((e) {
                        widget.selectedSectionsList.remove(e);
                      });
                      widget.selectedSectionsList.addAll(widget.availableSections.map((e) => e).toList());
                    });
                  },
                  child: ClayButton(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 25,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: const Text("Select All"),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.selectedSectionsList = [];
                    });
                  },
                  child: ClayButton(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 25,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: const Text("Clear"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 20,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: InkWell(
        onTap: () {
          HapticFeedback.vibrate();
          setState(() {
            isSectionPickerOpen = !isSectionPickerOpen;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    widget.selectedSectionsList.isEmpty
                        ? "Select a section"
                        : "Sections: ${widget.selectedSectionsList.map((e) => e.sectionName).join(", ")}",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: const Icon(Icons.expand_more),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SingleSectionPickerWidget extends StatefulWidget {
  SingleSectionPickerWidget({
    Key? key,
    required this.selectedSection,
    required this.availableSections,
  }) : super(key: key);

  Section? selectedSection;
  List<Section> availableSections;

  @override
  _SingleSectionPickerWidgetState createState() => _SingleSectionPickerWidgetState();
}

class _SingleSectionPickerWidgetState extends State<SingleSectionPickerWidget> {
  bool isSectionPickerOpen = false;

  @override
  Widget build(BuildContext context) {
    return _sectionPicker();
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.all(10),
        child: isSectionPickerOpen
            ? Container(
                margin: const EdgeInsets.all(10),
                child: ClayContainer(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: _selectSectionExpanded(),
                ),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ClayButton(
        depth: 40,
        spread: widget.selectedSection != null && widget.selectedSection!.sectionId == section.sectionId ? 0 : 2,
        surfaceColor: widget.selectedSection != null && widget.selectedSection!.sectionId == section.sectionId
            ? Colors.blue.shade300
            : clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(5),
          child: InkWell(
            onTap: () {
              HapticFeedback.vibrate();
              setState(() {
                if (widget.selectedSection != null && widget.selectedSection!.sectionId == section.sectionId) {
                  widget.selectedSection = null;
                } else {
                  widget.selectedSection = section;
                }
              });
              // _applyFilters();
            },
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  section.sectionName!,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectSectionExpanded() {
    return Container(
      width: double.infinity,
      // margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.vibrate();
              setState(() {
                isSectionPickerOpen = !isSectionPickerOpen;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      widget.selectedSection == null ? "Select a section" : "Section: ${widget.selectedSection!.sectionName ?? "-"}",
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: const Icon(Icons.expand_less),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          GridView.count(
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery.of(context).size.width ~/ 125,
            shrinkWrap: true,
            children: widget.availableSections.map((e) => buildSectionCheckBox(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 20,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: InkWell(
        onTap: () {
          HapticFeedback.vibrate();
          setState(() {
            isSectionPickerOpen = !isSectionPickerOpen;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    widget.selectedSection == null ? "Select a section" : "Section: ${widget.selectedSection!.sectionName ?? "-"}",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: const Icon(Icons.expand_more),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
