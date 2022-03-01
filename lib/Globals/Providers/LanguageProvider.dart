import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';

// Provider for Language Change in our App.
class LanguageProvider extends ChangeNotifier {
  Locale? _idioma;

  Locale? get idioma => _idioma;

  // Sets the App´s Locale
  void setLocale(Locale idioma) {
    if (!Idiomas.all.contains(idioma)) return;
    _idioma = idioma;
    notifyListeners();
  }
  // Clears the App´s Language. The default one will be used.
  void clearLocale() {
    _idioma = null;
    notifyListeners();
  }
}