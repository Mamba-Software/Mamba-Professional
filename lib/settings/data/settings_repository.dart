import 'package:mamba/settings/data/firebase_settings_repository.dart';
import 'package:mamba/settings/data/hive_settings_repository.dart';

abstract class SettingsRepository {  
  Future<List<bool>> checkAppVersion();  
}

class SettingsRepositoryManager implements SettingsRepository {
  final FirebaseSettingsRepository _firebaseRepo;
  final HiveSettingsRepository _hiveRepo;
  SettingsRepositoryManager(this._firebaseRepo, this._hiveRepo);

  @override
  Future<List<bool>> checkAppVersion() async {
    return _firebaseRepo.checkAppVersion();
  }

  /* 
  // Example method that uses Hive
  Future<dynamic> getSettingsFromCache() {
    return _hiveRepo.checkAppVersion();
  }

  // Method that might use both
  Future<dynamic> getSettings() async {
    try {
      // First, try to get settings from Firebase
      return await _firebaseRepo.checkAppVersion();
    } catch (e) {
      // If it fails, fall back to Hive
      return _hiveRepo.checkAppVersion();
    }
  }  
  */
}