// This file contains all the Global Variabels used throgh the App.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lDegradate.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../Data/LibraryModels/lColor.dart';

// IS PRODUCTION ?
bool isProduction = true;

// App Version
var appVersion = "MAMBA v0.0.13";

List<lColor> currentColors = [];
List<lDegradate> currentDegradates = [];//0x00000000, 0xFFE53935, 0xFF43A047, 0xFF1E88E5, 0xFF8E24AA, 0xFFFB8C00, 0xFFFDD835

// App
var androidGooglePlayUrl = "https://play.google.com/store/apps/details?id=com.mamba.mambaprofessionalapp";
var iosAppStoreUrl = "https://apps.apple.com/es/app/mamba-professional/id1642701679";

// Website
var websiteES = "https://www.mambaapp.app/";
var websiteCA = "https://www.mambaapp.app/ca/inici/";
var termsAndConditionsES = "https://www.mambaapp.app/terminos-y-condiciones/";
var termsAndConditionsCA = "https://www.mambaapp.app/ca/termes-i-condicions/";

var functionalitiesES = "https://www.mambaapp.app/#funcionalidades";
var functionalitiesCA = "https://www.mambaapp.app/#funcionalidades";

// API Keys
var placesAPIAndroid = "AIzaSyBjUcoI0sYFY9H8mb2n0IoBv26GxnPTRgs";
var placesAPIIOS = "AIzaSyAYFglgzIMLYXB9XQPaZ977MKUMseCJCvY";
var googleMapsAPIAndroid = "AIzaSyBv6FwSFMHrhQE6w5i7bIW_DcOOW08FVR8";
var googleMapsAPIIOS = "AIzaSyCHiJWFQzsfD-lO34bbctas1No0Kgxn9i4";

// User & Brand Global Variables
var currentUser = Usuario();
var currentBrand = Brand();
bool hasBrand = false;
bool brandIsActive = false;

// Unread Notifications And Chats
var unreadNotifications = 0;
var unreadChats = 0;

// Current User Location and TimeZone
Position? currentPosition;
String? currentAddress;
String? timeZoneName;

// Page Controller Mamba Professional
int pageIndex = 0;

// Analytics Mix Panel
Mixpanel? mixpanel;

// Key Scaffold Mamba Pro
final GlobalKey<ScaffoldState> mambaProScaffoldKey = GlobalKey<ScaffoldState>();

// Dynamic Links Path
var dynamicLinkBrandId;

//Revenue Cat
const googleApiKey = 'goog_xHoFXqoNpoesuLjeweHEqSuEvXy';
const appleApiKey = 'appl_WdXLePsgLfQWTsDgYXYWYkdbDCj';
const entitlementID = 'AllFeatures';

//JMF 18042023 REVENUECAT
void setBrandActive()
{
  //Se trata de revenueCat
  if (currentBrand.subscription != null) {
    if(currentBrand.subscription?['brandIsActive'] == true) {
      brandIsActive = true;
    }
    else {
      brandIsActive = false;
    }
  }
  //Se trata de una antigua suscripción
  else if(currentBrand.endDatePay != null)
  {
    if(DateTime.now().compareTo(currentBrand.endDatePay!.toDate()) < 0)
    {

      brandIsActive = true;
    }
    else
    {
      brandIsActive = false;
    }
  }
  else
  {
    brandIsActive = false;
  }
}

Future<void> navigateToPayWall(var context)
async {
  if(!brandIsActive) {
    await Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => const SplashScreen(),
        settings: const RouteSettings(name: 'SplashScreen'),
      ),
          (_) => false,
    );
  }
}




