import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectDateAndTimeDialog extends StatefulWidget {

  String title;
  DateTime startDate;
  bool onlyFuture;
  SelectDateAndTimeDialog({super.key, required this.title, required this.startDate, required this.onlyFuture});

  @override
  _SelectDateAndTimeDialogState createState() => _SelectDateAndTimeDialogState();
}

class _SelectDateAndTimeDialogState extends State<SelectDateAndTimeDialog> {
  // Initial Vars  
  var pickedDate = DateTime.now();
  
  @override
  void initState() {
    pickedDate = widget.startDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height*0.40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center
                    )
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: Theme.of(context).textTheme.bodyLarge,
                      )
                  ),
                  child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.dateAndTime,
                      initialDateTime: DateTime(widget.startDate.year, widget.startDate.month, widget.startDate.day, widget.startDate.hour,widget.startDate.minute),
                      minimumDate: widget.onlyFuture ? (DateTime.now()).subtract(const Duration(minutes: 1)): widget.startDate.subtract(const Duration(days: 365*80)),
                      maximumDate: widget.onlyFuture ? (DateTime.now()).add(const Duration(days: 365*1)): DateTime(widget.startDate.year, 12, 31, 0, 0),
                      maximumYear: DateTime.now().year+1,
                      use24hFormat: true,
                      minuteInterval: 15,
                      onDateTimeChanged: (val) {
                        pickedDate = val;
                      }
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: TextButton(
                      child: Text(
                          AppLocalizations.of(context)!.entendido,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
                      ),
                      onPressed: () {
                        Navigator.pop(context, pickedDate);

                      }
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.02),
          ],
        ),
      ),
    );
  }
}
