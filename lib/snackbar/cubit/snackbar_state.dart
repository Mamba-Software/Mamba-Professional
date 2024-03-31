import 'package:equatable/equatable.dart';
import 'package:mamba/snackbar/models/custom_snackbar.dart';

abstract class SnackbarState extends Equatable {
  const SnackbarState();
  
  @override
  List<Object?> get props => [];
}

// State indicating no popups are currently active or queued
class SnackbarInitial extends SnackbarState {
  const SnackbarInitial();
}

// State for managing a queue of PopupActions
class SnackbarQueueFull extends SnackbarState {
  final List<CustomSnackbar> queue;

  const SnackbarQueueFull(this.queue);

  @override
  List<Object?> get props => [queue];
}
