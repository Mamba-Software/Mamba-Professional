import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';

import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Notifications/Notifications.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'Chat/ChatCore/ChatCore.dart';
import 'Marca/Marca.dart';
import 'Perfil/Perfil.dart';

// HomePage for the App. Here the user can change between the diferent pages.
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  // Boolean Loading
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    // Init LocalNotificationsService
    LocalNotificationService.initialize(context);
    /// Message on which User has tapped from Terminated State
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("App in Terminated State Notification Trigger HomePage");
        final route = message.data["route"];
        currentIndex = int.parse(route[route.length-1]);
        pageController.jumpToPage(currentIndex);
      }
    });
    // If App in Foreground.
    FirebaseMessaging.onMessage.listen((message) {
      print("App in Foreground Notification Trigger HomePage");
      LocalNotificationService.display(message);
    });
    // If App in Background, Tap on Notification to be Opened
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("App in Background Notification Trigger HomePage");
      final route = message.data["route"];
      if (route == "SplashScreen1") {
        String routeFromMessage = route.substring(0, route.length - 1);;
        currentIndex = int.parse(route[route.length-1]);
        Navigator.of(context).pushNamedAndRemoveUntil(routeFromMessage, (Route<dynamic> route) => false, arguments: currentIndex);
      } else {
        if (ModalRoute.of(context)!.isCurrent) {
          print("Top Page, Moving to Notifications Page");
          currentIndex = int.parse(route[route.length-1]);
          pageController.jumpToPage(currentIndex);
        } else {
          print("Not in Home Page, Moving to Splash Screen");
          String routeFromMessage = route.substring(0, route.length - 1);;
          currentIndex = int.parse(route[route.length-1]);
          Navigator.of(context).pushNamedAndRemoveUntil(routeFromMessage, (Route<dynamic> route) => false, arguments: currentIndex);
        }
      }
    });
    // Defining the Page Controller
    pageController = PageController(initialPage: currentIndex);
    // Getting User Information
    getUserAndBrand();
  }

  // Gets the user info from firebase.
  void getUserAndBrand() async {
    // Get User Main Data
    currentUser.setBasicData = await _userDataService.getUserDetails(currentUser.id!);
    // Get User Brand
    List<Brand> brands = await _brandDataService.getAllBrandsFromUser(currentUser.id!);
    currentUser.setBrandList = brands;
    if (currentUser.brandsList.isNotEmpty) {
      // Setting the Brand to the User
      Brand brand = currentUser.brandsList[0];
      currentBrand.setBasicData = await _brandDataService.getBrandDetails(brand.id!);
      currentBrand.setUserList = await _brandDataService.getBrandUsers(brand.id!);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        iconSize: MediaQuery.of(context).size.height*0.035,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppLocalizations.of(context)!.profileBottomNav,
            //backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: AppLocalizations.of(context)!.brandBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: unreadNotifications > 0 ? buildCustomBadge(
              counter: unreadNotifications,
              child: Icon(Icons.notifications_rounded),
            ) : Icon(Icons.notifications_rounded),
            label: AppLocalizations.of(context)!.notificationsBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: unreadChats > 0 ? buildCustomBadge(
              counter: unreadChats,
              child: Icon(Icons.chat),
            ) : Icon(Icons.chat),
            label: AppLocalizations.of(context)!.chatBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
        onTap: (index) {
          _onTappedBar(index);
        },
        selectedItemColor: Theme.of(context).accentColor,
        selectedLabelStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color:Theme.of(context).accentColor),
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).accentColor
        ),
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.grey),
        unselectedIconTheme: IconThemeData(
            color: Colors.grey
        ),
        showUnselectedLabels: true,
      ),
      body: PageView(
        //physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        //allowImplicitScrolling: true,
        children: <Widget>[
          Perfil(),
          Marca(),
          Notifications(),
          ChatCore(),
        ],
        onPageChanged: (page) async {
          unreadNotifications = await _userDataService.getUnreadNotifications(currentUser.id!);
          unreadChats = await _userDataService.getUnreadConversations(currentUser.id!);
          // Check User´s Brand List
          List<Brand> brands = await _brandDataService.getAllBrandsFromUser(currentUser.id!);
          currentUser.setBrandList = brands;
          // Check If User has New Brand
          if (hasBrand == false && currentUser.brandsList.isNotEmpty) {
            setState(() {
              currentIndex = 1;
            });
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute<Null>(
                  builder: (context) => SplashScreen(),
                  settings: RouteSettings(name: 'SplashScreen'),
                )
            );
          } else if (hasBrand == true && currentUser.brandsList.isEmpty)  {
            setState(() {
              currentIndex = 1;
            });
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute<Null>(
                  builder: (context) => SplashScreen(),
                  settings: RouteSettings(name: 'SplashScreen'),
                )
            );
          }
          setState(() {
            currentIndex = page;
          });
        },
      ),
    );
  }

  Future<void> _onTappedBar(int value) async {
    setState(() {
      currentIndex = value;
    });
    pageController.jumpToPage(value);
  }

  Widget buildCustomBadge({required int counter, required Widget child}) {

    final text = counter.toString();
    final deltaFontSize = (text.length - 1) * 3.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -2,
          right: -15,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).accentColor,
            radius: 10,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12 - deltaFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

