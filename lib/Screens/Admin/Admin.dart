import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';


class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {

  //DataBase Access
  var _accessDatabase = new DatabaseAccess();
  // Models
  Usuario? user;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    user = await _accessDatabase.getCurrentUserDetails();
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Constants.logoExtended,
                  fit: BoxFit.contain,
                  height: 32,
                ),
                SizedBox(width: 15),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text("ADMIN", style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ],
            ),
            centerTitle: true,
            elevation: 10,
            automaticallyImplyLeading: false,
          ),
          backgroundColor: Colors.white,
          body: Container()
      );
  }
}
