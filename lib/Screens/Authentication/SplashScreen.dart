import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Globals/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Screens/Admin/Admin.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Login.dart';
import 'package:provider/provider.dart';

import '../../Data/DataService/LibraryDataService.dart';
import '../../Globals/Widgets/GroupOfComponents/LoadingViews/SplashScreenView.dart';
import '../MainApp/Mamba/Mamba.dart';
import '../MainApp/OnboardingScreen.dart';

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
  var _libraryDataService = new LibraryDataService();

  @override
  initState() {
    super.initState();
    checkAndGetUserDetails();
    initColorsList();
    //initDynamicLinks();
  }

  Future<void> initColorsList() async {
    currentColors =  await _libraryDataService.getColors();
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
          FirebaseChatCore.instance.setConfig(
            FirebaseChatCoreConfig(
                null,
              'Rooms',
              'Users',
            )
          );
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
                    builder: (context) => Mamba(),
                    settings: RouteSettings(name: 'Mamba'),
                  )
              );
            } else {
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute<Null>(
                    builder: (context) =>
                    OnboardingScreen(),
                    settings: RouteSettings(name: 'OnboardingScreen'),
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
        FirebaseChatCore.instance.setConfig(
            FirebaseChatCoreConfig(
              null,
              '7777 Rooms',
              '7777 Users',
            )
        );
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
                  builder: (context) => Mamba(),
                  settings: RouteSettings(name: 'Mamba'),
                )
            );
          } else {
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute<Null>(
                  builder: (context) => OnboardingScreen(),
                  settings: RouteSettings(name: 'OnboardingScreen'),
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
    // Set App Theme To User Preferred Theme Settings
    if (currentUser.isDark != null) {
      print("This user has a Dark Mode: "+currentUser.isDark!.toString());
      Provider.of<ThemeProvider>(context, listen: false).toggleTheme(currentUser.isDark!);
    }
    print("This user has the System Theme On");
    // Get Current User Unread Notifications and Chats
    unreadNotifications = await _userDataService.getUnreadNotifications(currentUser.id!);
    unreadChats = await _userDataService.getUnreadConversations(currentUser.id!);
    // Get Current User Brand, if any.
    // WAIT TO AVOID PROBLEMS DUE TO CLOUD FUNCTIONS NOT BEING INSTANTANEOUS.
    await Future.delayed(const Duration(seconds: 3));
    List<Brand> brands = await _brandDataService.getAllBrandsFromUser(userId);
    // Set the Brand List
    currentUser.setBrandList = brands;
    if (currentUser.brandsList.isNotEmpty) {
      // Put first brand to Current Brand
      Brand brand = currentUser.brandsList[0];
      currentBrand = await _brandDataService.getBrandDetails(brand.id!);
      hasBrand = true;
      print("This user has a Brand");
    } else {
      // Empty Current Brand
      currentBrand = Brand();
      hasBrand = false;
      print("User with NO Brand");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SplashScreenView(),
    );

  }
}
