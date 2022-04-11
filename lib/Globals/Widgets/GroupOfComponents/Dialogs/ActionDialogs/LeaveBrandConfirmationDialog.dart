import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';

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
        padding: EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 10),
        height: MediaQuery.of(context).size.height*0.3,
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width*0.9,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            currentBrand.name!,
                            style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 24.0, right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(widget.text, style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5),textAlign: TextAlign.center,),
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
                          backgroundColor: Colors.red,
                          fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.leave,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                        ),
                        icon: Icon(Icons.exit_to_app, size: MediaQuery.of(context).size.width*0.06, color: Colors.white,),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
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
                top: -110,
                child: Column(
                  children: <Widget>[
                    CircularImage(
                      size: MediaQuery.of(context).size.width*0.25,
                      image: currentBrand.logoUrl,
                      color: Theme.of(context).accentColor,
                      borderWidth: 2,
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