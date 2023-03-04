import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({
    Key? key,
    required this.isSearchBarSelectedByDefault,
    required this.onComplete,
    required this.receiptNumbers,
    required this.isSearchButtonSelected,
  }) : super(key: key);

  final bool isSearchBarSelectedByDefault;
  final Function onComplete;
  final List<String> receiptNumbers;
  final Function isSearchButtonSelected;

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  bool _isSelected = false;
  TextEditingController _searchKeyController = TextEditingController();
  int? foundIndex;
  bool _isLoading = false;
  List<int> foundIndices = [];

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSearchBarSelectedByDefault;
    _searchKeyController = TextEditingController();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return _isSelected ? buildSearchBar() : buildSearchIconButton();
  }

  Widget buildSearchBar() {
    bool isKeyFound = _searchKeyController.text.trim().isEmpty || widget.receiptNumbers.contains(_searchKeyController.text.trim());
    return SizedBox(
      width: MediaQuery.of(context).size.width >= 400 ? 400 : 300,
      child: InputDecorator(
        isFocused: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: isKeyFound
                  ? Colors.blue
                  : Colors.red,
            ),
          ),
          label: Text(
            isKeyFound ? "Receipt Number" : "Receipt Number not found",
            style: TextStyle(
              color: isKeyFound
                  ? Colors.blue
                  : Colors.red,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width >= 400 ? 240 : 180,
                child: Center(
                  child: buildSearchTextField(),
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            if (isKeyFound) buildSearchButton(),
            if (isKeyFound) const SizedBox(
              width: 5,
            ),
            if (isKeyFound) const CustomVerticalDivider(
              hasCircularBorder: false,
              color: Colors.grey,
              width: 1,
            ),
            if (isKeyFound) const SizedBox(
              width: 5,
            ),
            if (_isLoading)
              Center(
                child: Image.asset(
                  'assets/images/gear-loader.gif',
                  height: 50,
                  width: 50,
                ),
              ),
            foundIndices.isEmpty || foundIndex == null || _isLoading ? const SizedBox() : buildPrevOccurrenceButton(),
            const SizedBox(
              width: 5,
            ),
            _searchKeyController.text.trim().isEmpty || _isLoading ? const SizedBox() : buildOccurrenceCount(),
            const SizedBox(
              width: 5,
            ),
            foundIndices.isEmpty || foundIndex == null || _isLoading ? const SizedBox() : buildNextOccurrenceButton(),
            const SizedBox(
              width: 5,
            ),
            buildCancelSearchFilterButton(),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchTextField() {
    return TextField(
      enabled: true,
      autofocus: true,
      style: const TextStyle(
        fontSize: 12,
      ),
      onTap: () {
        _searchKeyController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _searchKeyController.text.length,
        );
      },
      onChanged: (String e) {
        debugPrint(e);
        setState(() {
          foundIndices.clear();
          foundIndex = null;
        });
      },
      onSubmitted: (String e) {
        searchNext(e);
      },
      controller: _searchKeyController,
      keyboardType: TextInputType.text,
      maxLines: 1,
      textAlignVertical: TextAlignVertical.center,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 18),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: "Receipt Number",
        hintStyle: TextStyle(fontSize: 12),
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget buildSearchButton() {
    return InkWell(
      onTap: () {
        searchNext(_searchKeyController.text);
      },
      child: const Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Icon(
          Icons.search,
          size: 15,
        ),
      ),
    );
  }

  void searchNext(String searchKey) {
    setState(() => _isLoading = true);
    debugPrint("$foundIndices, $foundIndex");
    setState(() {
      if (foundIndices.isEmpty) {
        for (int i = 0; i < widget.receiptNumbers.length; i++) {
          if (widget.receiptNumbers[i] == searchKey) {
            foundIndices.add(i);
          }
        }
      }
      if (foundIndices.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      if (foundIndex != null) {
        if (foundIndex == foundIndices.length - 1) {
          foundIndex = 0;
        } else {
          foundIndex = foundIndex! + 1;
        }
      } else {
        foundIndex = 0;
      }
    });
    widget.onComplete(foundIndex == null || foundIndices.isEmpty ? -1 : foundIndices[foundIndex!]);
    debugPrint("$foundIndices, $foundIndex");
    setState(() => _isLoading = false);
  }

  void searchPrev(String searchKey) {
    setState(() => _isLoading = true);
    debugPrint("$foundIndices, $foundIndex");
    setState(() {
      if (foundIndices.isEmpty) {
        for (int i = 0; i < widget.receiptNumbers.length; i++) {
          if (widget.receiptNumbers[i] == searchKey) {
            foundIndices.add(i);
          }
        }
      }
      if (foundIndices.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      if (foundIndex != null) {
        if (foundIndex == 0) {
          foundIndex = foundIndices.length - 1;
        } else {
          foundIndex = foundIndex! - 1;
        }
      } else {
        foundIndex = 0;
      }
    });
    widget.onComplete(foundIndex == null || foundIndices.isEmpty ? -1 : foundIndices[foundIndex!]);
    debugPrint("$foundIndices, $foundIndex");
    setState(() => _isLoading = false);
  }

  Widget buildPrevOccurrenceButton() {
    return InkWell(
      onTap: () => searchPrev(_searchKeyController.text),
      child: const Center(
        child: Icon(
          Icons.arrow_left,
          size: 15,
        ),
      ),
    );
  }

  Widget buildOccurrenceCount() {
    return InkWell(
      onTap: () {},
      child: Center(
        child: _isLoading
            ? Image.asset(
                'assets/images/gear-loader.gif',
                fit: BoxFit.scaleDown,
              )
            : Text(
                foundIndex == null
                    ? ""
                    : foundIndices.isEmpty
                        ? "0"
                        : "${(foundIndex ?? 0) + 1} / ${foundIndices.length}",
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
      ),
    );
  }

  Widget buildNextOccurrenceButton() {
    return InkWell(
      onTap: () => searchNext(_searchKeyController.text),
      child: const Center(
        child: Icon(
          Icons.arrow_right,
          size: 15,
        ),
      ),
    );
  }

  Widget buildSearchIconButton() {
    return InkWell(
      onTap: () {
        if (_isSelected) return;
        setState(() {
          _isSelected = true;
          widget.isSearchButtonSelected(_isSelected);
        });
      },
      child: const Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Icon(Icons.search),
      ),
    );
  }

  Widget buildCancelSearchFilterButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _isSelected = false;
          widget.isSearchButtonSelected(_isSelected);
        });
      },
      child: const Center(
        child: Icon(
          Icons.clear,
          size: 15,
        ),
      ),
    );
  }
}
