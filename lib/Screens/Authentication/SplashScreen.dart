import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mamba_castelldefels/Data/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DatabaseAccess.dart';
import 'package:mamba_castelldefels/Data/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Screens/Admin/Admin.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Login.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTime.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/HomePage.dart';
import 'package:provider/provider.dart';

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
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();

  @override
  initState() {
    super.initState();
    checkAndGetUserDetails();
  }

  void checkAndGetUserDetails() async {
    //_userDataService.signOut();
    // 1. We get the Firebase User
    User? firebaseUser = await _userDataService.getCurrentUser();
    // 2. Check if we have a user logged in.
    if (firebaseUser != null) {
      // 2.1 User is logged in.
      // 3. Check if we are in production enviroment
      if (isProduction) {
        // 3.1 We are in PROD. We checked if email has been verified.
        if (firebaseUser.emailVerified) {
          // 3.1.1 Email has been verified
          // 4. Define Prod Config for FirebaseChatCore
          FirebaseChatCore.instance.setConfig(FirebaseChatCoreConfig(
            'Rooms',
            'Users',
          ));
          // 5. Load Users Data
          await getUserData(firebaseUser.uid);
          // 6. Get Token for FirebaseMessaging
          FirebaseMessaging.instance.getToken().then((token) {
            print("Token: $token");
            if (token != currentUser.notificationToken) {
              print("New token updated");
              _userDataService.updateUserNotificationToken(currentUser.id!, token!);
            }
          });
          // 7. Travel to Corresponding Screen
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
          // 3.1.2 Email has NOT been verified. Go back to Login.
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
        // 3.2 We are in DEVELOPMENT
        // 4. Define Development Config for FirebaseCore
        FirebaseChatCore.instance.setConfig(FirebaseChatCoreConfig(
          '7777 Rooms',
          '7777 Users',
        ));
        // 5. Load Users Data
        await getUserData(firebaseUser.uid);
        // 6. Get Token for FirebaseMessaging
        FirebaseMessaging.instance.getToken().then((token) {
          print("Token: $token");
          if (token != currentUser.notificationToken) {
            print("New token updated");
            _userDataService.updateUserNotificationToken(currentUser.id!, token!);
          }
        });
        // 7. Travel to Corresponding Screen
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
      // 2.2 User is logged NOT in. We travel to the Login
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

  Future<void> getUserData(String userId) async {
    // Get Current User Main Data from Document
    currentUser = await _userDataService.getUserDetails(userId);
    // Set App Locale To User Preferred Language
    Provider.of<LanguageProvider>(context, listen: false).setLocale(Idiomas.getLocaleFromString(currentUser.idioma!));
    // Get Current User Unread Notifications and Chats
    unreadNotifications = await _userDataService.getUnreadNotifications(currentUser.id!);
    unreadChats = await _userDataService.getUnreadConversations(currentUser.id!);
    // Get Current User Brand, if any.
    List<Brand> brands = await _userDataService.getUserBrands(userId);
    // Set the Brand List
    currentUser.setBrandList = brands;
    if (currentUser.getBrandList.isNotEmpty) {
      // Put first brand to Current Brand
      Brand brand = currentUser.getBrandList[0];
      currentBrand = await _brandDataService.getBrandDetails(brand.id!);
    } else {
      // Empty Current Brand
      currentBrand = Brand();
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
