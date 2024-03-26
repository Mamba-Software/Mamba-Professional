import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mamba/app/bootstrap.dart';
import 'package:mamba/app/firebase/firebase_options_development.dart';
import 'package:mamba/commons/constants/constants.dart';

Future<void> main() async {
  // Initialize App
  WidgetsFlutterBinding.ensureInitialized();
  // Set Global Flavor
  flavor = Flavor.development;
  // Firebase Crashlytics
  Bootstrap(
    firebaseOptions: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
  );
}
