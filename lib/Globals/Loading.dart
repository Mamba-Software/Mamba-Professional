// Flutter Libs
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
//Internal App Resources
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Login.dart';

class Loading extends StatefulWidget {
  Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  var _accessDatabase = new DatabaseAccess();

  @override
  initState() {
    super.initState();
    checkAndGetCurrentUserDetails();
  }

  void checkAndGetCurrentUserDetails() async {
    User? currentUser = await _accessDatabase.getCurrentUser();
    if(currentUser != null) {
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute<Null>(
            builder: (context) => Container(child: Text(
              "HOMEPAGE "
            ),),
            settings: RouteSettings(name: 'HomePage'),
          )
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => Login(),
          settings: RouteSettings(name: 'Login'),
        ),
            (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.mainColor,
      body: Stack(
        children: <Widget>[
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.15,
              child: CircularProgressIndicator(
                color: Styles.white,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.15,
              child: Image(
                  image: AssetImage(Constants.logoSimple)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
