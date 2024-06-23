import 'package:flutter/material.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/styles/AppColors.dart';

class SelectTimeRange extends StatefulWidget {
  final TimeOfDay initialStartTime;
  final TimeOfDay initialEndTime;

  SelectTimeRange({
    super.key,
    required this.initialStartTime,
    required this.initialEndTime,
  });

  @override
  _SelectTimeRangeState createState() => _SelectTimeRangeState();
}

class _SelectTimeRangeState extends State<SelectTimeRange> with PlatformMixin {
  late TimeOfDay startTime;
  late TimeOfDay endTime;

  @override
  void initState() {
    super.initState();
    startTime = widget.initialStartTime;
    endTime = widget.initialEndTime;
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showCustomTimePicker(
      context: context,
      initialTime: isStartTime ? startTime : endTime,
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          startTime = pickedTime;
          if (!isEndTimeValid(pickedTime, endTime)) {
            endTime =
                addDurationToTimeOfDay(pickedTime, const Duration(minutes: 15));
          }
        } else {
          if (isEndTimeValid(startTime, pickedTime)) {
            endTime = pickedTime;
          }
        }
      });
    }
  }

  bool isEndTimeValid(TimeOfDay start, TimeOfDay end) {
    return end.hour > start.hour ||
        (end.hour == start.hour && end.minute > start.minute);
  }

  TimeOfDay addDurationToTimeOfDay(TimeOfDay time, Duration duration) {
    final int totalMinutes = time.hour * 60 + time.minute + duration.inMinutes;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    return TimeOfDay(hour: hours % 24, minute: minutes);
  }

  Future<TimeOfDay?> showCustomTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
  }) async {
    return await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return CustomTimePickerDialog(
          initialTime: initialTime,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = endTime.hour * 60 +
        endTime.minute -
        startTime.hour * 60 -
        startTime.minute;
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    final durationText =
        "${hours > 0 ? '$hours ${hours > 1 ? 'hours' : 'hour'} ' : ''}${minutes > 0 ? '$minutes minutes' : ''}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Time Range'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text('Start Time: ${startTime.format(context)}'),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: () => _selectTime(context, true),
            ),
            ListTile(
              title: Text('End Time: ${endTime.format(context)}'),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: () => _selectTime(context, false),
            ),
            SizedBox(height: 20),
            Text('Duration: $durationText', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      bottomSheet: GestureDetector(
        onTap: () {
          Navigator.pop(context, {'startTime': startTime, 'endTime': endTime});
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.09,
          width: double.infinity,
          color: Theme.of(context).primaryColor,
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom:
                      isIOS ? MediaQuery.of(context).size.height * 0.01 : 0),
              child: Text(
                context.l10n.confirm,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const CustomTimePickerDialog({Key? key, required this.initialTime})
      : super(key: key);

  @override
  _CustomTimePickerDialogState createState() => _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<CustomTimePickerDialog> {
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
  }

  List<TimeOfDay> generateTimeSlots() {
    List<TimeOfDay> slots = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 15) {
        slots.add(TimeOfDay(hour: hour, minute: minute));
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    List<TimeOfDay> timeSlots = generateTimeSlots();

    return AlertDialog(
      title: Text('Select Time'),
      content: Container(
        width: double.minPositive,
        height: 300.0,
        child: ListView.builder(
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            TimeOfDay timeSlot = timeSlots[index];
            return ListTile(
              title: Text(timeSlot.format(context)),
              onTap: () {
                setState(() {
                  selectedTime = timeSlot;
                });
                Navigator.of(context).pop(selectedTime);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
