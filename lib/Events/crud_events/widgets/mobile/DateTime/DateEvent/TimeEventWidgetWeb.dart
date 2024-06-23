import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/utils/enumAddEditEvent.dart';

Widget timeEventWidgetWeb(
  BuildContext context,
  DateTime startDate,
  bool isBeforeEdit,
  Locale locale,
  TimeOfDay startTime,
  TimeOfDay endTime,
  List<String> timeStrings,
) {
  double defaultWidth = 100;

  return Column(
    children: [
      Row(
        children: [
          Icon(
            Icons.schedule,
            color: AppColors.grey,
            size: iconSizeBig,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.05),
          SizedBox(
            width: defaultWidth,
            child: _buildEditableDropdown(
              context,
              label: 'Start Time',
              initialValue: _formatTimeOfDay(startTime),
              onChanged: (newValue) {
                context
                    .read<CrudEventCubit>()
                    .editEventInfo(_parseTime(newValue), EditEventType.time);
              },
              items: timeStrings,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                '-',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          SizedBox(
            width: defaultWidth,
            child: _buildEditableDropdown(
              context,
              label: 'End Time',
              initialValue: _formatTimeOfDay(endTime),
              onChanged: (newValue) {
                context
                    .read<CrudEventCubit>()
                    .editEventInfo(_parseTime(newValue), EditEventType.time);
              },
              items: timeStrings,
            ),
          ),
        ],
      ),
    ],
  );
}

String _formatTimeOfDay(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  final format = DateFormat('HH:mm'); // use 'HH:mm' for 24 hour format
  return format.format(dt);
}

TimeOfDay _parseTime(String input) {
  final format = DateFormat('HH:mm'); // use 'HH:mm' for 24 hour format
  final now = DateTime.now();
  final dt = format.parse(input);
  return TimeOfDay(hour: dt.hour, minute: dt.minute);
}

Widget _buildEditableDropdown(
  BuildContext context, {
  required String label,
  required String initialValue,
  required ValueChanged<String> onChanged,
  required List<String> items,
}) {
  TextEditingController controller = TextEditingController(text: initialValue);
  FocusNode focusNode = FocusNode();

  void showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200, maxWidth: 100),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                  onTap: () {
                    controller.text = items[index];
                    onChanged(items[index]);
                    Navigator.pop(context); // Cerrar el diálogo
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.subtitle1),
      SizedBox(height: 8),
      Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            ),
            onChanged: (value) {
              if (items.contains(value)) {
                onChanged(value);
              }
            },
            onFieldSubmitted: (value) {
              if (!items.contains(value)) {
                controller.text = initialValue;
              } else {
                onChanged(value);
              }
            },
            onTap: () {
              showPopup(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_drop_down),
            onPressed: () {
              showPopup(context);
            },
          ),
        ],
      ),
    ],
  );
}
