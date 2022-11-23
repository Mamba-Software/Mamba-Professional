import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectDaysDialog extends StatefulWidget {

  String title;
  int intialDays;
  SelectDaysDialog({Key? key, required this.title, required this.intialDays}) : super(key: key);

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
                          dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText2,
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
                              style: Theme.of(context).textTheme.bodyText1,
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
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: TextButton(
                      child: Text(
                          AppLocalizations.of(context)!.entendido,
                          style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
                      ),
                      onPressed: () {
                        Navigator.pop(context, pickedDays);
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
