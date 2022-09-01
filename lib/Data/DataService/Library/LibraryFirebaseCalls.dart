import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lColor.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lPaymentMethod.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';

// Firebase Library Service Class. All calls to Firebase are in this class.
class LibraryFirebaseCalls {

  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final batch = FirebaseFirestore.instance.batch();

  // Firebase collections
  String users = isProduction ? 'Users' : '7777 Users';
  String nicknames = isProduction ? 'Nicknames' : '7777 Nicknames';
  String brands = isProduction ? 'Brands' : '7777 Brands';
  String conversations = isProduction ? 'Conversations' : '7777 Conversations';
  String library = isProduction ? 'Library' : '7777 Library';

  //Colors
  Future<List<lColor>> getColors() async {
    List<lColor> colors = [];
    try {
      await _firestore.collection(library).doc('Colors')
          .collection("Colors")
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          colors.add(lColor.fromObjectAllData(doc.id, doc));

        }
      });
      return colors;
    } catch (e) {
      print(e.toString());
      return colors;
    }
  }

  Future<List<lPaymentMethod>> getPaymentMethods() async {
    List<lPaymentMethod> paymentMethods = [];
    try {
      await _firestore.collection(library).doc('PaymentMethods')
          .collection("PaymentMethods")
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          paymentMethods.add(lPaymentMethod.fromObjectAllData(doc.id, doc));

        }
      });
      return paymentMethods;
    } catch (e) {
      print(e.toString());
      return paymentMethods;
    }
  }

  Future<String> getRandomEventPhoto() async {
    List<lPaymentMethod> paymentMethods = [];
    try {
      await _firestore.collection(library).doc('PaymentMethods')
          .collection("PaymentMethods")
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          paymentMethods.add(lPaymentMethod.fromObjectAllData(doc.id, doc));

        }
      });
      return "paymentMethods";
    } catch (e) {
      print(e.toString());
      return "paymentMethods";
    }
  }


}
