import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../Styles.dart';

class JoinConfirmationDialog extends StatelessWidget {
  final String text;
  const JoinConfirmationDialog({Key? key, required this.text}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 24.0, right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(text, style: Styles.purpleTextStyle.copyWith(fontSize: 16, height: 1.5), textAlign: TextAlign.center,),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: "14",
                        label: Text(AppLocalizations.of(context)!.book),
                        icon: Icon(Icons.check_circle_outline),
                        backgroundColor: Colors.green,
                        foregroundColor: Styles.white,
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width*0.01),
                      FloatingActionButton.extended(
                        heroTag: "15",
                        icon: Icon(Icons.cancel_outlined, size: 30,),
                        label: Text(AppLocalizations.of(context)!.cancel),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Styles.white,
                        onPressed: () async {
                          Navigator.pop(context, false);
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
                          color: Colors.green, // button color
                          child: InkWell(
                            onTap: () async {
                            },
                            child: Icon(Icons.event_available_outlined, color: Colors.white, size: 40,), // icon
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