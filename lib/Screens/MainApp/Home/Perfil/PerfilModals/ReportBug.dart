import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Database.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Models/Error.dart';
import 'package:mamba_castelldefels/Providers/ClientProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReportBug extends StatefulWidget {
  const ReportBug({Key? key}) : super(key: key);

  @override
  _ReportBugState createState() => _ReportBugState();
}

class _ReportBugState extends State<ReportBug> {
  // DATABASE INSTANCE
  final DatabaseService _databaseService = DatabaseService();
  // Form Values
  final _formKey = GlobalKey<FormState>();
  String tituloTemp = "";
  String descriptionTemp = "";
  String stepsReproduceTemp = "";
  final tituloController = TextEditingController();
  final descriptionController = TextEditingController();
  final stepsReproduceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void clearControllers() {
      tituloController.clear();
      descriptionController.clear();
      stepsReproduceController.clear();
    }

    return Container(
      padding: MediaQuery.of(context).viewInsets,
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
                  icon: Icon(Icons.arrow_back, color: purpleColor),
                  onPressed: () => {Navigator.of(context).pop()},
                ),
                Text(AppLocalizations.of(context)!.reporting, style: purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                IconButton(
                    icon: Icon(Icons.send, color: purpleColor),
                    onPressed: () async {
                    if(_formKey.currentState!.validate()){
                      _databaseService.updateErrorData(
                        new Error(
                          title: tituloTemp,
                          descripcion: descriptionTemp
                        ));
                      clearControllers();
                      }
                    }
                ),
                IconButton(
                    icon: Icon(Icons.delete, color: purpleColor),
                    onPressed: () async {
                      clearControllers();
                    }
                ),
              ],
            ),
            new Container(
              child: Padding(
                padding: EdgeInsets.only(bottom: 25.0),
                child: Form(
                  key: _formKey,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    AppLocalizations.of(context)!.title,
                                    style: purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextFormField(
                                  controller: tituloController,
                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.titleError : null,
                                  onChanged: (val) {
                                    setState(() => tituloTemp = val);
                                  },
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.titleHint,
                                  ),
                                  enabled: true,
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0, bottom: 8.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    AppLocalizations.of(context)!.description,
                                    style: purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextFormField(
                                  controller: descriptionController,
                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.descriptionError : null,
                                  onChanged: (val) {
                                    setState(() => descriptionTemp = val);
                                  },
                                  maxLines: 4,
                                  decoration: textFromInputDecoration.copyWith(hintText:AppLocalizations.of(context)!.descriptionHint)
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    AppLocalizations.of(context)!.reproducteSteps,
                                    style: purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextFormField(
                                  controller: stepsReproduceController,
                                  onChanged: (val) {
                                    setState(() => stepsReproduceTemp = val);
                                  },
                                  decoration: InputDecoration(
                                    hintMaxLines: 2,
                                    hintText: AppLocalizations.of(context)!.reproducteStepsHint,
                                  ),
                                  enabled: true,
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}




