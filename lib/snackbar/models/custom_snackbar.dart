import 'package:equatable/equatable.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';

class CustomSnackbar extends Equatable {
  final SnackbarType type;
  final String message;  
  final String? title;  
  final bool? hasAction;
  final Duration? duration;


  const CustomSnackbar({
    required this.type,
    required this.message,    
    this.title,    
    this.hasAction,
    this.duration,
  });

  @override
  List<Object?> get props =>
      [type, title, message, hasAction, duration];
}
