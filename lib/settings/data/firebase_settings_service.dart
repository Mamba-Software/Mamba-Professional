import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

//Singleton
class FirebaseSettingsService {
  static final _settingsCollection =
      FirebaseFirestore.instance.collection('Settings');

  Future<List<bool>> checkAppVersion() async {
    // Get Current Build Number
    final int buildNumber = int.parse("25"); //TODO DELTE
    // Get Minimum and Max Version from Settings Collection
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _settingsCollection.doc("MinimumAppVersion").get();
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

  Future<String> getProductUpdatesHTML() async {
    // Get Product Updates HTML
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _settingsCollection.doc("ProductUpdates").get();
    String emailHTML = documentSnapshot.get("emailContentPro");
    return emailHTML;
  }

  Future<bool> checkIfIsMaintenance() async {
    // Get Minimum and Max Version from Settings Collection
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _settingsCollection.doc("MinimumAppVersion").get();
    bool isMaintenance = documentSnapshot.get("isMaintenance");
    return isMaintenance;
  }

}
