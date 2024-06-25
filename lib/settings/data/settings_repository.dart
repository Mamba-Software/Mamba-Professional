import 'package:mamba/settings/data/firebase_settings_service.dart';
import 'package:mamba/settings/data/hive_settings_service.dart';

class SettingsRepository {
  final FirebaseSettingsService _firebaseService;
  final HiveSettingsService _hiveService;

  //SettingsRepository(this._firebaseRepo, this._hiveRepo);

  SettingsRepository({
    FirebaseSettingsService? firebaseService,
    HiveSettingsService? hiveService,
  })  : _firebaseService = firebaseService ?? FirebaseSettingsService(),
        _hiveService = hiveService ?? HiveSettingsService();

  // Check App Version
  Future<List<bool>> checkAppVersion() async {
    return _firebaseService.checkAppVersion();
  }

  // Setter/Getter Whats New Boolean
  Future<void> setWhatsNewStatus(bool whatsNew) async {}

  Future<bool> getWhatsNewStatus() async {
    // To Do: Remove This
    return true;
    return await _hiveService.getWhatsNewStatus();
  }

  // Get Product Update HTML
  Future<String> getProductUpdatesHTML() async {
    return _firebaseService.getProductUpdatesHTML();
  }

  // Get Product Update HTML
  Future<bool> checkIfIsMaintenance() async {
    return _firebaseService.checkIfIsMaintenance();
  }


}
