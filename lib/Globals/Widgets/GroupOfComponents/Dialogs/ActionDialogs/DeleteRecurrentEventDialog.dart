import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';

class DeleteRecurrentEventDialog extends StatefulWidget {
  const DeleteRecurrentEventDialog({Key? key}) : super(key: key);

  @override
  _DeleteRecurrentEventDialogState createState() => _DeleteRecurrentEventDialogState();
}

class _DeleteRecurrentEventDialogState extends State<DeleteRecurrentEventDialog> {

  int _value = 0;

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 10, left: 10),
                    child: Text(AppLocalizations.of(context)!.deleteRecurrentEvent, style: Theme.of(context).textTheme.bodyText1?.copyWith(height: 1.5),textAlign: TextAlign.center,),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01, horizontal: MediaQuery.of(context).size.width*0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                        title: Text(
                          AppLocalizations.of(context)!.thisEvent,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        leading: Transform.scale(
                          scale: 1.2,
                          child: Radio(
                            value: 1,
                            groupValue: _value,
                            activeColor: Theme.of(context).primaryColor,
                            fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                            onChanged: (value) {
                              setState(() {
                                _value = int.parse(value.toString());
                              });
                            },
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                        title: Text(
                          AppLocalizations.of(context)!.thisEventAndRest,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        leading: Transform.scale(
                          scale: 1.2,
                          child: Radio(
                            value: 2,
                            groupValue: _value,
                            activeColor: Theme.of(context).primaryColor,
                            fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                            onChanged: (value) {
                              setState(() {
                                _value = int.parse(value.toString());
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: _value == 0 ? Colors.red.withOpacity(0.3) : Colors.red,
                          fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.delete,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: _value == 0 ? AppColors.white.withOpacity(0.5) : AppColors.white),
                        ),
                        icon: Icon(Icons.delete_outline, size: MediaQuery.of(context).size.width*0.06, color: _value == 0 ? AppColors.white.withOpacity(0.5) : AppColors.white),
                        onPressed: _value != 0 ? () {
                          Navigator.pop(context, [true, _value]);
                        } : null,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width*0.01),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: Theme.of(context).primaryColor,
                          fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark,),
                        ),
                        icon: Icon(Icons.cancel_outlined, size: MediaQuery.of(context).size.width*0.06, color: Theme.of(context).primaryColorDark,),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                top: -83,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: Size(70, 70), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Colors.red, // button color
                          child: InkWell(
                            onTap: () async {
                            },
                            child: Icon(Icons.priority_high, color: Colors.white, size: 45,), // icon
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

}


