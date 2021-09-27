import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';

class AjustesMarca extends StatefulWidget {
  const AjustesMarca({Key? key}) : super(key: key);

  @override
  _AjustesMarcaState createState() => _AjustesMarcaState();
}

class _AjustesMarcaState extends State<AjustesMarca> {

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height*0.86,
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
                  Text(AppLocalizations.of(context)!.settings, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                  SizedBox(width: 30,),
                ],
              ),
              new Container(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 25.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 80.0),
                          child: Text(
                            AppLocalizations.of(context)!.noFeedback,
                            textAlign: TextAlign.center,
                            style: Styles.purpleTextStyle.copyWith(fontSize: 22),
                          ),
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




