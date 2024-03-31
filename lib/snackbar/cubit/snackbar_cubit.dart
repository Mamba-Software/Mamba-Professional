import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/snackbar/cubit/snackbar_state.dart';
import 'package:mamba/snackbar/models/custom_snackbar.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';

class SnackbarCubit extends Cubit<SnackbarState> with PlatformMixin {
  SnackbarCubit() : super(const SnackbarInitial());

  // Handle Popup Queue
  void enqueueSnackbarAction(CustomSnackbar customSnackbar) {
    final currentState = state;
    List<CustomSnackbar> newQueue = [];
    if (currentState is SnackbarQueueFull) {
      newQueue = List.from(currentState.queue)..add(customSnackbar);
    } else {
      newQueue.add(customSnackbar);
    }
    emit(SnackbarQueueFull(newQueue));
  }

  // Process Next Popup in Queue
  void processNextAction() {
    final currentState = state;
    if (currentState is SnackbarQueueFull && currentState.queue.isNotEmpty) {
      List<CustomSnackbar> newQueue = List.from(currentState.queue)
        ..removeAt(0);
      if (newQueue.isEmpty) {
        emit(const SnackbarInitial());
      } else {
        emit(SnackbarQueueFull(newQueue));
      }
    }
  }

  void createSnackbar(
    SnackbarType type,
    String message, [
    String? title,
    bool? hasAction,
    String? actionText,
    Duration? duration,
  ]) {
    enqueueSnackbarAction(CustomSnackbar(
      type: type,
      message: message,
      duration: duration,
      title: title,
      hasAction: hasAction,
    ));
  }
}
