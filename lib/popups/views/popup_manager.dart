import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/popups/cubit/popups_cubit.dart';
import 'package:mamba/popups/cubit/popups_state.dart';
import 'package:mamba/popups/models/inital_popup_type.dart';
import 'package:mamba/popups/widgets/initial_popups/html_popup.dart';
import 'package:mamba/popups/widgets/initial_popups/update_app_popup.dart';
import 'package:store_redirect/store_redirect.dart';

class PopupManager extends StatelessWidget {  
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  
  const PopupManager({super.key, required this.child, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PopupsCubit, PopupState>(
      listener: (context, popupState) {
        if (navigatorKey.currentState?.overlay?.context != null) {
          context = navigatorKey.currentState!.overlay!.context;
          print("PopupState received: $popupState"); // Debugging
          if (popupState is InitialPopupLoaded) {
            switch (popupState.type) {
              case InitalPopupType.app_update:
                UpdateAppPopup.show(
                  context: context,
                  isMandatory: popupState.forceAppUpdate!,
                  onTap: () {
                    StoreRedirect.redirect(
                      androidAppId: "com.mamba.mambaprofessionalapp",
                      iOSAppId: "1642701679",
                    );
                  },
                );                
                break;
              case InitalPopupType.whats_new:
                HTMLPopup.show(
                  context: context,
                  html: popupState.html!,
                );
                break;
              default:
                break;
            }
          }
        }
      },
      child: child,
    );
  }
}
