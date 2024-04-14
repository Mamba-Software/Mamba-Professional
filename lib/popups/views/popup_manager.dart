import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/popups/cubit/popups_cubit.dart';
import 'package:mamba/popups/cubit/popups_state.dart';
import 'package:mamba/popups/models/popup_type.dart';
import 'package:mamba/popups/widgets/whats_new_popup.dart';
import 'package:mamba/popups/widgets/rate_app_popup.dart';
import 'package:mamba/popups/widgets/update_app_popup.dart';
import 'package:store_redirect/store_redirect.dart';

class PopupManager extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const PopupManager(
      {super.key, required this.child, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PopupsCubit, PopupState>(
      listener: (context, popupState) {
        if (navigatorKey.currentState?.overlay?.context != null) {
          context = navigatorKey.currentState!.overlay!.context;
          if (popupState is PopupQueueFull && popupState.queue.isNotEmpty) {
            final popup = popupState.queue.first;
            switch (popup.type) {
              case PopupType.app_update:
                UpdateAppPopup.show(
                  context: context,
                  isMandatory: popup.forceAppUpdate!,
                  onAcceptFunction: () {
                    StoreRedirect.redirect(
                      androidAppId: "com.mamba.mambaprofessionalapp",
                      iOSAppId: "1642701679",
                    );
                    context.read<PopupsCubit>().processNextPopup();
                  },
                );
                break;
              case PopupType.whats_new:
                WhatsNewPopup.show(
                  context: context,
                  html: popup.htmlContent!,
                  backgroundColor: popup.htmlBackground!, 
                  onAcceptFunction: () {                    
                    context.read<PopupsCubit>().closeWhatsNew();
                    context.read<PopupsCubit>().processNextPopup();
                  },
                );
                context.read<PopupsCubit>().processNextPopup();
                break;
              case PopupType.rate_app_dialog:
                RateAppPopup.show(
                  context: context,                  
                  onAcceptFunction: () {                    
                    context.read<PopupsCubit>().openStoreListing();
                    context.read<PopupsCubit>().processNextPopup();                    
                  },
                  onDeclineFunction: () {                    
                    context.read<PopupsCubit>().inAppReviewDeclined();
                    context.read<PopupsCubit>().processNextPopup();                    
                  },
                );
                break;
            }
          }
        }
      },
      child: child,
    );
  }
}
