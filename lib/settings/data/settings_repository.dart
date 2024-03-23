import 'package:mamba/settings/data/firebase_settings_repository.dart';
import 'package:mamba/settings/data/hive_settings_repository.dart';

abstract class SettingsRepository {  
  Future<List<bool>> checkAppVersion();  
  void setWhatsNewBoolean(bool whatsNew);  
  bool getWhatsNewBoolean();    
}

class SettingsRepositoryManager implements SettingsRepository {
  final FirebaseSettingsRepository _firebaseRepo;
  final HiveSettingsRepository _hiveRepo;
  
  SettingsRepositoryManager(this._firebaseRepo, this._hiveRepo);

  @override
  Future<List<bool>> checkAppVersion() async {
    return _firebaseRepo.checkAppVersion();
  }

  @override
   void setWhatsNewBoolean(bool whatsNew) {  
    return _hiveRepo.setWhatsNewBoolean(whatsNew);
  }

  @override
  bool getWhatsNewBoolean() {
    return _hiveRepo.getWhatsNewBoolean();
  }
}