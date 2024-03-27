import 'package:mamba/settings/data/firebase_settings_repository.dart';
import 'package:mamba/settings/data/hive_settings_repository.dart';

class SettingsRepository {
  final FirebaseSettingsRepository _firebaseRepo;
  final HiveSettingsRepository _hiveRepo;

  SettingsRepository(this._firebaseRepo, this._hiveRepo);

  // Check App Version
  Future<List<bool>> checkAppVersion() async {
    return _firebaseRepo.checkAppVersion();
  }

  // Setter/Getter Whats New Boolean
  Future<void> setWhatsNewStatus(bool whatsNew) async {
    return await _hiveRepo.setWhatsNewStatus(whatsNew);
  }

  Future<bool> getWhatsNewStatus() async {
    return await _hiveRepo.getWhatsNewStatus();
  }

  // Get Product Update HTML
  Future<String> getProductUpdatesHTML() async {
    return _firebaseRepo.getProductUpdatesHTML();
  }

}
