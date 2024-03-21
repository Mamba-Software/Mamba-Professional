import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba/data/LibraryModels/lColor.dart';
import 'package:mamba/data/LibraryModels/lDegradate.dart';
import 'package:mamba/data/LibraryModels/lImage.dart';
import 'package:mamba/data/LibraryModels/lPaymentMethod.dart';

// Firebase Library Service Class. All calls to Firebase are in this class.
class LibraryFirebaseCalls {
  // Firebase Instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final batch = FirebaseFirestore.instance.batch();

  // Firebase collections
  String users = 'Users';
  String nicknames = 'Nicknames';
  String brands = 'Brands';
  String conversations = 'Conversations';
  String library = 'Library';

  //Colors
  Future<List<lColor>> getColors() async {
    List<lColor> colors = [];
    try {
      await _firestore
          .collection(library)
          .doc('Colors')
          .collection("Colors")
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          colors.add(lColor.fromObjectAllData(doc.id, doc));
        }
        colors.sort((a, b) {
          if (int.parse(a.id!) > int.parse(b.id!)) {
            return 1;
          }
          return -1;
        });
      });

      return colors;
    } catch (e) {
      print(e.toString());
      return colors;
    }
  }

  //Degradates
  Future<List<lDegradate>> getDegradates() async {
    List<lDegradate> degradates = [];
    try {
      await _firestore
          .collection(library)
          .doc('Colors')
          .collection("Degradates")
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          degradates.add(lDegradate.fromObjectAllData(doc.id, doc));
        }
        degradates.sort((a, b) {
          if (int.parse(a.id!) > int.parse(b.id!)) {
            return 1;
          }
          return -1;
        });
      });

      return degradates;
    } catch (e) {
      print(e.toString());
      return degradates;
    }
  }

  Future<List<lPaymentMethod>> getPaymentMethods() async {
    List<lPaymentMethod> paymentMethods = [];
    try {
      await _firestore
          .collection(library)
          .doc('Payment Methods')
          .collection("Payment Methods")
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
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(library)
          .doc('Images')
          .collection("Events")
          .get();
      Random rnd = Random();
      int index = rnd.nextInt(querySnapshot.size);
      lImage image = lImage.fromObjectAllData(
          querySnapshot.docs[index].id, querySnapshot.docs[index]);
      return image.url!;
    } catch (e) {
      print(e.toString());
      return "Error";
    }
  }

  Future<void> sendEmailToUser(String templateId, String userId,
      [String? brandId]) async {
    switch (templateId) {
      case "joinBrandMessage":
        await _firestore
            .collection(library)
            .doc("Email Templates")
            .collection("Emails To Send")
            .doc(userId)
            .set({
          "templateId": templateId,
          "userId": userId,
          "brandId": brandId,
        }).catchError((err) {
          print(err);
        });
        break;
      case "joinBrandMessagePro":
        await _firestore
            .collection(library)
            .doc("Email Templates")
            .collection("Emails To Send")
            .doc(userId)
            .set({
          "templateId": templateId,
          "userId": userId,
          "brandId": brandId,
        }).catchError((err) {
          print(err);
        });
        break;
      default:
        break;
    }
  }
}
