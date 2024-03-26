import 'package:mamba/app/bootstrap.dart';
import 'package:mamba/app/firebase/firebase_options_staging.dart';
import 'package:mamba/commons/constants/constants.dart';

Future<void> main() async {
  // Set Global Flavor
  flavor = Flavor.staging;  
  // Create Bootstrap Class
  Bootstrap bootstrap = Bootstrap(DefaultFirebaseOptions.currentPlatform);
  // Initialize App
  await bootstrap.initialize();
}

