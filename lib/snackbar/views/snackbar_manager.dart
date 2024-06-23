import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/snackbar/cubit/snackbar_cubit.dart';
import 'package:mamba/snackbar/cubit/snackbar_state.dart';
import 'package:mamba/snackbar/models/custom_snackbar.dart';
import 'package:mamba/snackbar/widgets/snackbar_widget.dart';

class SnackbarManager extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const SnackbarManager(
      {super.key, required this.child, required this.navigatorKey});

  double getMaxWidth(BuildContext context) {
    if (context.isMobile) {
      return context.width * 0.9;
    } else if (context.isTablet) {
      return context.width * 0.77;
    } else {
      return context.width * 0.66;
    }
  }

  double getPadding(BuildContext context) {
    if (context.isMobile || context.isTablet ) {    
      return 8.0;
    } else {
      return 10;
    }
  }

  void _showSnackbar(
    BuildContext context,
    GlobalKey<NavigatorState> navigatorKey,
    CustomSnackbar snackbar, [
    VoidCallback? onAccept,
    Color? color,
    IconData? icon,
  ]) {
    // Use navigatorKey to obtain the OverlayState
    OverlayState? overlayState = navigatorKey.currentState?.overlay;
    // Check if we can find OverlayState
    if (overlayState == null) {
      print('Unable to find OverlayState.');
      return;
    }
    // Prepare the Overlay
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: context.isDesktop ? 50 : 30,
        width: context.width,
        child: CustomSnackbarView(          
          padding: getPadding(context),
          maxWidth: getMaxWidth(context),
          snackbar: snackbar,
          onAccept: onAccept,
          color: color,
          icon: icon,
        ),
      ),
    );
    // Insert
    overlayState.insert(overlayEntry);
    // Automatically dismiss the snackbar after a duration
    Future.delayed(Duration(seconds: snackbarDefaultDuration), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        context.read<SnackbarCubit>().processNextAction();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SnackbarCubit, SnackbarState>(
      listener: (context, snackbarState) {
        if (navigatorKey.currentState?.overlay?.context != null) {
          context = navigatorKey.currentState!.overlay!.context;
          if (snackbarState is SnackbarQueueFull &&
              snackbarState.queue.isNotEmpty) {
            CustomSnackbar snackbar = snackbarState.queue.first;
            _showSnackbar(
              context,
              navigatorKey,
              snackbar,
              snackbar.onAccept,
              snackbar.color,
              snackbar.icon,
            );
          }
        }
      },
      child: child,
    );
  }
}
