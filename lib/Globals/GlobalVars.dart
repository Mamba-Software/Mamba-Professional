// This file contains all the Global Variabels used throgh the App.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lDegradate.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/ChatCore.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/Notifications.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/Profile.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../Data/LibraryModels/lColor.dart';

// IS PRODUCTION ?
bool isProduction = true;

// App Version
var appVersion = "MAMBA v0.0.17";

List<lColor> currentColors = [];
List<lDegradate> currentDegradates = []; //0x00000000, 0xFFE53935, 0xFF43A047, 0xFF1E88E5, 0xFF8E24AA, 0xFFFB8C00, 0xFFFDD835

// App
var androidGooglePlayUrl =
    "https://play.google.com/store/apps/details?id=com.mamba.mambaprofessionalapp";
var iosAppStoreUrl =
    "https://apps.apple.com/es/app/mamba-professional/id1642701679";

// Email
var contactEmail = "contacto@mambafitness.es";

// Website
var website = "https://mambafitness.es/";
var termsAndConditions = "https://mambafitness.es/terminos-y-condiciones/";
var privacy = "https://mambafitness.es/privacidad/";
var functionalities = "https://mambafitness.es/profesionales/";


// User & Brand Global Variables
var currentUser = Usuario();
var currentBrand = Brand();
bool hasBrand = false;
bool brandIsActive = false;

// Current User Location and TimeZone
Position? currentPosition;
String? currentAddress;
String? timeZoneName;

// Page Controller Mamba Professional
int pageIndex = 10;

bool isExecuted = false; // Initialize the flag as a member variable.

// Analytics Mix Panel
Mixpanel? mixpanel;

// Key Scaffold Mamba Pro
final GlobalKey<ScaffoldState> mambaProScaffoldKey = GlobalKey<ScaffoldState>();

// Dynamic Links Path
var dynamicLinkBrandId;

//JMF 18042023 REVENUECAT
void setBrandActive() {
  //Se trata de revenueCat
  if (currentBrand.subscription != null) {
    if (currentBrand.subscription?['brandIsActive'] == true) {
      brandIsActive = true;
    } else {
      brandIsActive = false;
    }
  }
  //Se trata de una antigua suscripción
  else if (currentBrand.endDatePay != null) {
    if (DateTime.now().compareTo(currentBrand.endDatePay!.toDate()) < 0) {
      brandIsActive = true;
    } else {
      brandIsActive = false;
    }
  } else {
    brandIsActive = false;
  }
}

Future<void> navigateToPayWall(var context,
    [bool fromActiveSubs = false]) async {
  final topSnackBar = TopSnackBarDef();
  if (currentUser.id == currentBrand.adminID) {
    if (fromActiveSubs) {
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PayWall(
            brandId: currentBrand.id!,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), // Starts from below
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ).whenComplete(() {
        Navigator.pop(context);
      });
    } else {
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PayWall(
            brandId: currentBrand.id!,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), // Empieza desde abajo
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      );
    }
  } else {
    topSnackBar.showSnackBarTop(
        context, AppLocalizations.of(context)!.notSubNotAdmin, 5);
  }
}

// Navigate to Notifications Screen
void navigateToProfileScreen(BuildContext context) {
  Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => const Profile(),
        settings: const RouteSettings(name: 'Profile'),
      ));
}

// Navigate to Notifications Screen
Future<void> navigateToNotificationsScreen(BuildContext context) async {
  Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => const Notifications(),
      ));
}

// Navigate to Notifications Screen
Future<void> navigateToChatScreen(BuildContext context) async {
  Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => const ChatCore(),
      ));
}
