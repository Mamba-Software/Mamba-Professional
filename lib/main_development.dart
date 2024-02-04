import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/bootstrap.dart';
import 'package:mamba_castelldefels/Globals/FirebaseOptions/firebase_options_development.dart';

Future<void> main() async {
  // Set Global Flavor
  currentFlavor = Flavor.development;
  //Stripe
  Stripe.publishableKey =
      'pk_test_51OWbhYIhy0dvY0FfJL0eCvjAGgoyJQuTj81ActDqvdfygppz4W1tFYhXiwGAeXk00a3Bvrsv0ImrWeXKpeRO0YO000nHC9xcy4';
  if (Platform.isIOS) {
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    await Stripe.instance.applySettings();
  }
  // Firebase Crashlytics
  Bootstrap(
    firebaseOptions: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
  );
}
