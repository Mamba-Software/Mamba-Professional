import 'package:mamba/popups/models/html_popup.dart';
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

  // Check Whats New Popup
  Future<bool> checkIfWhatsNewPopup() async {
    try {
      // Check online product updates available version
      int onlineProductUpdates = await _firebaseRepo.getLatestWhatsNewBuildNumber();
      // Check local product updates version
      int localProductUpdates = await _hiveRepo.getLocalWhatsNewBuildNumber();
      // If Online > Local show WhatsNew Popup
      if (onlineProductUpdates > localProductUpdates) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Setter Whats New Build Number
  Future<void> setLocalWhatsNewBuildNumber() async {
    return await _hiveRepo.setLocalWhatsNewBuildNumber();
  }

  // Get Product Update HTML
  Future<HTMLPopup> getProductUpdatesHTML() async {
    return _firebaseRepo.getProductUpdatesHTML();
  }
}
