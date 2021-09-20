import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Screens/Admin/Admin.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Login.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTimeWrapper.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/HomePage.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// Splash Screen, the first one that is being shown.
// This screen has 3 possible outcomes.
// A) User NOT Logged In => LogInPage()
// B) User IS Logged In ...
//      1) isFirstTime? YES => FirstTimeWrapper()
//      2) isFirstTime? NO => HomePage()
//
// While getting data from Database it is showing a Loading Widget.
class _SplashScreenState extends State<SplashScreen> {

  var _accessDatabase = new DatabaseAccess();

  @override
  initState() {
    super.initState();
    checkAndGetCurrentUserDetails();
  }

  void checkAndGetCurrentUserDetails() async {
    User? firebaseUser = await _accessDatabase.getCurrentUser();
    if(firebaseUser != null && firebaseUser.emailVerified) {
      var user = await _accessDatabase.getCurrentUserDetails();
      Provider.of<LanguageProvider>(context, listen: false).setLocale(Idiomas.getLocaleFromString(user.idioma!));
      if(user.isAdmin!) {
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute<Null>(
              builder: (context) => Admin(),
              settings: RouteSettings(name: 'Admin'),
            )
        );
      } else {
        if(!(user.isFirst!)) {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute<Null>(
                builder: (context) => HomePage(),
                settings: RouteSettings(name: 'HomePage'),
              )
          );
        } else {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute<Null>(
                builder: (context) => FirstTimeWrapper(),
                settings: RouteSettings(name: 'FirstTimeWrapper'),
              )
          );
        }
      }

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value:SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, //i like transaparent :-)
          systemNavigationBarColor: Colors.black, // navigation bar color
          statusBarIconBrightness: Brightness.light, // status bar icons' color
          systemNavigationBarIconBrightness:Brightness.light, //navigation bar icons' color
        ),
        child: Scaffold(
                backgroundColor: Styles.mainColor,
                body: Stack(
                  children: <Widget>[
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.14,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: CircularProgressIndicator(
                          color: Styles.white,
                         ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.07,
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: Image(
                            image: AssetImage(Constants.logoSimple)
                            ),
                          ),
                      ),
                  ],
                )
        )
    );
  }
}
