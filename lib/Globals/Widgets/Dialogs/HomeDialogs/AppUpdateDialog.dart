import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Constants.dart';
import '../../../GlobalVars.dart';
import '../../../Styles/Styles.dart';

class AppUpdateDialog extends StatelessWidget {

  const AppUpdateDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.only(top: 40, bottom: 30, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(AppLocalizations.of(context)!.updateAppTitle, style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold,height: 1.5),textAlign: TextAlign.center,),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                  Flexible(
                    child: Text(AppLocalizations.of(context)!.updateAppText, style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5),textAlign: TextAlign.center,),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                  Center(
                    child: Container(
                        height: MediaQuery.of(context).size.height*0.15,
                        child: Image.asset(Constants.appUpdateImage)
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                  OutlinedButton(
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
                    child: Text(
                      AppLocalizations.of(context)!.update,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white,),
                    ),
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        await launch(androidGooglePlayUrl);
                      } else {
                        await launch(iosAppStoreUrl);
                      }
                    },
                  ),
                ],
              ),
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
                            child: Icon(Icons.update_outlined, color: Colors.white, size: 40,), // icon
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