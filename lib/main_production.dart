import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mamba/app/bootstrap.dart';
import 'package:mamba/app/firebase/firebase_options_production.dart';
import 'package:mamba/commons/constants/constants.dart';

Future<void> main() async {
  // Initialize App
  WidgetsFlutterBinding.ensureInitialized();
  // Set Global Flavor
  flavor = Flavor.production;
  // Firebase Crashlytics
  Bootstrap(
    firebaseOptions: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
  );
}
