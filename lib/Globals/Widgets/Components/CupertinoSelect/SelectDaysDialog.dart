import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectDaysDialog extends StatefulWidget {

  String title;
  int intialDays;
  int? daysMax;
  SelectDaysDialog({super.key, required this.title, required this.intialDays, this.daysMax});

  @override
  _SelectDaysDialogState createState() => _SelectDaysDialogState();
}

class _SelectDaysDialogState extends State<SelectDaysDialog> {

  // Initial Vars
  int pickedDays = 0;
  int daysMax = 30;

  @override
  void initState() {
    pickedDays = widget.intialDays;
    if (widget.daysMax != null) {
      daysMax = widget.daysMax!;
    }
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
            SizedBox(height: MediaQuery.of(context).size.height*0.03),
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                child: CupertinoTheme(
                    data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: Theme.of(context).textTheme.bodyMedium,
                        )
                    ),
                    child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem: widget.intialDays
                        ),
                        itemExtent: 40.0,
                        backgroundColor: Colors.transparent,
                        onSelectedItemChanged: (int index) {
                          pickedDays = index+1;
                        },
                        children: List<Widget>.generate(
                            daysMax, (int index) {
                          var days = index+1;
                          return Center(
                            child: Text(
                              days.toString(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }
                        )
                    )
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                FloatingActionButton.extended(
                  heroTag: "42",
                  onPressed: () {
                    Navigator.pop(context, pickedDays);
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  icon: Container(),
                  label: Text(
                      AppLocalizations.of(context)!.confirm,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).primaryColorDark)
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
