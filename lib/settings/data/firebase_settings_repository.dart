import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba/settings/data/settings_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

//Singleton
class FirebaseSettingsRepository implements SettingsRepository {
  factory FirebaseSettingsRepository() => _instance;
  FirebaseSettingsRepository._internal();

  static final FirebaseSettingsRepository _instance = FirebaseSettingsRepository._internal();

  static final _settingsCollection = FirebaseFirestore.instance.collection('Settings');  

  @override
  Future<List<bool>> checkAppVersion() async {
    // Get Current Build Number
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final int buildNumber = int.parse(packageInfo.buildNumber);
    // Get Minimum and Max Version from Settings Collection
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await _settingsCollection.doc("MinimumAppVersion").get();
    int minBuildNumPro = documentSnapshot.get("minBuildNumPro");
    int maxBuildNumPro = documentSnapshot.get("maxBuildNumPro");
    if (buildNumber < minBuildNumPro) {
      // Can Update && isMandatory
      print("Can Update == TRUE && isMandatory == TRUE");
      List<bool> result = [true, true];
      return result;
    } else if (buildNumber < maxBuildNumPro) {
      // Can Update && isMandatory
      print("Can Update == TRUE && isMandatory == FALSE");
      List<bool> result = [true, false];
      return result;
    } else {
      print("Can Update == FALSE && isMandatory == FALSE");
      // Can Update && isMandatory
      List<bool> result = [false, false];
      return result;
    }
  }
  
  @override
  bool getWhatsNewBoolean() {
    // TODO: implement getWhatsNewBoolean
    throw UnimplementedError();
  }
  
  @override
  void setWhatsNewBoolean(bool whatsNew) {
    // TODO: implement setWhatsNewBoolean
  }

  
}
