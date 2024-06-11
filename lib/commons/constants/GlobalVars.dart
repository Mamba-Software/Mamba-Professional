// This file contains all the Global Variabels used throgh the App.
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/data/LibraryModels/lColor.dart';
import 'package:mamba/data/LibraryModels/lDegradate.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/snackbar/cubit/snackbar_cubit.dart';
import 'package:mamba/snackbar/models/custom_snackbar.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';
import 'package:mamba/user/chat/ChatCore.dart';
import 'package:mamba/commons/widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:mamba/notifications/NotificationService/Notifications.dart';
import 'package:mamba/user/profile/Profile.dart';
import 'package:mamba/user/profile/views/Feedback/Help.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

List<lColor> currentColors = [];
List<lDegradate> currentDegradates =
    []; //0x00000000, 0xFFE53935, 0xFF43A047, 0xFF1E88E5, 0xFF8E24AA, 0xFFFB8C00, 0xFFFDD835

// User & Brand Global Variables
var currentUser = Usuario();
var currentBrand = Brand();
bool hasBrand = false;
bool brandIsActive = false;

//Stripe
bool stripeActivatedGlobal = false;

// Current User Location and TimeZone
Position? currentPosition;
String? currentAddress;
String? timeZoneName;

// Analytics Mix Panel
Mixpanel? mixpanel;

// Chat Things
bool isExecuted = false; // Initialize the flag as a member variable.
// Dynamic Links Path
var dynamicLinkBrandId;

//JMF 18042023 REVENUECAT
void setBrandActive() {
  // Se trata de revenueCat
  if (currentBrand.subscription != null) {
    if (currentBrand.subscription?['brandIsActive'] == true) {
      brandIsActive = true;
    } else {
      brandIsActive = false;
    }
  }
  // Se trata de una antigua suscripción
  else if (currentBrand.endDatePay != null) {
    if (DateTime.now().compareTo(currentBrand.endDatePay!.toDate()) < 0) {
      brandIsActive = true;
    } else {
      brandIsActive = false;
    }
  } else {
    brandIsActive = false;
  }
}

Future<void> navigateToPayWall(BuildContext context,
    [bool fromActiveSubs = false]) async {
  final topSnackBar = TopSnackBarDef();
  if (currentUser.id == currentBrand.adminID) {
    if (fromActiveSubs) {
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PayWall(
            brandId: currentBrand.id!,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), // Starts from below
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ).whenComplete(() {
        Navigator.pop(context);
      });
    } else {
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PayWall(
            brandId: currentBrand.id!,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), // Empieza desde abajo
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      );
    }
  } else {
    topSnackBar.showSnackBarTop(context, context.l10n.notSubNotAdmin, 5);
  }
}

// Navigate to Notifications Screen
void navigateToProfileScreen(BuildContext context) {
  //context.pushNamed(Profile.routeName);
  Navigator.push(
    context,
    CupertinoPageRoute<void>(
      builder: (context) => const Profile(),
    ),
  );
}

// Navigate to Notifications Screen
Future<void> navigateToNotificationsScreen(BuildContext context) async {
  if (kIsWeb) {
    CustomSnackbar snackbar = CustomSnackbar(
      type: SnackbarType.custom,
      message: context.l10n.mobileOnly,
      icon: Icons.smartphone,
      color: Colors.blue,
    );
    context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
  } else {
    Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => const Notifications(),
      ),
    );
  }
}

// Navigate to Notifications Screen
Future<void> navigateToChatScreen(BuildContext context) async {
  if (kIsWeb) {
    CustomSnackbar snackbar = CustomSnackbar(
      type: SnackbarType.custom,
      message: context.l10n.mobileOnly,
      icon: Icons.smartphone,
      color: Colors.blue,
    );
    context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
  } else {
    Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => const ChatCore(),
      ),
    );
  }
}

// Navigate to Feedback Screen
void navigateToMainFeedbackScreen(BuildContext context) {
  if (kIsWeb) {
    CustomSnackbar snackbar = CustomSnackbar(
      type: SnackbarType.custom,
      message: context.l10n.mobileOnly,
      icon: Icons.smartphone,
      color: Colors.blue,
    );
    context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
  } else {
    Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => const FeedBack(),
      ),
    );
  }
}
