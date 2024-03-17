import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/app/bootstrap.dart';
import 'package:mamba_castelldefels/app/firebase/firebase_options_staging.dart';

Future<void> main() async {
  // Initialize App
  WidgetsFlutterBinding.ensureInitialized();
  // Set Global Flavor
  currentFlavor = Flavor.staging;
  // Firebase Crashlytics
  Bootstrap(
    firebaseOptions: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
  );
}
