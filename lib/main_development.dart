import 'package:flutter/foundation.dart';
import 'package:mamba_castelldefels/bootstrap.dart';
import 'package:mamba_castelldefels/Globals/FirebaseOptions/firebase_options_development.dart';

Future<void> main() async {
  // Firebase Crashlytics
  Bootstrap(
    flavor: "development",
    firebaseOptions: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
  );
}
