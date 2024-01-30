import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';
import 'package:mamba_castelldefels/Notifications/Unread/cubit/UnreadNotChatsCubit.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/007%20-%20Purchases/views/BrandPurchaseHistory.dart';
import 'package:mamba_castelldefels/Stripe/bloc/stripe_connect_bloc/stripe_connect_cubit.dart';
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

// Top Level -- Local BackGroundNotificationHandler
Future<void> backgroundLocalMessageHandler(
    NotificationResponse notificationResponse) async {
  LocalNotificationService localNotificationService =
      LocalNotificationService();
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

// Bootstrap
class Bootstrap {
  // Vars
  final FirebaseOptions? firebaseOptions;
  // Init
  Bootstrap({required this.firebaseOptions}) {
    bootstrap();
  }
  // Starting app function. After initialization, we define the global providers:
  Future<void> bootstrap() async {
    runZonedGuarded(() async {
      // Initialize App
      WidgetsFlutterBinding.ensureInitialized();
      // Load Env Variables
      print("Loading Environment Variables...");
      String envFileName = ".env.${currentFlavor.name}";
      await dotenv.load(fileName: envFileName);
      // Initialize Firebase
      if (kIsWeb) {
        // Web = Firebase Options
        await Firebase.initializeApp(
          options: firebaseOptions,
        );
      } else {
        // Mobile = Firebase .json or .plist
        await Firebase.initializeApp();
      }
      // Initialise TimeZone
      timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      // Firebase Messaging Back Ground Message Handler
      FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
      // Firebase Dynamic Links
      DynamicLinkUtils().retrieveDynamicLink();

      /// Production and Staging Only
      if (currentFlavor != Flavor.development) {
        // Firebase Crashlytics on Global Uncaught Errors
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
        // Set Log Level
        await Purchases.setLogLevel(LogLevel.info);
      }
      // Init MixPanel
      mixpanel = await Mixpanel.init(dotenv.env['MIXPANEL_KEY']!,
          trackAutomaticEvents: true, optOutTrackingDefault: false);
      // Init Revenue Cat
      if (Platform.isAndroid) {
        PurchasesConfiguration configuration =
            PurchasesConfiguration(dotenv.env['REVCAT_GOOGLE_API_KEY']!);
        await Purchases.configure(configuration);
      } else if (Platform.isIOS) {
        PurchasesConfiguration configuration =
            PurchasesConfiguration(dotenv.env['REVCAT_APPLE_API_KEY']!);
        await Purchases.configure(configuration);
      }
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
    }, (error, stackTrace) {
      print(error.toString());
      if (currentFlavor != Flavor.development) {
        // Firebase Crashlytics on Explicitly Caught Exceptions
        FirebaseCrashlytics.instance.recordError(error, stackTrace);
      }
    });
  }

  // BackGroundNotificationHandler
  Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    LocalNotificationService localNotificationService =
        LocalNotificationService();
    if (message.data.containsKey('route')) {
      String route = message.data['route'];
      localNotificationService.onNotifications.add(route);
    }
  }
}

// Material App
class Mamba extends StatefulWidget {
  const Mamba({super.key});
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
        BlocProvider(
          create: (_) => StripeConnectCubit(),
        ),
      ],
      child:
          Consumer3<LanguageProvider, ThemeProvider, FirebaseAnalyticsProvider>(
              builder: (context, LanguageProvider language, ThemeProvider theme,
                  FirebaseAnalyticsProvider analytics, _) {
        AppThemes appThemes = AppThemes();
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
              debugShowCheckedModeBanner: currentFlavor == Flavor.development,
              title: Constants.appName,
              themeMode: theme.themeMode,
              theme: appThemes.returnResponsiveLightTheme(100.vh),
              darkTheme: appThemes.returnResponsiveDarkTheme(100.vh),
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
                    pageIndex = 18;
                    break;
                  case 'MembershipRequests':
                    String brandId = args as String;
                    return CupertinoPageRoute(
                      builder: (_) => MembershipRequestsPro(
                        brandId: brandId,
                      ),
                      settings: const RouteSettings(name: 'MembershipRequests'),
                    );
                }
                return null;
              },
            );
          },
        );
      }),
    );
  }
}
