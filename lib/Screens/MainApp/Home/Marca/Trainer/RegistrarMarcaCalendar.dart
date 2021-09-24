import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegistrarMarcaCalendar extends StatefulWidget {
  const RegistrarMarcaCalendar({Key? key}) : super(key: key);

  @override
  _RegistrarMarcaCalendarState createState() => _RegistrarMarcaCalendarState();
}

class _RegistrarMarcaCalendarState extends State<RegistrarMarcaCalendar> {
  //DataBase Access
  var _accessDatabase = new DatabaseAccess();
  // Controllers of Calendar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.disponibilidad, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22),),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.today),
              onPressed: () => print("TODAY"),
              tooltip: 'Jump to today',
            ),
          ],
          centerTitle: true,
          elevation: 10,
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
        ),
        backgroundColor: Styles.white,
        body: Container(),
      );
  }

  void showInSnackBar(String value) {
    final snackbar = new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "Raleway"),
      ),
      backgroundColor: Styles.accent,
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState!.showSnackBar(snackbar);
  }

}

