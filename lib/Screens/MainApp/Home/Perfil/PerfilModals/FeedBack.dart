import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Database.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Models/Error.dart';
import 'package:mamba_castelldefels/Providers/ClientProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeedBack extends StatefulWidget {
  const FeedBack({Key? key}) : super(key: key);

  @override
  _FeedBackState createState() => _FeedBackState();
}

class _FeedBackState extends State<FeedBack> {
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
                Text(AppLocalizations.of(context)!.feedback, style: purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                IconButton(
                    icon: Icon(Icons.send, color: purpleColor),
                    onPressed: () async {}
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
                      Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 100.0, horizontal: 100.0),
                          child: Text("FALTA IMPLEMENTAR PREGUNTES FEEDBACK"),
                        ),
                      ),
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




