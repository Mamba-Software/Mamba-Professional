// This class represents the Object <RecievedNotification> that will handle local notifications.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReceivedNotification {
  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
    this.createdAt,
    this.firesAt,
  });

  int? id;
  String? title;
  String? body;
  String? payload;
  Timestamp? createdAt;
  DateTime? firesAt;

  ReceivedNotification.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = int.parse(documentId);
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('payload')) {
      this.payload = documentSnapshot.get("payload").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('createdAt')) {
      this.createdAt = documentSnapshot.get("createdAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('firesAt')) {
      this.firesAt = (documentSnapshot.get("firesAt") as Timestamp).toDate();
    }
  }
}