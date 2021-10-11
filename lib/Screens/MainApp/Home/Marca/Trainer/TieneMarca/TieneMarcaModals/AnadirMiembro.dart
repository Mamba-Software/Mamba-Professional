import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:flutter/services.dart';

class AnadirMiembro extends StatefulWidget {
  const AnadirMiembro({Key? key}) : super(key: key);

  @override
  _AnadirMiembroState createState() => _AnadirMiembroState();
}

class _AnadirMiembroState extends State<AnadirMiembro> {

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height*0.89,
      ),
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Styles.accent),
                    onPressed: () => {Navigator.of(context).pop()},
                  ),
                  Text(AppLocalizations.of(context)!.addMembers, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                  SizedBox(width: 30,),
                ],
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 25.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    AppLocalizations.of(context)!.inviteCode,
                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 25.0),
                        child: Row(
                          children: [
                            Flexible(
                              child: Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)
                                ),
                                elevation: 5,
                                child: new TextFormField(
                                  initialValue: currentBrand.id,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.codigo,
                                    hintStyle: Styles.whiteTextStyle.copyWith(fontSize: 16, color:Colors.green),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.green, width: 1.0),
                                      borderRadius: BorderRadius.circular(13.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.green, width: 1.0),
                                      borderRadius: BorderRadius.circular(13.0),
                                    ),
                                  ),
                                  style: Styles.whiteTextStyle.copyWith(fontSize: 13, color:Colors.green),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: FloatingActionButton(
                                    child: Icon(Icons.copy),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Styles.white,
                                    onPressed: () async {
                                      Clipboard.setData(new ClipboardData(text: currentBrand.id)).then((_){
                                        showTopSnackBar(
                                          context,
                                          CustomSnackBar.info(
                                            icon: Container(),
                                            /*
                                            Padding(
                                              padding: const EdgeInsets.only(left: 20),
                                              child: Icon(Icons.copy, size: 50, color: Colors.white.withOpacity(0.2),),
                                            ),
                                             */
                                            iconRotationAngle: 0,
                                            backgroundColor: Styles.accent,
                                            message: AppLocalizations.of(context)!.copyCorrectCode,
                                            textStyle: Styles.whiteTextStyle,
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}




