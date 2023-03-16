// This class represents the Object <Image>.
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageObject {
  String? id;
  String? url;
  Timestamp? timestamp;
  bool? isBaseImage;

  ImageObject({
    this.id,
    this.url,
    this.timestamp,
    this.isBaseImage,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  ImageObject.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('url')) {
      this.url = documentSnapshot.get("url").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('timestamp')) {
      this.timestamp = documentSnapshot.get("timestamp");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isBaseImage')) {
      this.isBaseImage = documentSnapshot.get("isBaseImage");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

}