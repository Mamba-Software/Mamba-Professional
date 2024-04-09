import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';

//Singleton
class HiveSettingsRepository {
  static final HiveSettingsRepository _instance =
      HiveSettingsRepository._internal();

  factory HiveSettingsRepository() => _instance;
  HiveSettingsRepository._internal();

  final String _settingsBoxName = 'settings';

  Future<void> setLocalWhatsNewBuildNumber() async {
    // Get Current Build Number
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final int buildNumber = int.parse(packageInfo.buildNumber);
    // Check if the box is already open
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      // Open the box if not already open
      await Hive.openBox(_settingsBoxName);
    }
    // Returns an Opened Box
    var box = Hive.box(_settingsBoxName);
    // Put Latest Build Number
    await box.put('whatsNewVersion', buildNumber);
  }

  Future<int> getLocalWhatsNewBuildNumber() async {
    try {
      // Check if the box is already open
      if (!Hive.isBoxOpen(_settingsBoxName)) {
        // Open the box if not already open
        await Hive.openBox(_settingsBoxName);
      }
      // Returns an Opened Box
      var box = Hive.box(_settingsBoxName);
      // Get Latest Build Number For which they saw the Product Updates
      int? latestBuildNumber = box.get('whatsNewVersion');
      // No WhatsNew version stored locally
      if (latestBuildNumber == null) {
          throw Exception('No WhatsNew version stored locally');
      }
      // Return
      return latestBuildNumber;
    } catch (e) {
      return 0;
    }
  }
}
