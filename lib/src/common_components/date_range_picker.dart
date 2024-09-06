import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DatePickerWidget extends StatefulWidget {
  final Function(String dateSelectionType, DateTime? startDate, DateTime? endDate) onDateSelected;

  const DatePickerWidget({
    super.key,
    required this.onDateSelected,
    this.thresholdStartDate,
    this.thresholdEndDate,
  });

  final DateTime? thresholdStartDate;
  final DateTime? thresholdEndDate;

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedMode = "Range"; // Default mode
  final DateRangePickerController _datePickerController = DateRangePickerController();

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        _startDate = args.value.startDate;
        _endDate = args.value.endDate;
      } else if (args.value is DateTime) {
        _startDate = args.value;
        _endDate = null;
      }
      // Pass the selected dates to the parent widget
      widget.onDateSelected(_selectedMode, _startDate, _endDate);
    });
  }

  void _updatePickerMode(String newValue) {
    setState(() {
      _selectedMode = newValue;
      if (_selectedMode == "Single Date") {
        _datePickerController.view = DateRangePickerView.month;
        _datePickerController.selectedDate = DateTime.now();
      } else if (_selectedMode == "Range") {
        _datePickerController.view = DateRangePickerView.month;
        _datePickerController.selectedRange = null;
      } else if (_selectedMode == "Month") {
        _datePickerController.view = DateRangePickerView.year;
        _datePickerController.selectedRange = null;
      } else if (widget.thresholdStartDate != null && widget.thresholdEndDate != null && _selectedMode == "Whole Year") {
        _datePickerController.view = DateRangePickerView.month;
        _datePickerController.selectedRange = PickerDateRange(widget.thresholdStartDate, widget.thresholdEndDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: buildRadioListTileForPickerSelection("Single Date")),
            Expanded(child: buildRadioListTileForPickerSelection("Range")),
            Expanded(child: buildRadioListTileForPickerSelection("Month")),
            if (widget.thresholdStartDate != null && widget.thresholdEndDate != null)
              Expanded(child: buildRadioListTileForPickerSelection("Whole Year")),
          ],
        ),
        const SizedBox(height: 20),
        // Only show the date picker if Single Date or Range is selected
        SfDateRangePicker(
          minDate: widget.thresholdStartDate,
          maxDate: widget.thresholdEndDate,
          controller: _datePickerController,
          onSelectionChanged: _onSelectionChanged,
          selectionMode: _selectedMode == "Single Date" ? DateRangePickerSelectionMode.single : DateRangePickerSelectionMode.extendableRange,
          monthViewSettings: const DateRangePickerMonthViewSettings(
            enableSwipeSelection: true,
            showTrailingAndLeadingDates: true,
            showWeekNumber: false,
          ),
        ),
      ],
    );
  }

  Widget buildRadioListTileForPickerSelection(String pickerType) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RadioListTile<String>(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(pickerType),
        ),
        value: pickerType,
        groupValue: _selectedMode,
        onChanged: (String? value) => _updatePickerMode(value!),
      ),
    );
  }
}
