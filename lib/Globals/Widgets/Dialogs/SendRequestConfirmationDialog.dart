import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import '../../Styles.dart';
import '../Images/CircularImage.dart';

class SendRequestConfirmationDialog extends StatelessWidget {
  final String text;
  final Brand brand;
  const SendRequestConfirmationDialog({Key? key, required this.text, required this.brand}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.only(top: 80, bottom: 10, left: 10, right: 10),
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
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: Icon(Icons.send, size: MediaQuery.of(context).size.width*0.07, color: Colors.white,),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width*0.01),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: Colors.black,
                          fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: Icon(Icons.cancel_outlined, size: MediaQuery.of(context).size.width*0.07, color: Colors.white,),
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
                      image: brand.logoUrl,
                      color: Theme.of(context).accentColor,
                      borderWidth: 2,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    Expanded(
                      child: Text(
                        brand.name!,
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