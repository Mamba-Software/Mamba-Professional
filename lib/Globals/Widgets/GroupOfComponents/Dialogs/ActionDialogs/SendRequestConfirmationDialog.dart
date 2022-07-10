import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';

class SendRequestConfirmationDialog extends StatelessWidget {
  final String text;
  final Brand brand;
  const SendRequestConfirmationDialog({Key? key, required this.text, required this.brand}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(MediaQuery.of(context).size.height*0.02),
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05, bottom: MediaQuery.of(context).size.height*0.04, left: MediaQuery.of(context).size.height*0.01, right: MediaQuery.of(context).size.height*0.01),
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
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.07, bottom: 24.0, right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(text, style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5),textAlign: TextAlign.center,),
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
                          backgroundColor: Colors.green,
                          fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.send,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                        ),
                        icon: Icon(Icons.send, size: MediaQuery.of(context).size.width*0.06, color: Colors.white,),
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
                top: -MediaQuery.of(context).size.height*0.12,
                child: Column(
                  children: <Widget>[
                    CircularImage(
                      size: MediaQuery.of(context).size.width*0.25,
                      image: brand.logoUrl,
                      color: Theme.of(context).accentColor,
                      borderWidth: 2,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    Expanded(
                      child: Text(
                        brand.name!,
                        style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.bold),
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