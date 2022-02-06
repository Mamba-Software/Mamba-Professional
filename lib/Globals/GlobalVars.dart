// This file contains all the Global Variabels used throgh the App.
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

// IS PRODUCTION?
bool isProduction = true;

// App Version
var version = "MAMBA v0.0.3";

// Website
var websiteES = "https://mambastyle.net/";
var websiteCA = "https://mambastyle.net/ca/inici/";
var termsAndConditionsES = "https://mambastyle.net/terminos-y-condiciones/";
var termsAndConditionsCA = "https://mambastyle.net/ca/termes-i-condicions/";

// API Keys
var placesAPIAndroid = "AIzaSyBjUcoI0sYFY9H8mb2n0IoBv26GxnPTRgs";
var placesAPIIOS = "AIzaSyAYFglgzIMLYXB9XQPaZ977MKUMseCJCvY";

// User & Brand Global Variables
var currentUser = Usuario();
var currentBrand = Brand();
bool hasBrand = false;

// Unread Notifications and Chats
var unreadNotifications = 0;
var unreadChats = 0;

// Current User Location
Position? currentPosition;
String? currentAddress;

// Page Controller
int currentIndex = 0;
PageController pageController = PageController(initialPage: currentIndex);
