import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class HTMLPopup extends Equatable {
  final String htmlContent;
  final Color htmlBackground;

  const HTMLPopup({
    required this.htmlContent,
    required this.htmlBackground,
  });

  @override
  List<Object?> get props => [htmlContent, htmlBackground];
}
