// Constants that are final and will NEVER change.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Flavor {
  production,
  staging,
  development,
}

// Flavor
Flavor flavor = Flavor.development;

// Name
String appName = "Mamba";

// App
var androidGooglePlayUrl = "https://play.google.com/store/apps/details?id=com.mamba.mambaprofessionalapp";
var iosAppStoreUrl = "https://apps.apple.com/es/app/mamba-professional/id1642701679";

// Contact
var contactEmail = "contacto@mambafitness.es";
var contactNumber = "+34677909194"; 
var contactNumberMessage = "¡Hola! Estoy interesad@ en saber más sobre sus servicios. ¿Podrían proporcionarme más información?";
var whatsappUrl = "whatsapp://send?phone=$contactNumber&text=${Uri.encodeComponent(contactNumberMessage)}";

// Website
var website = "https://mambafitness.es/";
var termsAndConditions = "https://mambafitness.es/terminos-y-condiciones/";
var privacy = "https://mambafitness.es/privacidad/";
var functionalities = "https://mambafitness.es/profesionales/";

// Stripe
var stripeConnect = "https://stripe.com/es/privacy";
var stripeTermsAndConditions = "https://stripe.com/es/connect";

class Constants {
    static get brandQuery => FirebaseFirestore.instance.collection('Brands');
  static get bonosCollection => 'TestBonos';
  static get baseUrl => dotenv.env['URLSTRIPE'];
  /*static get baseUrl =>
      'https://europe-west1-mamba-fitness-dev.cloudfunctions.net/stripeApi';*/

  static get merchantDisplayName => 'Mamba Software SL';
}
