import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/AdminService/SettingsDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/HomeDialogs/AppUpdateDialog.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandPage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Sesions/Sesions.dart';
import '../../../Globals/Widgets/Components/Images/CircularImage.dart';
import '../Home/Marca/Marca.dart';
import 'Profile/Profile.dart';

// HomePage for the App. Here the user can change between the diferent pages.
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class MambaClient extends StatefulWidget {
  const MambaClient({Key? key}) : super(key: key);

  @override
  _MambaClientState createState() => _MambaClientState();
}

class _MambaClientState extends State<MambaClient> {

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  var _settingsDataService = new SettingsDataService();
  // Boolean Loading
  bool isLoading = false;
  // Boolean hasSeenStartUpDialog
  bool hasSeenStartUpDialog = false;

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
    // Check if User minimum version
    checkMinimumAppVersion();
    // Getting User Information
    getUserAndBrand();
  }

  // Check version and Update App Dialog
  void checkMinimumAppVersion() async {
    // Check version
    bool result = await _settingsDataService.checkIfMinimumAppVersion(appVersion);
    if (result == false) {
      // Start up Dialog
      Future.delayed(Duration.zero, () {
        return showDialog(
            context: context,
            builder: (_) {
              return AppUpdateDialog();
            }
        );
      });
    }
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
        type: BottomNavigationBarType.fixed,
        iconSize: MediaQuery.of(context).size.height*0.04,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 3.0),
              child: Icon(Icons.home_filled),
            ),
            label: AppLocalizations.of(context)!.profileBottomNav,
            //backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 3.0),
              child: Icon(Icons.groups),
            ),
            label: AppLocalizations.of(context)!.brandBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 3.0),
              child: Icon(Icons.calendar_month_outlined),
            ),
            label: AppLocalizations.of(context)!.sesionsBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 3.0),
              child: CircularImage(
                size: MediaQuery.of(context).size.height*0.04,
                image: currentUser.imageUrl!,
                borderWidth: 1,
                color: currentIndex == 3 ? Theme.of(context).primaryColor : AppColors.grey.withOpacity(0.5),
              ),
            ),
            label: AppLocalizations.of(context)!.profileBottomNav,
            //backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
        onTap: (index) {
          _onTappedBar(index);
        },
        showUnselectedLabels: true,
        selectedItemColor: Theme.of(context).primaryColor,
        selectedLabelStyle: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10, color:Theme.of(context).primaryColor),
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).primaryColor
        ),
        unselectedItemColor: AppColors.grey.withOpacity(0.5),
        unselectedLabelStyle: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10, color: AppColors.grey.withOpacity(0.5)),
        unselectedIconTheme: IconThemeData(
            color: AppColors.grey.withOpacity(0.5)
        ),
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        //allowImplicitScrolling: true,
        children: <Widget>[
          Marca(),
          BrandPage(),
          Sesions(),
          Profile(),
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

  @override
  void dispose() {
    super.dispose();
  }
}

