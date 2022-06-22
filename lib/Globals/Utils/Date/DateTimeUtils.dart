import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// This class contains all the Utils used for Date recollection and treatment.
class DateTimeUtils {

  Future<DateTime> selectDate(ctx) {
    // Initial Vars
    var startDate = DateTime.now();
    var pickedDate = DateTime.now();
    var title;
    var widgetPicker;
    // Different types of pickers
    Widget dateTimePicker = CupertinoTheme(
      data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: Theme.of(ctx).textTheme.bodyText1,
          )
      ),
      child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, 0, 0),
          minimumDate: startDate.subtract(Duration(days: 365*80)),
          maximumDate: DateTime(startDate.year, startDate.month, 31, 0, 0),
          minimumYear: 1941,
          maximumYear: startDate.year,
          use24hFormat: true,
          onDateTimeChanged: (val) {
            pickedDate = val;
          }
      ),
    );

    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Material(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height*0.40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: MediaQuery.of(ctx).size.height*0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Text(title,
                          style: Theme.of(ctx).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,)
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(ctx).size.width*0.01),
                    child: widgetPicker,
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
                              AppLocalizations.of(ctx)!.entendido,
                              style: Theme.of(ctx).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          }
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(ctx).size.height*0.02),
              ],
            ),
          ),
        )
    );
    return Future.value(pickedDate);
  }

}
