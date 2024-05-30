import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/settings/data/settings_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageState extends Equatable {
  final Locale locale;
  const LanguageState(this.locale);
  @override
  List<Object?> get props => [locale];
}

class LanguageManager extends Cubit<LanguageState> {
  final SettingsRepository settingsRepository;

  LanguageManager({required this.settingsRepository}) : super(initialLocale());

  Locale get currentLocale => state.locale;
  String get currentLocaleTag => state.locale.toLanguageTag();

  static LanguageState initialLocale() {
    return LanguageState(
      AppLocalizations.supportedLocales.firstWhere(
        (element) => element.toLanguageTag() == standardLanguage,
      ),
    );
  }

  void setLocale(Locale locale) {
    if (AppLocalizations.supportedLocales.contains(locale)) {
      emit(LanguageState(locale));
    }
  }
}
