// This file contains all the Global Variabels used throgh the App.
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';

// IS PRODUCTION?
bool isProduction = true;

// App Version
var appVersion = "MAMBA v0.0.11";

// App
var androidGooglePlayUrl = "https://play.google.com/store/apps/details?id=com.mamba.mambastyleapp";
var iosAppStoreUrl = "https://apps.apple.com/us/app/mamba-style/id1601684650";

// Website
var websiteES = "https://mambastyle.net/";
var websiteCA = "https://mambastyle.net/ca/inici/";
var termsAndConditionsES = "https://mambastyle.net/terminos-y-condiciones/";
var termsAndConditionsCA = "https://mambastyle.net/ca/termes-i-condicions/";

// API Keys
var placesAPIAndroid = "AIzaSyBjUcoI0sYFY9H8mb2n0IoBv26GxnPTRgs";
var placesAPIIOS = "AIzaSyAYFglgzIMLYXB9XQPaZ977MKUMseCJCvY";
var googleMapsAPIAndroid = "AIzaSyBv6FwSFMHrhQE6w5i7bIW_DcOOW08FVR8";
var googleMapsAPIIOS = "AIzaSyCHiJWFQzsfD-lO34bbctas1No0Kgxn9i4";

// User & Brand Global Variables
var currentUser = Usuario();
var currentBrand = Brand();
bool hasBrand = false;

// Unread Notifications And Chats
var unreadNotifications = 0;
var unreadChats = 0;

// Current User Location and TimeZone
Position? currentPosition;
String? currentAddress;
String? timeZoneName;

// Page Controller
int currentIndex = 0;
PageController pageController = PageController(initialPage: currentIndex);

// Dynamic Links Path
var dynamicLinkBrandId;



