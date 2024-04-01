import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';

class CustomSnackbar extends Equatable {
  final SnackbarType type;
  final String message;        
  final VoidCallback? onAccept;
  final String? actionText;

  const CustomSnackbar({
    required this.type,
    required this.message,        
    this.onAccept,
    this.actionText,
  });

  @override
  List<Object?> get props =>
      [type, message, onAccept, actionText];
}
