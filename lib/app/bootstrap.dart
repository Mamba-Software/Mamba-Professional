import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba/events/crud_events/read_event/views/mobile/ReadEventPage.dart';
import 'package:mamba/notifications/NotificationService/LocalNotificationService.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/views/mobile/SplashScreen.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/cubit/BrandEventsCubit.dart';
import 'package:mamba/notifications/NotificationService/Notifications.dart';
import 'package:mamba/app/theme/ThemeProvider.dart';
import 'package:mamba/app/theme/AppThemes.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/ClientSessions/cubit/ClientsSessionsCubit.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Events/EventFeedback.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';
import 'package:mamba/popups/cubit/popups_cubit.dart';
import 'package:mamba/popups/views/popup_manager.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/MembershipRequestsPro.dart';
import 'package:mamba/settings/data/firebase_settings_repository.dart';
import 'package:mamba/settings/data/hive_settings_repository.dart';
import 'package:mamba/settings/data/settings_repository.dart';
import 'package:mamba/user/chat/ChatCore.dart';
import 'package:mamba/notifications/Unread/cubit/UnreadNotChatsCubit.dart';
import 'package:mamba/stripe/bloc/stripe_connect_bloc/stripe_connect_cubit.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/l10n/Idiomas.dart';
import 'package:mamba/l10n/LanguageProvider.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:resize/resize.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

// Bootstrap
class Bootstrap with PlatformMixin {
  // Vars
  final FirebaseOptions? firebaseOptions;
  // Init
  Bootstrap({required this.firebaseOptions}) {
    bootstrap();
  }
  // Starting app function. After initialization, we define the global providers:
  Future<void> bootstrap() async {
    runZonedGuarded(() async {
      // Load Env Variables
      print("Loading Environment Variables...");
      String envFileName = ".env.${currentFlavor.name}";
      await dotenv.load(fileName: envFileName);
      // Initialize Firebase
      if (isWeb) {
        // Web = Firebase Options
        await Firebase.initializeApp(
          options: firebaseOptions,
        );
      } else {
        // Mobile = Firebase .json or .plist
        await Firebase.initializeApp();
      }
      // Initialize Hive
      await Hive.initFlutter();
      // Initialise TimeZone
      timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      // Firebase Messaging Back Ground Message Handler
      FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
      // Firebase Dynamic Links
      if (isWeb == false) DynamicLinkUtils().retrieveDynamicLink();
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
      if (isAndroid) {
        PurchasesConfiguration configuration =
            PurchasesConfiguration(dotenv.env['REVCAT_GOOGLE_API_KEY']!);
        await Purchases.configure(configuration);
      } else if (isIOS) {
        PurchasesConfiguration configuration =
            PurchasesConfiguration(dotenv.env['REVCAT_APPLE_API_KEY']!);
        await Purchases.configure(configuration);
      }
      //Init Stripe
      Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
      // Run App
      runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider<LanguageProvider>(
              create: (_) => LanguageProvider()),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
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
  final navigatorKey = GlobalKey<NavigatorState>();
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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingsRepository>(
          create: (context) => SettingsRepository(
            FirebaseSettingsRepository(),
            HiveSettingsRepository(),
          ),
        ),
      ],
      child: MultiBlocProvider(
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
            create: (context) =>
                BrandSuscriptionCubit(context.read<AuthCubit>()),
            lazy: false,
          ),
          BlocProvider(
            create: (_) => StripeConnectCubit(),
          ),
          BlocProvider<PopupsCubit>(
            create: (context) => PopupsCubit(
              settingsRepository: context.read<SettingsRepository>(),
            ),
          ),
        ],
        child: Consumer2<LanguageProvider, ThemeProvider>(builder:
            (context, LanguageProvider language, ThemeProvider theme, _) {
          AppThemes appThemes = AppThemes();
          final brightness =
              SchedulerBinding.instance.window.platformBrightness;
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
                navigatorKey: navigatorKey,
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
                builder: (context, child) {
                  // Wrap every screen with PopupManager using MaterialApp.builder
                  return PopupManager(
                    navigatorKey: navigatorKey,
                    child: child!,
                  );
                },
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
                        settings:
                            const RouteSettings(name: 'MembershipRequests'),
                      );
                  }
                  return null;
                },
              );
            },
          );
        }),
      ),
    );
  }
}
