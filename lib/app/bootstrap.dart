import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mamba/analytics/data/analytics_repository.dart';
import 'package:mamba/app/router/router.dart';
import 'package:mamba/auth/bloc/auth_bloc.dart';
import 'package:mamba/auth/data/auth_repository.dart';
import 'package:mamba/brand/bloc/brand_bloc.dart';
import 'package:mamba/brand/data/brand_repository.dart';
import 'package:mamba/commons/managers/theme_manager.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba/notifications/NotificationService/LocalNotificationService.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/cubit/BrandEventsCubit.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/ClientSessions/cubit/ClientsSessionsCubit.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';
import 'package:mamba/popups/cubit/popups_cubit.dart';
import 'package:mamba/popups/views/popup_manager.dart';
import 'package:mamba/settings/data/settings_repository.dart';
import 'package:mamba/snackbar/cubit/snackbar_cubit.dart';
import 'package:mamba/snackbar/views/snackbar_manager.dart';
import 'package:mamba/notifications/Unread/cubit/UnreadNotChatsCubit.dart';
import 'package:mamba/stripe/bloc/stripe_connect_bloc/stripe_connect_cubit.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:mamba/user/data/firebase_user_repository.dart';
import 'package:mamba/user/data/user_repository.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

class Bootstrap with PlatformMixin {
  // Initialize Variables
  final FirebaseOptions? firebaseOptions;
  Bootstrap(this.firebaseOptions);
  // Initialize Function
  Future<void> initialize() async {
    runZonedGuarded(
      () async {
        // Initialize App
        WidgetsFlutterBinding.ensureInitialized();
        // Initialize Hive
        await Hive.initFlutter();
        // Initialize Env Variables
        String envFileName = ".env.${flavor.name}";
        await dotenv.load(fileName: envFileName);
        // Initialize Firebase
        if (isWeb) {
          // Web = Firebase Options
          await Firebase.initializeApp(options: firebaseOptions);
        } else {
          // Mobile = Firebase .json or .plist
          await Firebase.initializeApp();
        }

        // TO DO: NETEJAR AIXÒ PER AL SEU PROPI CUBIT
        /////////////////////////////////////////////

        mixpanel = await Mixpanel.init(
          dotenv.env['MIXPANEL_KEY']!,
          trackAutomaticEvents: true,
          optOutTrackingDefault: false,
        );

        // Initialise TimeZone
        timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
        // Firebase Messaging Back Ground Message Handler
        FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
        // Firebase Dynamic Links
        if (isWeb == false) {
          await DynamicLinkUtils().retrieveDynamicLink();
        }

        /////////////////////////////////////////////
        // TO DO: NETEJAR AIXÒ PER AL SEU PROPI CUBIT

        // Firebase Crashlytics on Global Uncaught Errors
        if (flavor != Flavor.development) {
          FlutterError.onError =
              FirebaseCrashlytics.instance.recordFlutterError;
        }
        // For Path Url Strategy in Web
        usePathUrlStrategy();
        // Run App
        runApp(App());
      },
      (error, stackTrace) {
        if (flavor != Flavor.development) {
          // Firebase Crashlytics on Explicitly Caught Exceptions
          FirebaseCrashlytics.instance.recordError(error, stackTrace);
        }
        print("Error:");
        print(error);
      },
    );
  }
}

// Handle App Level Repositories and Blocs
class App extends StatelessWidget {
  App({super.key});

  final UserRepository userRepository = FirebaseUserRepository();
  final BrandRepository brandRepository = BrandRepository();
  final AuthRepository authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    final userBloc = UserBloc(userRepository: userRepository);
    final brandBloc =
        BrandBloc(brandRepository: brandRepository, userBloc: userBloc);
    final authBloc =
        AuthBloc(authRepository: authRepository, userBloc: userBloc);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AnalyticsRepository>(
          create: (context) => AnalyticsRepository(
            isRelease: flavor != Flavor.development || flavor != Flavor.staging,
          ),
        ),
        RepositoryProvider<UserRepository>(create: (context) => userRepository),
        RepositoryProvider<SettingsRepository>(
          create: (context) => SettingsRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => authBloc),
          BlocProvider<UserBloc>(create: (_) => userBloc),
          BlocProvider<BrandBloc>(create: (_) => brandBloc),
          // Refactor Done
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(BlocProvider.of<AuthBloc>(context)),
            lazy: false,
          ),
          BlocProvider<ThemeManager>(
            create: (context) => ThemeManager(),
          ),
          BlocProvider<LanguageManager>(
            create: (context) => LanguageManager(
              settingsRepository: context.read<SettingsRepository>(),
            ),
          ),
          BlocProvider<PopupsCubit>(
            create: (context) => PopupsCubit(
              settingsRepository: context.read<SettingsRepository>(),
            ),
          ),
          BlocProvider<SnackbarCubit>(
            create: (context) => SnackbarCubit(),
          ),
          // To Be Refactored
          BlocProvider<ClientSessionsCubit>(
            create: (_) => ClientSessionsCubit([]),
            lazy: false,
          ),
          BlocProvider<CrudEventCubit>(
            lazy: false,
            create: (context) => CrudEventCubit(),
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
            lazy: false,
          ),
        ],
        child: const AppView(), // Your AppView widget
      ),
    );
  }
}

// Material App
class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  AppViewState createState() => AppViewState();
}

class AppViewState extends State<AppView> with WidgetsBindingObserver {
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
    return BlocBuilder<ThemeManager, ThemeState>(builder: (context, theme) {
      return BlocBuilder<LanguageManager, LanguageState>(
        builder: (context, language) {
          return MaterialApp.router(
            title: appName,
            debugShowCheckedModeBanner: flavor == Flavor.development,
            theme: theme.themeData,
            locale: language.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return PopupManager(
                navigatorKey:
                    AppRouter.navigatorKey, // Use the GoRouter navigatorKey
                child: SnackbarManager(
                  navigatorKey:
                      AppRouter.navigatorKey, // Use the same navigatorKey
                  child: child!,
                ),
              );
            },
            routerDelegate: AppRouter.router.routerDelegate,
            routeInformationProvider: AppRouter.router.routeInformationProvider,
            routeInformationParser: AppRouter.router.routeInformationParser,
          );
        },
      );
    });
  }
}
