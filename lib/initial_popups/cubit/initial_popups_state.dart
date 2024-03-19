import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/initial_popups/models/initial_popup_actions.dart';

abstract class InitialPopupState extends Equatable {
  const InitialPopupState();

  @override
  List<Object?> get props => [];
}

class InitialPopupInitial extends InitialPopupState {
  const InitialPopupInitial();
}

class InitialPopupLoading extends InitialPopupState {
  const InitialPopupLoading();

  @override
  List<Object?> get props => [];
}

// Represents a state where a specific type of popup should be shown.
// Additional properties specific to each popup can be added as needed.
class InitialPopupLoaded extends InitialPopupState {
  final String title;
  final String message;
  final List<PopupAction> actions; // Assuming PopupAction is a class or enum you define for possible actions in a popup

  const InitialPopupLoaded({
    required this.title,
    required this.message,
    required this.actions,
  });

  @override
  List<Object?> get props => [title, message, actions];
}

class InitialPopupError extends InitialPopupState {
  final String errorMessage;

  const InitialPopupError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// You could also extend InitialPopupLoaded for each specific popup if they need unique properties.
class WhatsNewPopupLoaded extends InitialPopupLoaded {
  final String newFeaturesSummary; // Unique property for "What's New"

  const WhatsNewPopupLoaded({
    required String title,
    required String message,
    required List<PopupAction> actions,
    required this.newFeaturesSummary,
  }) : super(title: title, message: message, actions: actions);

  @override
  List<Object?> get props => super.props..add(newFeaturesSummary);
}

class RateAppPopupLoaded extends InitialPopupLoaded {
  // Example of extending with unique properties or methods

  const RateAppPopupLoaded({
    required String title,
    required String message,
    required List<PopupAction> actions,
  }) : super(title: title, message: message, actions: actions);
}

// Define additional classes for GiveFeedbackPopupLoaded, InstallWidgetsPopupLoaded, etc., following the pattern above.

