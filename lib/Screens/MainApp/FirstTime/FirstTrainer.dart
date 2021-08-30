import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/Database.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Providers/TrainerProvider.dart';
import 'package:provider/provider.dart';

class FirstTrainer extends StatefulWidget {
  const FirstTrainer({Key? key}) : super(key: key);

  @override
  _FirstTrainerState createState() => _FirstTrainerState();
}

class _FirstTrainerState extends State<FirstTrainer> {
  final DatabaseService _databaseService = DatabaseService();
  // Loading Screen Boolean
  bool loading = false;
  // Codigo Widget Boolean
  bool codigo = false;
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  String key = "";

  @override
  Widget build(BuildContext context) {
    final trainer = Provider.of<TrainerProvider>(context).trainer;
    return loading ? Loading() : Scaffold(
      backgroundColor: yellowColor,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 16.0),
                    width: 200,
                    height: 100,
                    child: Image.asset(logoExtended)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(AppLocalizations.of(context)!.wellcome(trainer.name!), style: purpleTextStyle.copyWith(fontSize: 23, fontWeight:FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 4.0),
                  child: Text(AppLocalizations.of(context)!.alreadyCreatedTrainer,
                      style: purpleTextStyle,
                      textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 24.0),
                      child: FloatingActionButton(
                        child: Text(AppLocalizations.of(context)!.yes, style: whiteTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        onPressed: () async {
                          setState(() {
                            loading = true;
                          });
                          String defIdioma = Localizations.localeOf(context).languageCode;
                          await _databaseService.updateUsersData(trainer.uid, true, false, defIdioma);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 24.0),
                      child: FloatingActionButton(
                        child: Text(AppLocalizations.of(context)!.no, style: whiteTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            codigo = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              codigo ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                      child: Text(AppLocalizations.of(context)!.alreadyCreatedTrainerFirm,
                        style: purpleTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 45.0, right: 45.0, top: 4.0, bottom: 0),
                      child: TextFormField(
                          validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.codigo : null,
                          onChanged: (val) {
                            setState(() => key = val);
                          },
                          decoration: textFromInputDecoration.copyWith(labelText: AppLocalizations.of(context)!.codigo)
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton.extended(
                        icon: Icon(Icons.qr_code),
                        label: Text(AppLocalizations.of(context)!.letsGo, style: purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                        backgroundColor: whiteColor,
                        foregroundColor: purpleColor,
                        onPressed: () async {
                          // TODO: validació del codi per entrar directament a formar part del grup de entrenadors.
                          //if(_formKey.currentState!.validate()){}
                          setState(() {
                            loading = true;
                          });
                          String defIdioma = Localizations.localeOf(context).languageCode;
                          await _databaseService.updateUsersData(trainer.uid, true, false, defIdioma);
                        },
                      ),
                    ),
                  ],
                ) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
