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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.disponibilidad, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22),),
        centerTitle: true,
        elevation: 10,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      backgroundColor: Styles.white,
      body: SingleChildScrollView(
          child: Container()
      ),
    );
  }

}
