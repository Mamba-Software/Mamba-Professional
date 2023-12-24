import 'package:mamba_castelldefels/bootstrap.dart';
import 'package:mamba_castelldefels/Globals/FirebaseOptions/firebase_options_development.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Load Environment Variables
  try {
    await dotenv.load(fileName: ".env.production"); // Or .env.staging for other flavors
  } catch (e) {
    // If the specified .env file is not found, load the development environment
    await dotenv.load(fileName: ".env.development");
  }
  // Bootstrap App
  Bootstrap(
    flavor: "development",
    firebaseOptions: DefaultFirebaseOptions.currentPlatform
  );
}
