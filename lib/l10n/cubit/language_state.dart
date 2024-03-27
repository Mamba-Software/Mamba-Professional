import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class LanguageState extends Equatable {
  final Locale locale;

  const LanguageState(this.locale);

  @override
  List<Object?> get props => [locale];
}
