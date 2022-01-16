import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Screens/Admin/Admin.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Login.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTime.dart';
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

  // Data Base Access
  var _accessDatabase = new DatabaseAccess();

  @override
  initState() {
    super.initState();
    checkAndGetCurrentUserDetails();
  }

  void checkAndGetCurrentUserDetails() async {
    //_accessDatabase.signOut();
    User? firebaseUser = await _accessDatabase.getCurrentUser();
    if (firebaseUser != null) {
      if (isProduction) {
        FirebaseChatCore.instance.setConfig(FirebaseChatCoreConfig(
          'Rooms',
          'Users',
        ));
        if (firebaseUser.emailVerified) {
          currentUser = await _accessDatabase.getCurrentUserDetails();
          unreadNotifications =
          await _accessDatabase.numberUnreadNotifications(currentUser.id!);
          unreadChats =
          await _accessDatabase.numberUnreadConversations(currentUser.id!);
          if (currentUser.brandID != "null" && currentUser.brandID != null) {
            currentBrand =
            await _accessDatabase.getBrandDetails(currentUser.brandID!);
          } else {
            currentBrand = Brand();
          }
          Provider.of<LanguageProvider>(context, listen: false).setLocale(
              Idiomas.getLocaleFromString(currentUser.idioma!));
          // Get Token of User and Update in Firebase
          FirebaseMessaging.instance.getToken().then((token) {
            print("Token:");
            print(token);
            if (token != currentUser.notificationToken) {
              print("New token updated");
              _accessDatabase.addUserNotificationToken(currentUser.id!, token!);
            }
          });
          if (currentUser.isAdmin!) {
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute<Null>(
                  builder: (context) => Admin(),
                  settings: RouteSettings(name: 'Admin'),
                )
            );
          } else {
            if (!(currentUser.isFirst!)) {
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
                    builder: (context) =>
                        FirstTime(
                          locale: Localizations.localeOf(context),
                        ),
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
      } else {
        FirebaseChatCore.instance.setConfig(FirebaseChatCoreConfig(
          '7777 Rooms',
          '7777 Users',
        ));
        currentUser = await _accessDatabase.getCurrentUserDetails();
        unreadNotifications = await _accessDatabase.numberUnreadNotifications(currentUser.id!);
        unreadChats = await _accessDatabase.numberUnreadConversations(currentUser.id!);
        if (currentUser.brandID != "null" && currentUser.brandID != null) {
          currentBrand = await _accessDatabase.getBrandDetails(currentUser.brandID!);
        } else {
          currentBrand = Brand();
        }
        Provider.of<LanguageProvider>(context, listen: false).setLocale(Idiomas.getLocaleFromString(currentUser.idioma!));
        // Get Token of User and Update in Firebase
        FirebaseMessaging.instance.getToken().then((token) {
          print("Token:");
          print(token);
          if (token != currentUser.notificationToken) {
            print("New token updated");
            _accessDatabase.addUserNotificationToken(currentUser.id!, token!);
          }
        });
        if (currentUser.isAdmin!) {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute<Null>(
                builder: (context) => Admin(),
                settings: RouteSettings(name: 'Admin'),
              )
          );
        } else {
          if (!(currentUser.isFirst!)) {
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
                  builder: (context) =>
                      FirstTime(
                        locale: Localizations.localeOf(context),
                      ),
                  settings: RouteSettings(name: 'FirstTimeWrapper'),
                )
            );
          }
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
    return Scaffold(
      appBar: null,
      body: LoadingViewPurple(),
    );

  }
}
