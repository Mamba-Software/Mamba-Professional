import 'package:mamba/settings/data/settings_repository.dart';

//Singleton
class HiveSettingsRepository implements SettingsRepository {
  factory HiveSettingsRepository() => _instance;
  HiveSettingsRepository._internal();

  static final HiveSettingsRepository _instance = HiveSettingsRepository._internal();

  @override
  Future<List<bool>> checkAppVersion() async {
    List<bool> result = [false, false];
      return result;
  }
}
