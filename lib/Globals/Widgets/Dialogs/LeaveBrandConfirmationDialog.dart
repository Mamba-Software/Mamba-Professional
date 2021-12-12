import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import '../../Styles.dart';
import '../CircularImage.dart';

class LeaveBrandConfirmationDialog extends StatefulWidget {
  final String text;
  const LeaveBrandConfirmationDialog({Key? key, required this.text}) : super(key: key);

  @override
  _LeaveBrandConfirmationDialogState createState() => _LeaveBrandConfirmationDialogState();
}

class _LeaveBrandConfirmationDialogState extends State<LeaveBrandConfirmationDialog> {

  @override
  Widget build(BuildContext context) {


    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.only(top: 80, bottom: 10, left: 10, right: 10),
        height: MediaQuery.of(context).size.height*0.3,
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
                        child: Text(widget.text, style: Styles.purpleTextStyle.copyWith(fontSize: 16, height: 1.5), textAlign: TextAlign.center,),
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
                        heroTag: "16",
                        label: Text(AppLocalizations.of(context)!.leave),
                        icon: Icon(Icons.exit_to_app),
                        backgroundColor: Colors.red,
                        foregroundColor: Styles.white,
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width*0.01),
                      FloatingActionButton.extended(
                        heroTag: "17",
                        icon: Icon(Icons.cancel_outlined, size: 30,),
                        label: Text(AppLocalizations.of(context)!.cancel),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Styles.white,
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                bottom: 0,
                top: -150,
                child: Column(
                  children: <Widget>[
                    CircularImage(
                      size: MediaQuery.of(context).size.width*0.25,
                      image: currentBrand.logoUrl,
                      color: Theme.of(context).accentColor,
                      borderWidth: 2,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    Expanded(
                      child: Text(
                        currentBrand.name!,
                        style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 23),
                        textAlign: TextAlign.left,
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