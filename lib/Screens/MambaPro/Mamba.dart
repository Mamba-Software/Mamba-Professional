// ignore_for_file: avoid_print
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/AdminService/SettingsDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/Permissions/PermisionsService.dart';
import 'package:mamba_castelldefels/Globals/Utils/SharePlus/SharePlusUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/HomeDialogs/AppUpdateDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/HomeDialogs/BrandInviteDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/HomeDialogs/BrandInvitePage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/BrandScreen.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/NoBrandScreens/NoBrandScreen.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../Globals/Utils/MambaProSelector/MambaProUtils.dart';

// HomePage for the App. Here the user can change between the diferent pages.
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class Mamba extends StatefulWidget {
  const Mamba({Key? key}) : super(key: key);

  @override
  _MambaState createState() => _MambaState();
}

class _MambaState extends State<Mamba> {

  // Screen Dimensions
  double safeAreaHeight = 0;
  double safeAreaWidth = 0;

  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _settingsDataService = SettingsDataService();
  final _mambaProUtils = MambaProUtils();
  final SharePlusUtils _sharePlusUtils = SharePlusUtils();
  // Boolean Loading
  bool isLoading = false;
  bool hasBrand = false;
  bool isActive = false;
  // Boolean hasSeenStartUpDialog
  bool hasSeenStartUpDialog = false;
  // Notifications
  LocalNotificationService localNotificationService = LocalNotificationService();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    initPlatformState();
    // Handle LocalNotificationsService
    localNotificationService.initialize();
    handleAndlistenNotifications(context);
    // Firebase Cloud Messaging Notifications
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("App in Terminated State Notification Trigger HomePage");
        String route = message.data["route"];
        // Handling OnClickNotification Firebase Messaging Notification
        localNotificationService.onClickedNotification(context, route);
      }
    });
    // If App in Foreground.
    FirebaseMessaging.onMessage.listen((message) {
      print("App in Foreground Notification Trigger HomePage");
      ReceivedNotification notif = ReceivedNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/1000,
        title: message.notification!.title,
        body: message.notification!.body,
        payload: message.data["route"],
      );
      localNotificationService.showNotification(notif);
    });
    // If App in Background, Tap on Notification to be Opened
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("App in Background Notification Trigger HomePage");
      String route = message.data["route"];
      // Handling OnClickNotification Firebase Messaging Notification
      localNotificationService.onClickedNotification(context, route);
    });
    // Listen Dynamic Link Foreground / Background State
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      dynamicLinkBrandId = dynamicLinkData.link.queryParameters['id'];
      checkBrandInvite();
    }).onError((error) {
      print(error.toString());
    });
    // Setting default open to Homepage
    pageIndex = 0;
    // Getting User Information
    getUserAndBrand();
    // On StartUp Dialogs
    launchOnStartUpDialogs();
  }

  Future<void> initPlatformState() async {
    // Enable debug logs before calling `configure`.
    await Purchases.setLogLevel(LogLevel.debug);

    /*
    - appUserID is nil, so an anonymous ID will be generated automatically by the Purchases SDK. Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids
    - observerMode is false, so Purchases will automatically handle finishing transactions. Read more about Observer Mode here: https://docs.revenuecat.com/docs/observer-mode
    */
    PurchasesConfiguration configuration;

    configuration = PurchasesConfiguration(googleApiKey);

    await Purchases.configure(configuration);
  }

  // On StartUp Dialogs
  Future<void> launchOnStartUpDialogs() async {
    // First check if minimum version
    print("Checking Minimum App Version...");
    checkMinimumAppVersion();
    // Check if invited into Brand
    print("Checking if invited into Brand...");
    checkBrandInvite();
    // Check Notification Permissions
    print("Checking Notification Permissions...");
    var notificationString = await PermisionsService().checkUserNotificationsPermision();
    if (notificationString == "Provisional" || notificationString == "Unknown") {
      mixpanel!.track('notifications_permission_ask');
      PermissionStatus permission = await PermisionsService().askUserNotificationsPermision();
      switch (permission) {
        case PermissionStatus.denied:
          mixpanel!.track('notifications_permission_denied');
          break;
        case PermissionStatus.granted:
          mixpanel!.track('notifications_permission_granted');
          break;
        case PermissionStatus.unknown:
          mixpanel!.track('notifications_permission_unknown');
          break;
        case PermissionStatus.provisional:
          mixpanel!.track('notifications_permission_provisional');
          break;
        default:
          break;
      }
    }
    // Check Location Permissions
    print("Checking Location Permissions...");
    await PermisionsService().getUserLocation();
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  // Check version and Update App Dialog
  void checkMinimumAppVersion() async {
    // Check version
    List<bool> result = await _settingsDataService.checkIfMinimumAppVersion(appVersion);
    if (result[0] == false) {
      mixpanel!.track('minimum_app_version_open', properties: {'isMandatory': result[1]});
      if (result[1]) {
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AppUpdateDialog(
                  isMandatory: true,
                ),
              );
            },
          );
        });
      } else {
        var returnDialog = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AppUpdateDialog(
              isMandatory: false,
            );
          },
        );
        if (returnDialog == null) {
          mixpanel!.track('minimum_app_version_close', properties: {'isMandatory': false});
        }
      }
    }
  }

  // Check invited by Brand
  void checkBrandInvite() async {
    if (dynamicLinkBrandId != null && currentUser.brandsList.isEmpty) {
      await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.85,
            child: BrandInvitePage(
              brandId: dynamicLinkBrandId,
            ),
          );
        },
      );
      mixpanel!.track('brand_invite_modal_close', properties: {'Brand': dynamicLinkBrandId});
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
      hasBrand = true;
      Brand brand = currentUser.brandsList[0];
      currentBrand.setBasicData = await _brandDataService.getBrandDetails(brand.id!);
      currentBrand.setUserList = await _brandDataService.getBrandUsers(brand.id!);
      // Get Role in Brand
      int role = await _brandDataService.getUserBrandRole(brand.id!, currentUser.id!);
      currentUser.setBrandRole = role;
      mixpanel!.getPeople().set("Brands Roles", [role]);
      setBrandActive();
    }
    setState(() {
      isLoading = false;
    });
  }

  // listenNotifications if User Taps on Notifications
  Future<void> handleAndlistenNotifications(BuildContext context) async {
    // Did Launch the App
    await localNotificationService.didNotificationLaunch(context);
    // Handle Local Notifications
    await localNotificationService.handleLocalNotifications(context);
    // Listen to the Notifications Stream
    localNotificationService.onNotifications.stream.listen(
            (payload) => localNotificationService.onClickedNotification(context, payload!)
    );
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Scaffold(
      body: LoadingView(),
    ) :
      hasBrand ? !brandIsActive? currentUser.brandRole < 2? PayWall(brandId: currentBrand.id!, comesFromInitPage: true) : const BrandScreen() : const BrandScreen() : const NoBrandScreen();
  }




}

