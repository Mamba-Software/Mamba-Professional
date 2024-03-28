// ignore_for_file: avoid_print
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/home/views/brand_screen.dart';
import 'package:mamba/data/AdminService/SettingsDataService.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/home/views/no_brand_screen.dart';
import 'package:mamba/notifications/NotificationService/LocalNotificationService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/commons/managers/PermisionsService.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/HomeDialogs/BrandInvitePage.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:mamba/popups/cubit/popups_cubit.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const HomePageBody();
    /*
    return MultiBlocProvider(
      providers: const [        
        // Add BlocProviders here when needed

      ],
      child: const HomePageBody(),
    );
    */
  }
}

// HomePage for the App. Here the user can change between the diferent pages .
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  _HomePageBodyState createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  // Screen Dimensions
  double safeAreaHeight = 0;
  double safeAreaWidth = 0;

  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _settingsDataService = SettingsDataService();
  // Boolean Loading
  bool isLoading = false;
  bool hasBrand = false;
  bool isActive = false;
  // Boolean hasSeenStartUpDialog
  bool hasSeenStartUpDialog = false;
  // Notifications
  LocalNotificationService localNotificationService =
      LocalNotificationService();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    isLoading = true;
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
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
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
    // Setting default open to Brand Calendar
    pageIndex = 10;
    // Getting User Information
    getUserAndBrand();
    // Check If App Update
    context.read<PopupsCubit>().checkIfAppUpdate();
    // On StartUp Dialogs
    launchOnStartUpDialogs();
  }

  // On StartUp Dialogs
  Future<void> launchOnStartUpDialogs() async {
    //Stripe
    stripeActivatedGlobal = await _settingsDataService.getStripeActivated();
    // Check if invited into Brand
    print("Checking if invited into Brand...");
    checkBrandInvite();
    // Check Notification Permissions
    print("Checking Notification Permissions...");
    var notificationString =
        await PermisionsService().checkUserNotificationsPermision();
    if (notificationString == "Provisional" ||
        notificationString == "Unknown") {
      mixpanel!.track('notifications_permission_ask');
      PermissionStatus permission =
          await PermisionsService().askUserNotificationsPermision();
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
      mixpanel!.track('brand_invite_modal_close',
          properties: {'Brand': dynamicLinkBrandId});
    }
  }

  // Gets the user info from firebase.
  void getUserAndBrand() async {
    // Get User Main Data
    currentUser.setBasicData =
        await _userDataService.getUserDetails(currentUser.id!);
    // Get User Brand
    List<Brand> brands =
        await _brandDataService.getAllBrandsFromUser(currentUser.id!);
    currentUser.setBrandList = brands;
    if (currentUser.brandsList.isNotEmpty) {
      // Setting the Brand to the User
      hasBrand = true;
      Brand brand = currentUser.brandsList[0];
      currentBrand.setBasicData =
          await _brandDataService.getBrandDetails(brand.id!);
      currentBrand.setUserList =
          await _brandDataService.getBrandUsers(brand.id!);

      // Get Role in Brand
      int role =
          await _brandDataService.getUserBrandRole(brand.id!, currentUser.id!);
      currentUser.setBrandRole = role;
      if (currentUser.id == currentBrand.adminID) {
        Purchases.logIn(currentBrand.id!);
      }
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
    localNotificationService.onNotifications.stream.listen((payload) =>
        localNotificationService.onClickedNotification(context, payload!));
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: AppColors.black,
            body: LoadingView(
              hasLogo: false,
              isSmall: true,
              color: AppColors.white,
            ),
          )
        : BlocSelector<AuthCubit, AuthState, AuthState>(
            selector: (state) {
              return state;
            },
            builder: (context, state) {
              if (state is AuthUserBrand) {
                return !brandIsActive
                    ? currentUser.id == currentBrand.adminID
                        ? PayWall(
                            brandId: currentBrand.id!, comesFromInitPage: true)
                        : const BrandScreen()
                    : const BrandScreen();
              } else if (state is AuthUserNoBrand) {
                return const NoBrandScreen();
              } else {
                return Scaffold(
                  backgroundColor: AppColors.black,
                  body: LoadingView(
                    hasLogo: false,
                    isSmall: true,
                    color: AppColors.white,
                  ),
                );
              }
            },
          ); // The method to build widget based on AuthState
  }
}
