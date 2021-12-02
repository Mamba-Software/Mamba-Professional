// This file contains all the Global Variabels used throgh the App.
import 'package:geolocator/geolocator.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// API Keys
var placesAPIAndroid = "AIzaSyBjUcoI0sYFY9H8mb2n0IoBv26GxnPTRgs";
var placesAPIIOS = "AIzaSyAYFglgzIMLYXB9XQPaZ977MKUMseCJCvY";

// User & Brand Global Variables
var currentUser = Usuario();
var currentBrand = Brand();

// Unread Notifications and Chats
var unreadNotifications = 0;
var unreadChats = 0;

// Current User Location
Position? currentPosition;
String? currentAddress;