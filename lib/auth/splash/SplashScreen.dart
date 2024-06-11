import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/app/router/custom_transitions.dart';
import 'package:mamba/auth/bloc/auth_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/views/login.dart';
import 'package:mamba/data/DataService/Library/LibraryDataService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/auth/splash/SplashScreenView.dart';
import 'package:mamba/home/views/home.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = '/loading';
  static GoRoute route = GoRoute(
    name: routeName,
    path: '/loading',
    pageBuilder: (BuildContext context, GoRouterState state) =>
        CustomTransitions.instance.customTransitionPage(
      state: state,
      child: const SplashScreen(),
    ),
  );

  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Data Base Access
  final _libraryDataService = LibraryDataService();

  static const delayedRedirectionTime = Duration(milliseconds: 300);

  @override
  initState() {
    super.initState();
    initColorsList();
  }

  Future<void> initColorsList() async {
    currentColors = await _libraryDataService.getColors();
    currentDegradates = await _libraryDataService.getDegradates();
  }

  @override
  Widget build(BuildContext context) {
    context.read<AuthCubit>().checkAndGetUserDetails(context);
    return BlocListener<AuthBloc, AuthStateS>(
        listener: (context, state) {
          switch (state.status) {
            case AuthStatus.authenticated:              
              context.goNamed(HomePage.routeName);
              break;
            case AuthStatus.unauthenticated:
              context.goNamed(Login.routeName);
              break;
            case AuthStatus.unknown:
              break;
          }
        },
        child: Scaffold(
          appBar: null,
          body: SplashScreenView(
            isMaintenance: false,
            //isMaintenance: state is AuthMaintenance ? true : false,
          ),
        )

        /*BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthNotLoged) {
            context.goNamed(Login.routeName);
          }
          if (state is AuthAdmin) {
            context.goNamed(Admin.routeName);
          }
          if (state is AuthUserBrand || state is AuthUserNoBrand) {
            context.goNamed(HomePage.routeName);
          }
          if (state is AuthNewUser) {
            context.goNamed(OnboardingScreen.routeName);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: null,
            body: SplashScreenView(
              isMaintenance: state is AuthMaintenance ? true : false,
            ),
          );
        },
      ),*/
        );
  }
}
