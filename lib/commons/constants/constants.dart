// Constants that are final and will NEVER change.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  
  // App Name
  static String appName = "Mamba";
  
  //STRIPE
  static get userQuery => FirebaseFirestore.instance
      .collection('Users')
      .where('isTrainer', isEqualTo: false)
      .where('isAdmin', isEqualTo: false);
  static get brandQuery => FirebaseFirestore.instance.collection('Brands');
  static get bonosCollection => 'TestBonos';
  static get baseUrl => dotenv.env['URLSTRIPE'];
  /*static get baseUrl =>
      'https://europe-west1-mamba-fitness-dev.cloudfunctions.net/stripeApi';*/

  static get merchantDisplayName => 'Mamba Software SL';

}
