// This class represents the Object <Image>.
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageObject {
  String? id;
  String? url;
  Timestamp? timestamp;

  ImageObject({
    this.id,
    this.url,
    this.timestamp,
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
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

}