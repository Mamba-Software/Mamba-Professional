// ignore_for_file: avoid_print
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/Events/cubit/events_bloc.dart';
import 'package:mamba/auth/bloc/auth_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/views/Login.dart';
import 'package:mamba/brand/bloc/brand_bloc.dart';
import 'package:mamba/calendar/cubit/calendar_bloc.dart';
import 'package:mamba/home/cubit/home_manager.dart';
import 'package:mamba/brand/bloc/brand_bloc.dart';
import 'package:mamba/home/views/brand_screen.dart';
import 'package:mamba/data/AdminService/SettingsDataService.dart';
import 'package:mamba/data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/home/views/no_brand_screen.dart';
import 'package:mamba/notifications/NotificationService/LocalNotificationService.dart';
import 'package:mamba/commons/managers/PermisionsService.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/HomeDialogs/BrandInvitePage.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:mamba/popups/cubit/popups_cubit.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:notification_permissions/notification_permissions.dart';

class HomePage extends StatelessWidget {
  static String routeName = '/';
  static GoRoute route = GoRoute(
    name: routeName,
    path: '/',
    builder: (BuildContext context, GoRouterState state) => HomePage(),
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeManager>(
          create: (context) => HomeManager(),
        ),
        BlocProvider<CalendarBloc>(
          create: (context) => CalendarBloc(
            context: context,
            userBloc: context.read<UserBloc>(),
            brandBloc: context.read<BrandBloc>(),
            eventBloc: context.read<EventsBloc>(),
          ),
        ),
      ],
      child: const HomePageBody(),
    );
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
  // Acceso a Base de Datos
  final _settingsDataService = SettingsDataService();
  // Boolean Loading
  bool isLoading = false;
  bool hasBrand = false;
  bool isActive = false;
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
    // Getting User Information
    setState(() {
      isLoading = false;
    });
    // Check If App Update
    context.read<PopupsCubit>().checkIfAppUpdate();

    final currentState = context.read<BrandBloc>().state;
    if (currentState.brand.id != null && currentState.brand.id != '') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(BrandScreen.routeName);
      });
    }

    // On StartUp Dialogs
    launchOnStartUpDialogs();
  }

  Future<void> firstFunction() async {
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

    // Getting User Information
    setState(() {
      isLoading = false;
    });
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
    final brandBloc = context.read<BrandBloc>();

    // Verifica el estado actual inmediatamente al construir el widget
    final currentState = brandBloc.state;
    if (currentState.brand.id != null && currentState.brand.id! != '') {
      context.goNamed(BrandScreen.routeName);
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthStateS>(
          listener: (context, state) {
            switch (state.status) {
              case AuthStatus.unauthenticated:
                context.goNamed(Login.routeName);
                break;
              case AuthStatus.authenticated:
                break;
              case AuthStatus.unknown:
                break;
            }
          },
        ),
        BlocListener<BrandBloc, BrandState>(
          listener: (context, state) {
            if (state.brand.id != null && state.brand.id! != '') {
              context.goNamed(BrandScreen.routeName);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: LoadingView(
          hasLogo: false,
          isSmall: true,
          color: AppColors.white,
        ),
      ),
    );
    /* BlocSelector<BrandBloc, BrandState, BrandState>(
              selector: (state) {
                return state;
              },
              builder: (context, state) {
                if (state.brand.id != null && state.brand.id! != '') {
                  if (state.brand.id == 'none') {
                    return const NoBrandScreen();
                  } else if (!state.brand.brandActive &&
                      currentUser.id == currentBrand.adminID) {

                      
 else {
                      return PayWall(
                          brandId: currentBrand.id!, comesFromInitPage: true);
                    }
                  } else {
                    return const BrandScreen();
                  }
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
                /*if (state is AuthUserBrand) {
                  return !brandIsActive
                      ? currentUser.id == currentBrand.adminID
                          ? PayWall(
                              brandId: currentBrand.id!,
                              comesFromInitPage: true)
                          : const BrandScreen()
                      : const BrandScreen();
                } else if (state is AuthUserNoBrand) {
                  return const NoBrandScreen();
                } else {}
              },*/
              },
            ),
    ); */ // The method to build widget based on AuthState
  }
}
