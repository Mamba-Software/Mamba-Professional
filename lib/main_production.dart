import 'package:flutter/foundation.dart';
import 'package:mamba_castelldefels/bootstrap.dart';
import 'package:mamba_castelldefels/Globals/FirebaseOptions/firebase_options_production.dart';

Future<void> main() async {
  // Bootstrap App
  Bootstrap(
    flavor: "production",
    firebaseOptions: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
  );
}
