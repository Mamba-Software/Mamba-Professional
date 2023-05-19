import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectTimeDialog extends StatefulWidget {

  String title;
  DateTime startDate;
  bool onlyFuture;
  SelectTimeDialog({Key? key, required this.title, required this.startDate, required this.onlyFuture}) : super(key: key);

  @override
  _SelectTimeDialogDialogState createState() => _SelectTimeDialogDialogState();
}

class _SelectTimeDialogDialogState extends State<SelectTimeDialog> {
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
            SizedBox(height: MediaQuery.of(context).size.height*0.03),
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
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: DateTime(widget.startDate.year, widget.startDate.month, widget.startDate.day, widget.startDate.hour,widget.startDate.minute),
                      minimumDate: widget.onlyFuture ? (DateTime.now()).subtract(Duration(minutes: 1)): widget.startDate.subtract(Duration(days: 365*80)),
                      maximumDate: DateTime(widget.startDate.year, 12, 31, 0, 0),
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
                FloatingActionButton.extended(
                  heroTag: "45",
                  onPressed: () {
                    Navigator.pop(context, pickedDate);
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  icon: Container(),
                  label: Text(
                      AppLocalizations.of(context)!.confirm,
                      style: Theme.of(context).textTheme.headline3?.copyWith(color: Theme.of(context).primaryColorDark)
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.04),
          ],
        ),
      ),
    );
  }
}
