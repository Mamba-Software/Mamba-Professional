import 'package:flutter/material.dart';

// Idiomas Class, encapsulates all Locales / Languages that we work with in MambaClient.
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