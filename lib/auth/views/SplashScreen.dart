import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/views/Login.dart';
import 'package:mamba/auth/views/OnboardingScreen.dart';
import 'package:mamba/data/DataService/Library/LibraryDataService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LoadingViews/SplashScreenView.dart';
import 'package:mamba/admin/Admin.dart';
import 'package:mamba/home/views/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// Splash Screen, the first one that is being shown.
// This screen has 3 possible outcomes.
// A) User NOT Logged In => LogInPage()
// B) User IS Logged In ...
//      1) isFirstTime? YES => FirstTimeWrapper()
//      2) isFirstTime? NO => HomePage()
//
// While getting data from Database it is showing a Loading Widget.
class _SplashScreenState extends State<SplashScreen> {
  // Data Base Access
  final _libraryDataService = LibraryDataService();

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
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthNotLoged) {
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<void>(
              builder: (context) => const Login(),
              settings: const RouteSettings(name: 'Login'),
            ),
            (_) => false,
          );
        }
        if (state is AuthAdmin) {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute<void>(
                builder: (context) => const Admin(),
                settings: const RouteSettings(name: 'Admin'),
              ));
        }
        if (state is AuthUserBrand || state is AuthUserNoBrand) {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute<void>(
                builder: (context) => HomePage(),
                settings: const RouteSettings(name: 'Mamba'),
              ));
        }
        if (state is AuthNewUser) {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute<void>(
                builder: (context) => const OnboardingScreen(),
                settings: const RouteSettings(name: 'OnboardingScreen'),
              ));
        }
      },
      builder: (context, state) {
        return Scaffold(
            appBar: null,
            body: SplashScreenView(
              isMaintenance: state is AuthMaintenance ? true : false,
            ));
      },
    );
  }
}
