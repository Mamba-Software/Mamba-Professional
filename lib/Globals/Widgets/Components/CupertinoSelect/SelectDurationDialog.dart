import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectDurationDialog extends StatefulWidget {

  String title;
  String initialDuration;
  SelectDurationDialog({Key? key, required this.title, required this.initialDuration}) : super(key: key);

  @override
  _SelectDurationDialogState createState() => _SelectDurationDialogState();
}

class _SelectDurationDialogState extends State<SelectDurationDialog> {
  // Initial Vars
  String pickedDuration = "";
  List<String> durations = ["0.30","0.45","1.00","1.15","1.30","1.45","2.00","2.15","2.30","2.45","3.00"];

  @override
  void initState() {
    pickedDuration = widget.initialDuration;
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
                          dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText2,
                        )
                    ),
                    child: CupertinoPicker(
                        scrollController: new FixedExtentScrollController(
                            initialItem: durations.indexWhere((element) => element == widget.initialDuration),
                        ),
                        itemExtent: 40.0,
                        backgroundColor: Colors.transparent,
                        onSelectedItemChanged: (int index) {
                          pickedDuration = durations[index];
                        },
                        children: new List<Widget>.generate(
                            durations.length, (int index) {
                          var item = durations[index];
                          var hour = item.split(".")[0];
                          var min = item.split(".")[1];
                          return new Center(
                            child: new Text(
                              "${hour}h ${min}min",
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
                FloatingActionButton.extended(
                  heroTag: "41",
                  onPressed: () {
                    Navigator.pop(context, pickedDuration);
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
