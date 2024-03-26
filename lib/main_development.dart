import 'dart:async';
import 'package:mamba/app/bootstrap.dart';
import 'package:mamba/app/firebase/firebase_options_development.dart';
import 'package:mamba/commons/constants/constants.dart';

Future<void> main() async {
  // Set Global Flavor
  flavor = Flavor.development;  
  // Create Bootstrap Class
  Bootstrap bootstrap = Bootstrap(DefaultFirebaseOptions.currentPlatform);
  // Initialize App
  await bootstrap.initialize();
}
