import 'package:flutter/foundation.dart';
import 'package:mamba/app/bootstrap.dart';
import 'package:mamba/commons/firebase/firebase_options_production.dart';
import 'package:mamba/commons/constants/constants.dart';

Future<void> main() async {
  // Set Global Flavor
  flavor = Flavor.production;  
  // Create Bootstrap Class
  Bootstrap bootstrap = Bootstrap(kIsWeb ? DefaultFirebaseOptions.currentPlatform : null);
  // Initialize App
  await bootstrap.initialize();
}
