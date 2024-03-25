import 'package:hive/hive.dart';

//Singleton
class HiveSettingsRepository {
  static final HiveSettingsRepository _instance =
      HiveSettingsRepository._internal();

  factory HiveSettingsRepository() => _instance;
  HiveSettingsRepository._internal();

  final String _settingsBoxName = 'settings';

  Future<void> setWhatsNewBoolean(bool whatsNew) async {
    // Check if the box is already open
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      // Open the box if not already open
      await Hive.openBox(_settingsBoxName);
    }
    var box = Hive.box(_settingsBoxName);
    await box.put('whatsNew', whatsNew);
  }

  Future<bool> getWhatsNewBoolean() async {
    try {
      var box = await Hive.openBox(_settingsBoxName);
      return box.get('whatsNew') ?? false;
    } catch (e) {
      return false;
    }
  }
}
