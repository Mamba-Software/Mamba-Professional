import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mamba_castelldefels/Events/crud_events/read_event/views/mobile/ReadEventPage.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Auth/views/mobile/SplashScreen.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/cubit/BrandEventsCubit.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/Notifications.dart';
import 'package:mamba_castelldefels/Globals/Providers/FirebaseAnalyticsProvider.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppThemes/AppThemes.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/ChatCore.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/ClientSessions/cubit/ClientsSessionsCubit.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventFeedback.dart';
import 'package:mamba_castelldefels/firebase_options_development.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';
import 'package:mamba_castelldefels/Notifications/Unread/cubit/UnreadNotChatsCubit.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Globals/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:resize/resize.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'dart:io' show Platform;
import 'Globals/Utils/DynamicLinks/DynamicLinkUtils.dart';
import 'Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/MembershipRequestsPro.dart';
import 'Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/BrandPurchaseHistory/views/BrandPurchaseHistory.dart';

// Declaring Instance of AppThemes();
AppThemes _appThemes = AppThemes();
// Initialize the [FlutterLocalNotificationsPlugin] package.
LocalNotificationService localNotificationService = LocalNotificationService();
// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

// BackGroundNotificationHandler
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  if (message.data.containsKey('route')) {
    String route = message.data['route'];
    localNotificationService.onNotifications.add(route);
  }
}

// Local BackGroundNotificationHandler
Future<void> backgroundLocalMessageHandler(
    NotificationResponse notificationResponse) async {
  switch (notificationResponse.notificationResponseType) {
    case NotificationResponseType.selectedNotification:
      localNotificationService.onNotifications
          .add(notificationResponse.payload);
      break;
    case NotificationResponseType.selectedNotificationAction:
      localNotificationService.onNotifications
          .add(notificationResponse.payload);
      break;
  }
}

// Starting app function. After initialization, we define the global providers:
// - Language Provider: To change the Language of the App.
Future<void> main() async {
  await runZonedGuarded(() async {
    // Initialize App
    WidgetsFlutterBinding.ensureInitialized();
    // Initialize Firebase
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );  
    } else {
      await Firebase.initializeApp();
    }
    // Initialise TimeZone
    timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    // Firebase Messaging Back Ground Message Handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
    // Firebase Dynamic Links
    DynamicLinkUtils().retrieveDynamicLink();
    // Firebase Crashlytics
    if (isProduction) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    }
    // Init MixPanel
    mixpanel = await Mixpanel.init("c573538be2d62355bb2f0968ff42c181",
        trackAutomaticEvents: true, optOutTrackingDefault: false);
    mixpanel = await Mixpanel.init("c573538be2d62355bb2f0968ff42c181",
        trackAutomaticEvents: true, optOutTrackingDefault: false);
    await initPlatformState();
    // Run App
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>(
            create: (_) => LanguageProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<FirebaseAnalyticsProvider>(
            create: (_) => FirebaseAnalyticsProvider()),
      ],
      child: const Mamba(),
    ));
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>(
            create: (_) => LanguageProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<FirebaseAnalyticsProvider>(
            create: (_) => FirebaseAnalyticsProvider()),
      ],
      child: const Mamba(),
    ));
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

Future<void> initPlatformState() async {
  await Purchases.setLogLevel(LogLevel.debug);

  if (Platform.isAndroid) {
    PurchasesConfiguration configuration = PurchasesConfiguration(googleApiKey);
    await Purchases.configure(configuration);
  } else if (Platform.isIOS) {
    PurchasesConfiguration configuration = PurchasesConfiguration(appleApiKey);
    await Purchases.configure(configuration);
  }
}

class Mamba extends StatefulWidget {
  const Mamba({Key? key}) : super(key: key);

  @override
  _MambaState createState() => _MambaState();
}

class _MambaState extends State<Mamba> with WidgetsBindingObserver {
  final _dynamicLinkUtils = DynamicLinkUtils();
  Timer? _timerLink;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = Timer(
        const Duration(milliseconds: 1000),
        () {
          _dynamicLinkUtils.retrieveDynamicLink();
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ClientSessionsCubit>(
          create: (_) => ClientSessionsCubit([]),
          lazy: false,
        ),
        BlocProvider<CrudEventCubit>(
          lazy: false,
          create: (context) => CrudEventCubit(),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
          lazy: false,
        ),
        BlocProvider<UnreadNotChatsCubit>(
          create: (context) => UnreadNotChatsCubit(context.read<AuthCubit>()),
          lazy: false,
        ),
        BlocProvider<BrandEventsCubit>(
          create: (context) => BrandEventsCubit(context.read<AuthCubit>()),
          lazy: false,
        ),
        BlocProvider<BrandSuscriptionCubit>(
          create: (context) => BrandSuscriptionCubit(context.read<AuthCubit>()),
          lazy: false,
        ),
      ],
      child:
          Consumer3<LanguageProvider, ThemeProvider, FirebaseAnalyticsProvider>(
              builder: (context, LanguageProvider language, ThemeProvider theme,
                  FirebaseAnalyticsProvider analytics, _) {
        final brightness = SchedulerBinding.instance.window.platformBrightness;
        if (brightness == Brightness.dark) {
          print("Dark Mode");
          theme.darkModeStatusAndNavigationBar();
        } else {
          print("Light Mode");
          theme.lightModeStatusAndNavigationBar();
        }
        return Resize(
          allowtextScaling: true,
          builder: () {
            return MaterialApp(
              debugShowCheckedModeBanner: true,
              title: Constants.appName,
              themeMode: theme.themeMode,
              theme: _appThemes.returnResponsiveLightTheme(100.vh),
              darkTheme: _appThemes.returnResponsiveDarkTheme(100.vh),
              locale: language.idioma,
              supportedLocales: Idiomas.all,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
              onGenerateRoute: (RouteSettings settings) {
                final args = settings.arguments;
                print('ARGUMENTS');
                print(settings.name);
                switch (settings.name) {
                  case 'SplashScreen':
                    return CupertinoPageRoute(
                      builder: (_) => const SplashScreen(),
                      settings: const RouteSettings(name: 'SplashScreen'),
                    );
                  case 'Notifications':
                    return CupertinoPageRoute(
                      builder: (_) => const Notifications(),
                      settings: const RouteSettings(name: 'Notifications'),
                    );
                  case 'Chat':
                    return CupertinoPageRoute(
                      builder: (_) => const ChatCore(),
                      settings: const RouteSettings(name: 'ChatCore'),
                    );
                  case 'EventPage':
                    String eventId = args as String;
                    return CupertinoPageRoute(
                      builder: (_) => EventPage(
                        eventId: eventId,
                      ),
                      settings: const RouteSettings(name: 'EventPage'),
                    );
                  case 'EventFeedbackPage':
                    String eventId = args as String;
                    return CupertinoPageRoute(
                      builder: (_) => EventFeedback(
                        eventId: eventId,
                      ),
                      settings: const RouteSettings(name: 'EventFeedback'),
                    );
                  case 'BonosRequests':
                    String brandId = args as String;
                    setState(() {
                      pageIndex = 5;
                    });
                    return CupertinoPageRoute(
                      builder: (_) => BrandPurchaseHistory(brandId: brandId),
                      settings: const RouteSettings(name: 'BonosRequests'),
                    );
                  case 'MembershipRequests':
                    String brandId = args as String;
                    return CupertinoPageRoute(
                      builder: (_) => MembershipRequestsPro(
                        brandId: brandId,
                      ),
                      settings: const RouteSettings(name: 'MembershipRequests'),
                    );
                }
              },
            );
          },
        );
      }),
    );
  }
}
