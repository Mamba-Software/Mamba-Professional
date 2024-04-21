import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/auth/bloc/auth_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/views/login.dart';
import 'package:mamba/user/onboarding/OnboardingScreen.dart';
import 'package:mamba/data/DataService/Library/LibraryDataService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/auth/splash/SplashScreenView.dart';
import 'package:mamba/admin/Admin.dart';
import 'package:mamba/home/views/home.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = '/splash';
  static GoRoute route = GoRoute(
    name: routeName,
    path: '/splash',
    builder: (BuildContext context, GoRouterState state) =>
        const SplashScreen(),
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
            context.goNamed(Login.routeName);
            /*if (checkIfAppIsActive(context)) {
              userAutenticatedRedirection(context: context, userId: state.user.id);
            }*/
            break;
          case AuthStatus.unauthenticated:
            context.goNamed(Login.routeName);
            break;
          case AuthStatus.unknown:
            break;
        }
      },
      child: BlocConsumer<AuthCubit, AuthState>(
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
      ),
    );
  }
}
