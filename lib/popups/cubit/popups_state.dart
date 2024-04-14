import 'package:equatable/equatable.dart';
import 'package:mamba/popups/models/popup.dart';

abstract class PopupState extends Equatable {
  const PopupState();
  
  @override
  List<Object?> get props => [];
}

// State indicating no popups are currently active or queued
class PopupInitial extends PopupState {
  const PopupInitial();
}

// State for managing a queue of PopupActions
class PopupQueueFull extends PopupState {
  final List<Popup> queue;

  const PopupQueueFull(this.queue);

  @override
  List<Object?> get props => [queue];
}
