import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';


class LanguageProvider extends ChangeNotifier {
  Locale? _idioma;

  Locale? get idioma => _idioma;

  void setLocale(Locale idioma) {
    if (!Idiomas.all.contains(idioma)) return;
    _idioma = idioma;
    notifyListeners();
  }

  void clearLocale() {
    _idioma = null;
    notifyListeners();
  }
}