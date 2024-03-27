import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/l10n/l10n.dart';
import 'package:mamba/settings/data/settings_repository.dart';

class Language extends Equatable {
  final Locale locale;
  const Language(this.locale);
  @override
  List<Object?> get props => [locale];
}

class LanguageManager extends Cubit<Language> {
  final SettingsRepository settingsRepository;

  LanguageManager({required this.settingsRepository}) : super(initialLocale());

  Locale get currentLocale => state.locale;
  String get currentLocaleTag => state.locale.toLanguageTag();

  static Language initialLocale() {
    return Language(
      AppLocalizations.supportedLocales.firstWhere(
        (element) => element.toLanguageTag() == standardLanguage,
      ),
    );
  }

  void setLocale(Locale locale) {
    if (AppLocalizations.supportedLocales.contains(locale)) {
      emit(Language(locale));
    }
  }
}
