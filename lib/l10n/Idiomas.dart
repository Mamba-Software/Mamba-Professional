import 'package:flutter/material.dart';
import 'package:mamba/l10n/l10n.dart';

// Idiomas Class, encapsulates all Locales / Languages that we work with in Mamba.
class Idiomas {
  static final all = [
    const Locale('es', ''),
    const Locale('ca', ''),
  ];

  // Return Locale from Language Code
  static Locale getLocaleFromString(String localeCode){
    for(var i=0; i<all.length; i++){
      if(all[i].languageCode == localeCode) return all[i];
    }
    return all[0];
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}