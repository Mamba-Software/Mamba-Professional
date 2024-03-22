import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mamba/popups/models/inital_popup_type.dart';

abstract class PopupState extends Equatable {
  const PopupState();

  @override
  List<Object?> get props => [];
}

class PopupsInitial extends PopupState {
  const PopupsInitial();
}

class PopupLoaded extends PopupState {
  final String title;
  final String message;
  final Widget? widget;

  const PopupLoaded({
    required this.title,
    required this.message,
    this.widget,
  });

  @override
  List<Object?> get props => [title, message, widget];
}

class InitialPopupLoaded extends PopupState {
  final InitalPopupType type;
  final bool? forceAppUpdate;
  final String? html;

  const InitialPopupLoaded({
    required this.type,
    this.forceAppUpdate,
    this.html,
  });

  @override
  List<Object?> get props => [type, forceAppUpdate, html];
}

class RateAppPopupLoaded extends PopupState {
  const RateAppPopupLoaded();
}
