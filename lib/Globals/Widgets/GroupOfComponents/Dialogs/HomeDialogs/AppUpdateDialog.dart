import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:store_redirect/store_redirect.dart';

class AppUpdateDialog extends StatelessWidget {

  bool isMandatory;

  AppUpdateDialog({Key? key, required this.isMandatory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.only(top: 40, bottom: 30, left: 20, right: 20),
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
                  isMandatory ? Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                      Container(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: AppColors.ligthRed.withOpacity(0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.white,
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width*0.01),
                              Text(
                                AppLocalizations.of(context)!.mandatoryUpdate,
                                style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5, color: AppColors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                      ),
                    ],
                  ) : Container(),

                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                  Center(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height*0.15,
                        child: Image.asset(Constants.appUpdateImage)
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      elevation: 4.0,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
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
                      mixpanel!.track('minimum_app_version_update', properties: {'isMandatory': isMandatory});
                      await StoreRedirect.redirect(
                        androidAppId: "com.mamba.mambaprofessionalapp",
                        iOSAppId: "1642701679",
                      );
                      if (isMandatory == false) {
                        await Future.delayed(const Duration(seconds: 3));
                        Navigator.pop(context, true);
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
                      size: const Size(70, 70), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Theme.of(context).colorScheme.secondary,
                          child: InkWell(
                            onTap: () async {
                            },
                            child: const Icon(Icons.update_outlined, color: Colors.white, size: 40,), // icon
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