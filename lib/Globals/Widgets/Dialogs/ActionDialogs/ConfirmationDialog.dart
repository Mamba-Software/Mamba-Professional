import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import '../../../Styles/Styles.dart';

class ConfirmationDialog extends StatelessWidget {
  final String text;
  const ConfirmationDialog({Key? key, required this.text}) : super(key: key);


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
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 24.0, right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          text,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5),
                          textAlign: TextAlign.center,),
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
                          backgroundColor: Theme.of(context).accentColor,
                          fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.confirm,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                        ),
                        icon: Icon(Icons.check_circle_outline, size: MediaQuery.of(context).size.width*0.06, color: Colors.white,),
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
                top: -83,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: Size(70, 70), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Theme.of(context).accentColor,
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