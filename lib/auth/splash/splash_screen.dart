import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/app/router/custom_transitions.dart';
import 'package:mamba/auth/bloc/auth_bloc.dart';
import 'package:mamba/auth/sign_in/views/login.dart';
import 'package:mamba/data/DataService/Library/LibraryDataService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/auth/splash/splash_screen_view.dart';
import 'package:mamba/home/views/home.dart';
import 'package:mamba/user/data/user_repository.dart';
import 'package:mamba/brand/data/brand_repository.dart';

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

  static const delayedRedirectionTime = Duration(milliseconds: 3000);

  @override
  initState() {
    super.initState();
    initColorsList();
  }

  /* TO DO: Migrate to another part*/
  Future<void> initColorsList() async {
    currentColors = await _libraryDataService.getColors();
    currentDegradates = await _libraryDataService.getDegradates();
  }

  @override
  Widget build(BuildContext context) {
    /*
    context.read<AuthCubit>().checkAndGetUserDetails(context);
    final authBloc = context.read<AuthBloc>();

    // Verifica el estado actual inmediatamente al construir el widget
    final currentState = authBloc.state;
    if (currentState.status == AuthStatus.authenticated) {
      userAutenticatedRedirection(
        context: context,
        userId: currentState.user.id,
      );
    }
    */

    return BlocListener<AuthBloc, AuthStateS>(
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            print(AuthStatus.authenticated);
            /*
            userAutenticatedRedirection(
              context: context,
              userId: state.user.id,
            );
            */
            break;
          case AuthStatus.unauthenticated:
            print(AuthStatus.unauthenticated);
            /*
            userUnautenticatedRedirection(
              context: context,
            );
            */
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
      ),
    );
  }

  Future<void> userUnautenticatedRedirection({
    required BuildContext context,
  }) async {
    context.goNamed(Login.routeName);
  }

  Future<void> userAutenticatedRedirection({
    required BuildContext context,
    required String userId,
  }) async {
    final hasToCompleteProfile =
        await RepositoryProvider.of<UserRepository>(context)
            .hasToCompleteProfile(userId: userId);
    if (hasToCompleteProfile) {
      final hasBrand = await RepositoryProvider.of<BrandRepository>(context)
          .hasBrand(userId: userId);
      if (hasBrand) {
        Future.delayed(delayedRedirectionTime, () {
          context.goNamed(HomePage.routeName);
          // Assuming you are using go_router and context.goNamed is available
          /* context.goNamed(OnboardingScreen
              .routeName);*/ // Replace 'onboarding' with your route name
        });
      } else {
        Future.delayed(delayedRedirectionTime, () {
          // Assuming you are using go_router and context.goNamed is available
          context.goNamed(
              HomePage.routeName); // Replace 'onboarding' with your route name
        });
      }
    } else {
      Future.delayed(delayedRedirectionTime, () {
        // Assuming you are using go_router and context.goNamed is available
        context.goNamed(
            HomePage.routeName); // Replace 'onboarding' with your route name
      });
    }
  }
}
