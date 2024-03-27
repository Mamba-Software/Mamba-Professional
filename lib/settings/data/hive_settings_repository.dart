import 'package:hive/hive.dart';

//Singleton
class HiveSettingsRepository {
  static final HiveSettingsRepository _instance =
      HiveSettingsRepository._internal();

  factory HiveSettingsRepository() => _instance;
  HiveSettingsRepository._internal();

  final String _settingsBoxName = 'settings';

  Future<void> setWhatsNewStatus(bool whatsNew) async {
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      await Hive.openBox(_settingsBoxName);
    }
    var box = Hive.box(_settingsBoxName);
    await box.put('whatsNew', whatsNew);
  }

  Future<bool> getWhatsNewStatus() async {
    try {
      var box = await Hive.openBox(_settingsBoxName);
      return box.get('whatsNew') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getUserLanguage() async {
    try {
      if (Hive.isBoxOpen(_settingsBoxName)) {
        var box = await Hive.openBox(_settingsBoxName);
        return box.get('language');
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
