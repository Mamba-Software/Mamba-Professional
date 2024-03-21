import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class InitialPopupState extends Equatable {
  const InitialPopupState();

  @override
  List<Object?> get props => [];
}

class InitialPopupInitial extends InitialPopupState {
  const InitialPopupInitial();
}

class InitialPopupLoaded extends InitialPopupState {
  final String title;
  final String message;
  final Widget? widget;

  const InitialPopupLoaded({
    required this.title,
    required this.message,
    this.widget,    
  });

  @override
  List<Object?> get props => [title, message, widget];
}

class RateAppPopupLoaded extends InitialPopupState {
  const RateAppPopupLoaded();
}



