import 'package:flutter/foundation.dart';
import 'package:mamba_castelldefels/bootstrap.dart';
import 'package:mamba_castelldefels/Globals/FirebaseOptions/firebase_options_staging.dart';

Future<void> main() async {
  // Bootstrap App 
  Bootstrap(
    flavor: "staging",
    firebaseOptions: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
  );
}
