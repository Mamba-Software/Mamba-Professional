import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/popups/models/popup.dart';
import 'package:mamba/popups/models/popup_type.dart';
import 'package:mamba/settings/data/settings_repository.dart';
import 'popups_state.dart';

class PopupsCubit extends Cubit<PopupState> with PlatformMixin {
  final SettingsRepository settingsRepository;

  PopupsCubit({required this.settingsRepository}) : super(const PopupInitial());

  // Handle Popup Queue
  void enqueuePopupAction(Popup popup) {
    final currentState = state;
    List<Popup> newQueue = [];
    if (currentState is PopupQueueFull) {
      newQueue = List.from(currentState.queue)..add(popup);
    } else {
      newQueue.add(popup);
    }
    emit(PopupQueueFull(newQueue));
  }

  // Process Next Popup in Queue
  void processNextPopup() {
    final currentState = state;
    if (currentState is PopupQueueFull && currentState.queue.isNotEmpty) {
      List<Popup> newQueue = List.from(currentState.queue)..removeAt(0);
      if (newQueue.isEmpty) {
        emit(const PopupInitial());
      } else {
        emit(PopupQueueFull(newQueue));
      }
    }
  }

  // Popup App Update
  Future<void> checkIfAppUpdate([bool whatsNew = true]) async {
    List<bool> result = await settingsRepository.checkAppVersion();
    if (result[0]) {
      enqueuePopupAction(
        Popup(
          type: PopupType.app_update,
          forceAppUpdate: result[1],
        ),
      );
    } else {
      if (whatsNew == true) {
        checkIfWhatsNew();
      }
    }
  }

  // Popup WhatsNew
  Future<void> checkIfWhatsNew() async {
    await Future.delayed(const Duration(seconds: 2));
    bool whatsNew = await settingsRepository.getWhatsNewBool();
    if (whatsNew == false) {
      String emailHTML = await settingsRepository.getProductUpdatesHTML();
      enqueuePopupAction(
        Popup(
          type: PopupType.whats_new,
          htmlContent: emailHTML,
        ),
      );
    }
  }

  // Popup WhatsNew
  void closeWhatsNew() {
    settingsRepository.setWhatsNewBool(true);
  }

  // In App Review Dialog
  Future<void> checkInAppReview() async {
    if (isAndroid || isIOS) {
      // TO DO: Do here some check to now show every single time.
      enqueuePopupAction(
        const Popup(
          type: PopupType.rate_app_dialog,
        ),
      );
    }
  }

  // Open Store Listing
  Future<void> inAppReviewDeclined() async {
    if (isAndroid || isIOS) {
      // TO DO: Guardar que ha dit que no.
    }
  }

  // In App Review Native
  Future<void> nativeInAppReview() async {
    if (isAndroid || isIOS) {
      final InAppReview inAppReview = InAppReview.instance;      
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      } else {
        checkInAppReview();
      }
    }
  }

  // Open Store Listing
  Future<void> openStoreListing() async {
    if (isAndroid || isIOS) {
      final InAppReview inAppReview = InAppReview.instance;
      inAppReview.openStoreListing();
    }
  }
}
