import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mamba/Events/cubit/events_bloc.dart';
import 'package:mamba/analytics/data/analytics_repository.dart';
import 'package:mamba/app/router/router.dart';
import 'package:mamba/auth/bloc/auth_bloc.dart';
import 'package:mamba/auth/data/auth_repository.dart';
import 'package:mamba/auth/sign_in/cubit/sign_in_cubit.dart';
import 'package:mamba/brand/bloc/brand_bloc.dart';
import 'package:mamba/brand/data/brand_repository.dart';
import 'package:mamba/calendar/cubit/calendar_bloc.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/managers/theme_manager.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/ClientSessions/cubit/ClientsSessionsCubit.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';
import 'package:mamba/home/cubit/home_manager.dart';
import 'package:mamba/popups/cubit/popups_cubit.dart';
import 'package:mamba/popups/views/popup_manager.dart';
import 'package:mamba/settings/data/settings_repository.dart';
import 'package:mamba/snackbar/cubit/snackbar_cubit.dart';
import 'package:mamba/snackbar/views/snackbar_manager.dart';
import 'package:mamba/notifications/Unread/cubit/UnreadNotChatsCubit.dart';
import 'package:mamba/stripe/bloc/stripe_connect_bloc/stripe_connect_cubit.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:mamba/user/data/user_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class App extends StatelessWidget {
  // App Constructor
  App({super.key});

  // Define Main Data Repositories
  final AuthRepository authRepository = AuthRepository();
  final UserRepository userRepository = UserRepository();
  final BrandRepository brandRepository = BrandRepository();
  // Define Main Helper Repositories
  final AnalyticsRepository analyticsRepository = AnalyticsRepository(
    isRelease: flavor != Flavor.development || flavor != Flavor.staging,
  );
  final SettingsRepository settingsRepository = SettingsRepository();

  @override
  Widget build(BuildContext context) {
    // Define Main Blocs
    final userBloc = UserBloc(
      userRepository: userRepository,
      settingsRepository: settingsRepository,
    );
    final brandBloc = BrandBloc(
      brandRepository: brandRepository,
      userBloc: userBloc,
    );
    final authBloc = AuthBloc(
      authRepository: authRepository,
      userBloc: userBloc,
      brandBloc: brandBloc,
    );
    final authCubit = SignInCubit(
      authBloc: authBloc,
    );
    final eventsBloc = EventsBloc(
      brandRepository: brandRepository,
      brandBloc: brandBloc,
    );

    final calendarBloc = CalendarBloc(
      userBloc: userBloc,
      brandBloc: brandBloc,
      eventsBloc: eventsBloc,
    );

    // Return Bloc Provider
    return MultiRepositoryProvider(
      providers: [
        // Main Data Repositories
        RepositoryProvider<AuthRepository>(
          create: (context) => authRepository,
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => userRepository,
        ),
        RepositoryProvider<BrandRepository>(
          create: (context) => brandRepository,
        ),
        // Main Helper Repositories
        RepositoryProvider<AnalyticsRepository>(
          create: (context) => analyticsRepository,
        ),
        RepositoryProvider<SettingsRepository>(
          create: (context) => settingsRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Main Aplication Blocs
          // Blocs that manage the main features of the application
          BlocProvider<AuthBloc>(
            create: (_) => authBloc,
          ),
          BlocProvider<SignInCubit>(
            create: (_) => authCubit,
          ),
          BlocProvider<UserBloc>(
            create: (_) => userBloc,
          ),
          BlocProvider<BrandBloc>(
            create: (_) => brandBloc,
          ),
          BlocProvider<EventsBloc>(
            create: (_) => eventsBloc,
          ),
          BlocProvider<CalendarBloc>(
            create: (_) => calendarBloc,
          ),

          // Top Level Helper Blocs
          // Blocs that need to be top-level to manage features throught the app
          BlocProvider<HomeManager>(
            create: (context) => HomeManager(),
          ),
          BlocProvider<ThemeManager>(
            create: (context) => ThemeManager(),
          ),
          BlocProvider<LanguageManager>(
            create: (context) => LanguageManager(
              settingsRepository: settingsRepository,
            ),
          ),
          BlocProvider<PopupsCubit>(
            create: (context) => PopupsCubit(
              settingsRepository: settingsRepository,
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
            create: (context) => UnreadNotChatsCubit(userBloc),
            lazy: false,
          ),
          BlocProvider<BrandSuscriptionCubit>(
            create: (context) => BrandSuscriptionCubit(brandBloc),
            lazy: false,
          ),
          BlocProvider(
            create: (_) => StripeConnectCubit(),
            lazy: false,
          ),
        ],
        child: const AppView(),
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
            //debugShowCheckedModeBanner: flavor == Flavor.development,
            debugShowCheckedModeBanner: false,
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
                navigatorKey: AppRouter.navigatorKey,
                child: SnackbarManager(
                  navigatorKey: AppRouter.navigatorKey,
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
