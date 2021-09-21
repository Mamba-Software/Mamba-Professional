import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';


class AdminTool extends StatefulWidget {
  final String title;
  const AdminTool({Key? key,required this.title}) : super(key: key);

  @override
  _AdminToolState createState() => _AdminToolState();
}

class _AdminToolState extends State<AdminTool> {

  //DataBase Access
  var _accessDatabase = new DatabaseAccess();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        elevation: 10,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(),
    );
  }
}
