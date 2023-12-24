import 'package:mamba_castelldefels/bootstrap.dart';
import 'package:mamba_castelldefels/Globals/FirebaseOptions/firebase_options_production.dart';

Future<void> main() async {
  Bootstrap(
    flavor: "production",
    firebaseOptions: DefaultFirebaseOptions.currentPlatform
  );
}
