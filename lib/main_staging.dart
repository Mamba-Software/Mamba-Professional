import 'package:flutter/foundation.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/bootstrap.dart';
import 'package:mamba_castelldefels/Globals/FirebaseOptions/firebase_options_staging.dart';

Future<void> main() async {
  // Set Global Flavor
  currentFlavor = Flavor.staging;
  // Firebase Crashlytics
  Bootstrap(    
    firebaseOptions: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
  );
}
