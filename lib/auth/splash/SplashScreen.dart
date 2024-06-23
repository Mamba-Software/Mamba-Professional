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

  Future<void> initColorsList() async {
    currentColors = await _libraryDataService.getColors();
    currentDegradates = await _libraryDataService.getDegradates();
  }

  @override
  Widget build(BuildContext context) {
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

    return BlocListener<AuthBloc, AuthStateS>(
        listener: (context, state) {
          switch (state.status) {
            case AuthStatus.authenticated:              
              userAutenticatedRedirection(
                context: context,
                userId: state.user.id,
              );
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

  Future<void> userAutenticatedRedirection({
    required BuildContext context,
    required String userId,
  }) async {
    final hasToCompleteProfile =
        await RepositoryProvider.of<UserRepository>(context)
            .hasToCompleteProfile(uid: userId);
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
