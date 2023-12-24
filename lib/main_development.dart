import 'package:mamba_castelldefels/bootstrap.dart';
import 'package:mamba_castelldefels/Globals/FirebaseOptions/firebase_options_development.dart';

Future<void> main() async {
  Bootstrap(
    flavor: "development",
    firebaseOptions: DefaultFirebaseOptions.currentPlatform
  );
}
