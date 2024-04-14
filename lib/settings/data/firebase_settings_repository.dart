import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mamba/popups/models/html_popup.dart';

import 'package:package_info_plus/package_info_plus.dart';

//Singleton
class FirebaseSettingsRepository {
  static final FirebaseSettingsRepository _instance =
      FirebaseSettingsRepository._internal();

  factory FirebaseSettingsRepository() => _instance;
  FirebaseSettingsRepository._internal();

  static final _settingsCollection =
      FirebaseFirestore.instance.collection('Settings');

  Future<List<bool>> checkAppVersion() async {
    // Get Current Build Number
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final int buildNumber = int.parse(packageInfo.buildNumber);
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

  Future<int> getLatestWhatsNewBuildNumber() async {
    // Get Lastest Product Updates Build Number Available from Settings Collection
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _settingsCollection.doc("ProductUpdates").get();
    int productUpdatesBuildNumber =
        documentSnapshot.get("productUpdatesBuildNumberPro");
    // Return 
    return productUpdatesBuildNumber;
  }

  Future<HTMLPopup> getProductUpdatesHTML() async {
    // Get Product Updates HTML
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _settingsCollection.doc("ProductUpdates").get();
    String emailHTML = documentSnapshot.get("emailContentPro");
    String emailBackground = documentSnapshot.get("background");
    // Auxiliar Function
    Color hexStringToColor(String hexColor) {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      return Color(int.parse(hexColor, radix: 16));
    }

    // Turn into color
    Color backgroundColor = hexStringToColor(emailBackground);
    // Return
    return HTMLPopup(
      htmlContent: emailHTML,
      htmlBackground: backgroundColor,
    );
  }
}
