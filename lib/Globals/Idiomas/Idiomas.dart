import 'package:flutter/material.dart';

class Idiomas {
  static final all = [
    const Locale('es', ''),
    const Locale('ca', ''),
  ];

  static String getFlag(String code) {
    switch (code) {
      case 'ca':
        return '🇦🇪';
      case 'en':
      default:
        return '🇪🇸';
    }
  }

  static Locale getLocaleFromString(String localeCode){
    for(var i=0; i<all.length; i++){
      if(all[i].languageCode == localeCode) return all[i];
    }
    // Retorna el ESP per defecte
    return all[0];
  }
}