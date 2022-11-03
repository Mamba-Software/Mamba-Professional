import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Globals/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Screens/Admin/Admin.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Login.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Mamba.dart';
import 'package:provider/provider.dart';
import '../../Data/DataService/Library/LibraryDataService.dart';
import '../../Globals/Widgets/GroupOfComponents/LoadingViews/SplashScreenView.dart';
import 'OnboardingScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

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
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _libraryDataService = LibraryDataService();

  @override
  initState() {
    super.initState();
    checkAndGetUserDetails();
    initColorsList();
  }

  Future<void> initColorsList() async {
    currentColors =  await _libraryDataService.getColors();
    currentDegradates = await _libraryDataService.getDegradates();
  }

  void sendMixPanelDataUsers() {
    // Send User Mix Panel Data
    mixpanel!.getPeople().set("email", currentUser.email);
    String genderString = "";
    if (currentUser.gender == 0) genderString = "Male";
    if (currentUser.gender == 1) genderString = "Female";
    if (currentUser.gender == 2) genderString = "Other";
    mixpanel!.getPeople().set("gender", genderString);
    mixpanel!.getPeople().set("language", currentUser.idioma!);
    mixpanel!.getPeople().set("isPrivate", true);
    mixpanel!.getPeople().set("isTrainer", true);
    mixpanel!.getPeople().set("isProduction", isProduction);
    var dateOfBirthSplit = currentUser.dateOfBirth!.split("-");
    DateTime dateOfBirth = DateTime(int.parse(dateOfBirthSplit[2]), int.parse(dateOfBirthSplit[1]), int.parse(dateOfBirthSplit[0]), 0, 0);
    mixpanel!.getPeople().set("dateOfBirth", dateOfBirth.toString());
    var firstLoginDateSplit = currentUser.dateJoined!.split("-");
    DateTime firstLoginDate = DateTime(int.parse(firstLoginDateSplit[2]), int.parse(firstLoginDateSplit[1]), int.parse(firstLoginDateSplit[0]), 0, 0);
    // TODO: AFEGIR UN IF PER A QUE NOMES ACTUALITZACIO AIXO PER ALS USUARIS ABANS D'AQUESTA ACTUALITZACIO
    mixpanel!.getPeople().set("firstLoginDate", firstLoginDate.toString());
    mixpanel!.getPeople().set("lastLoginDate", DateTime.now().toString());
  }

  void checkAndGetUserDetails() async {
    //_userDataService.signOut();
    // 1. We get the Firebase User
    User? firebaseUser = await _userDataService.getCurrentUser();
    // 2. Check if we have a user logged in.
    if (firebaseUser != null) {
      mixpanel?.identify(firebaseUser.uid);
      // 2.1 User is logged in.
      // 3. Check if we are in production enviroment
      if (isProduction) {
        // 3.1 We are in PROD. We checked if email has been verified.
        if (firebaseUser.emailVerified) {
          // 3.1.1 Email has been verified
          // 4. Define Prod Config for FirebaseChatCore
          FirebaseChatCore.instance.setConfig(
            const FirebaseChatCoreConfig(
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
                CupertinoPageRoute<void>(
                  builder: (context) => const Admin(),
                  settings: const RouteSettings(name: 'Admin'),
                )
            );
          } else {
            if (!(currentUser.isFirst!)) {
              sendMixPanelDataUsers();
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute<void>(
                    builder: (context) => const Mamba(),
                    settings: const RouteSettings(name: 'Mamba'),
                  )
              );
            } else {
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute<void>(
                    builder: (context) =>
                    const OnboardingScreen(),
                    settings: const RouteSettings(name: 'OnboardingScreen'),
                  )
              );
            }
          }
        } else {
          // 3.1.2 Email has NOT been verified. Go back to Login.
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<void>(
              builder: (context) => const Login(),
              settings: const RouteSettings(name: 'Login'),
            ),
                (_) => false,
          );
        }
      } else {
        // 3.2 We are in DEVELOPMENT
        // 4. Define Development Config for FirebaseCore
        FirebaseChatCore.instance.setConfig(
            const FirebaseChatCoreConfig(
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
              CupertinoPageRoute<void>(
                builder: (context) => const Admin(),
                settings: const RouteSettings(name: 'Admin'),
              )
          );
        } else {
          if (!(currentUser.isFirst!)) {
            sendMixPanelDataUsers();
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute<void>(
                  builder: (context) => const Mamba(),
                  settings: const RouteSettings(name: 'Mamba'),
                )
            );
          } else {
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute<void>(
                  builder: (context) => const OnboardingScreen(),
                  settings: const RouteSettings(name: 'OnboardingScreen'),
                )
            );
          }
        }
      }
    } else {
      // 2.2 User is logged NOT in. We travel to the Login
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => const Login(),
          settings: const RouteSettings(name: 'Login'),
        ),
            (_) => false,
      );
    }
  }

  Future<void> getUserData(String userId) async {
    // Get Current User Main Data from Document
    try {
      currentUser = await _userDataService.getUserDetails(userId);
    } catch (e) {
      _userDataService.signOut();
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => const Login(),
          settings: const RouteSettings(name: 'Login'),
        ), (_) => false,
      );
    }
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
      mixpanel!.getPeople().set("Brands", [currentBrand.id!]);
    } else {
      // Empty Current Brand
      currentBrand = Brand();
      hasBrand = false;
      print("User with NO Brand");
      mixpanel!.getPeople().set("Brands", []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: SplashScreenView(),
    );

  }
}
