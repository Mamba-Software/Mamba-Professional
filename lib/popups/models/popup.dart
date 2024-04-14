import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mamba/popups/models/popup_type.dart';

class Popup extends Equatable {
  final PopupType type;
  final String? title;
  final String? message;
  final String? htmlContent;
  final Color? htmlBackground;
  final bool? forceAppUpdate;
  final Widget? widget;

  const Popup({
    required this.type,
    this.title,
    this.message,
    this.htmlContent,
    this.htmlBackground,
    this.forceAppUpdate,
    this.widget,
  });

  @override
  List<Object?> get props => [type, title, message, htmlContent, htmlBackground, forceAppUpdate, widget];
}
