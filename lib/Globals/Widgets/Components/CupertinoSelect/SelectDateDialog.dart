import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';

class SelectDateDialog extends StatefulWidget {

  String title;
  DateTime startDate;
  bool onlyFuture;
  bool dateOfWeek;
  SelectDateDialog({Key? key, required this.title, required this.startDate, required this.onlyFuture, required this.dateOfWeek}) : super(key: key);

  @override
  _SelectDateDialogState createState() => _SelectDateDialogState();
}

class _SelectDateDialogState extends State<SelectDateDialog> {
  
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
            widget.dateOfWeek == true ? Container(
              height: MediaQuery.of(context).size.height*0.24,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width*0.15,
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                    child: Text(
                        StringUtils().toCapitalized(DateFormat('EE', Localizations.localeOf(context).languageCode).format(pickedDate)),
                        style: Theme.of(context).textTheme.bodyText1,
                        textAlign: TextAlign.right
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.02, horizontal: MediaQuery.of(context).size.width*0.02),
                      child: CupertinoTheme(
                        data: CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText1,
                            )
                        ),
                        child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: DateTime(widget.startDate.year, widget.startDate.month, widget.startDate.day, widget.startDate.hour, widget.startDate.minute),
                            minimumDate: widget.onlyFuture ? (DateTime.now()).subtract(const Duration(minutes: 1)): widget.startDate.subtract(Duration(days: 365*80)),
                            maximumDate: widget.onlyFuture ? (DateTime.now()).add(Duration(days: 365*1)): DateTime(widget.startDate.year, 12, 31, 0, 0),
                            maximumYear:  widget.onlyFuture ? DateTime.now().year+1 : DateTime.now().year,
                            use24hFormat: true,
                            onDateTimeChanged: (val) {
                              setState(() {
                                pickedDate = val;
                              });
                            }
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ) : Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.02, horizontal: MediaQuery.of(context).size.width*0.02),
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText1,
                      )
                  ),
                  child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: DateTime(widget.startDate.year, widget.startDate.month, widget.startDate.day, widget.startDate.hour, widget.startDate.minute),
                      minimumDate: widget.onlyFuture ? (DateTime.now()).subtract(Duration(minutes: 1)): widget.startDate.subtract(Duration(days: 365*80)),
                      maximumDate: widget.onlyFuture ? (DateTime.now()).add(Duration(days: 365*1)): DateTime(widget.startDate.year, 12, 31, 0, 0),
                      maximumYear:  widget.onlyFuture ? DateTime.now().year+1 : DateTime.now().year,
                      use24hFormat: true,
                      onDateTimeChanged: (val) {
                        setState(() {
                          pickedDate = val;
                        });
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
                  heroTag: null,
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
