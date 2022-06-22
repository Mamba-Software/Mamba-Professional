import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectDateTimeDialog extends StatefulWidget {

  String title;
  SelectDateTimeDialog({Key? key, required this.title}) : super(key: key);

  @override
  _SelectDateTimeDialogState createState() => _SelectDateTimeDialogState();
}

class _SelectDateTimeDialogState extends State<SelectDateTimeDialog> {
  // Initial Vars
  var startDate = DateTime.now();
  var pickedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
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
                      style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold),
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
                        dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText1,
                      )
                  ),
                  child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, 0, 0),
                      minimumDate: startDate.subtract(Duration(days: 365*80)),
                      maximumDate: DateTime(startDate.year, 12, 31, 0, 0),
                      minimumYear: 1941,
                      maximumYear: startDate.year,
                      use24hFormat: true,
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
                          style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
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
