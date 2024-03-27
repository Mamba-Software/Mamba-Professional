import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/l10n/l10n.dart';
import 'package:mamba/settings/data/settings_repository.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  final SettingsRepository settingsRepository;

  LanguageCubit({required this.settingsRepository})
      : super(LanguageState(AppLocalizations.supportedLocales.first));

  Locale get currentLocale => state.locale;

  void initialLocale() {
    emit(LanguageState(AppLocalizations.supportedLocales.first));
  }

  void setLocale(Locale locale) {
    if (AppLocalizations.supportedLocales.contains(locale)) {
      emit(LanguageState(locale));
    }
  }
}
