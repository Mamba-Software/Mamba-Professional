import 'package:hive/hive.dart';
import 'package:mamba/settings/data/settings_repository.dart';

//Singleton
class HiveSettingsRepository implements SettingsRepository {
  static final HiveSettingsRepository _instance =
      HiveSettingsRepository._internal();
  factory HiveSettingsRepository() => _instance;
  HiveSettingsRepository._internal();

  final String _settingsBoxName = 'settings';

  @override
  void setWhatsNewBoolean(bool whatsNew) async {
    var box = Hive.box(_settingsBoxName);
    box.put('whatsNew', whatsNew);
    
  }

  @override
  bool getWhatsNewBoolean() {
    var box = Hive.box(_settingsBoxName);
    return box.get('whatsNew');    
  }
  
  @override
  Future<List<bool>> checkAppVersion() {
    // TODO: implement checkAppVersion
    throw UnimplementedError();
  }
}
