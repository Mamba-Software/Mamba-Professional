import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/initial_popups/models/initial_popup_actions.dart';
import 'initial_popups_state.dart';

class InitialPopupsCubit extends Cubit<InitialPopupState> {
  InitialPopupsCubit() : super(const InitialPopupInitial());

  // Method to check for and trigger the "What's New" popup
  void checkWhatsNew() {
    try {
      emit(const InitialPopupLoading());

      // Your logic to determine if "What's New" should be displayed
      // For example, this could involve checking the app version stored locally
      // against the current version and seeing if there are new features.

      // Let's assume we determine it's time to show the "What's New" popup
      // You would fetch or define the necessary details for the popup
      final title = "What's New in Our App!";
      final message = "Check out the new features...";
      final actions = [PopupAction.dismiss, PopupAction.learnMore]; // Define your PopupAction enum or class

      // Emitting the loaded state with details for the "What's New" popup
      emit(WhatsNewPopupLoaded(title: title, message: message, actions: actions, newFeaturesSummary: "Summary of new features"));

    } catch (error) {
      emit(InitialPopupError("Failed to load popups"));
    }
  }

  // You can add similar methods for other pop-ups like rate app, give feedback, etc.
}
