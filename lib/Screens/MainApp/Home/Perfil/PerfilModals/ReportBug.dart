import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Report a Bug Widget.
class ReportBug extends StatefulWidget {
  const ReportBug({Key? key}) : super(key: key);

  @override
  _ReportBugState createState() => _ReportBugState();
}

class _ReportBugState extends State<ReportBug> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  bool errorIsSent = false;

  // Form Values
  final _formKey = GlobalKey<FormState>();
  String tituloTemp = "";
  String descriptionTemp = "";
  String stepsReproduceTemp = "";
  final tituloController = TextEditingController();
  final descriptionController = TextEditingController();
  final stepsReproduceController = TextEditingController();

  // Clears all values.
  void clearControllers() {
    tituloController.clear();
    descriptionController.clear();
    stepsReproduceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: LoadingView()
      )
        :
      Container(
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
                    Text(AppLocalizations.of(context)!.reporting, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                    IconButton(
                        icon: Icon(Icons.send, color: Styles.accent),
                        onPressed: () async {
                          if(_formKey.currentState!.validate()){
                            setState(() {
                              isLoading = true;
                            });
                            sendError();
                          }
                        }
                    ),
                    IconButton(
                        icon: Icon(Icons.delete, color: Styles.accent),
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
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                          ),
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
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
                                      maxLines: 6,
                                      decoration: Styles.textFromInputDecoration.copyWith(hintText:AppLocalizations.of(context)!.descriptionHint)
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
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
        ),
    );
  }

  // Sends error to the Database.
  Future<void> sendError() async {
    var result = await _accessDatabase.addError(tituloTemp, descriptionTemp, stepsReproduceTemp);
    if (result) {
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        context,
        CustomSnackBar.success(
          icon: Container(),
          /*
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Icon(Icons.send, size: 40, color: Colors.white.withOpacity(0.2),),
          ),
           */
          iconRotationAngle: 0,
          backgroundColor: Colors.green,
          message: AppLocalizations.of(context)!.errorSent,
          textStyle: Styles.whiteTextStyle,
        ),
      );
      clearControllers();
    }
  }

}




