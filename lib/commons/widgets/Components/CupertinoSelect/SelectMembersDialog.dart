import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectMembersDialog extends StatefulWidget {

  String title;
  int initialMembers;
  SelectMembersDialog({super.key, required this.title, required this.initialMembers});

  @override
  _SelectMembersDialogState createState() => _SelectMembersDialogState();
}

class _SelectMembersDialogState extends State<SelectMembersDialog> {

  // Initial Vars
  int pickedMembers = 0;
  int membersMax = 100;

  @override
  void initState() {
    pickedMembers = widget.initialMembers;
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
                            initialItem: widget.initialMembers
                        ),
                        itemExtent: 40.0,
                        backgroundColor: Colors.transparent,
                        onSelectedItemChanged: (int index) {
                          pickedMembers = index+1;
                        },
                        children: List<Widget>.generate(
                            membersMax, (int index) {
                          var member = index+1;
                          return Center(
                            child: Text(
                              member.toString(),
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
                  shape: const StadiumBorder(),
                  heroTag: "44",
                  onPressed: () {
                    Navigator.pop(context, pickedMembers);
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
