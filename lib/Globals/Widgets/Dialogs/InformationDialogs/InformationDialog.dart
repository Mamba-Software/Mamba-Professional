import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../Styles/Styles.dart';

class InformationDialog extends StatelessWidget {
  final String text;
  const InformationDialog({Key? key, required this.text}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.only(top: 40, bottom: 10, left: 20, right: 20),
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
                  child: Text(text, style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5),textAlign: TextAlign.center,),
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.close, style: Theme.of(context).textTheme.bodyText2?.copyWith(decoration: TextDecoration.underline), ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
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
                          color: Styles.accent, // button color
                          child: InkWell(
                            onTap: () async {
                            },
                            child: Icon(Icons.info_outlined, color: Colors.white, size: 45,), // icon
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