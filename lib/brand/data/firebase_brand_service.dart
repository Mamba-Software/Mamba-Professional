import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/user/data/user_repository.dart';
import 'package:mamba/user/models/users/user.dart';

import 'dart:async';
import 'dart:io';

//Singleton
class FirebaseBrandService {
  // Collections
  static final _brandsCollection =
      FirebaseFirestore.instance.collection('Brands');

  Stream<Brand> geBrandStream({required String uid}) {
    return _brandsCollection.doc(uid).snapshots().map((documentSnapshot) {
      // Assuming `Brand.fromObjectAllData` is a static method or similar
      // You need to return a new instance of Brand
      return Brand.fromObjectAllData(uid, documentSnapshot);
    });
  }
}
