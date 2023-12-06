// This class represents the Object <RecievedNotification> that will handle local notifications.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReceivedNotification {
  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
    this.bonoId,
    this.eventId,
    this.purchaseId,
    this.createdAt,
    this.firesAt,
  });

  int? id;
  String? title;
  String? body;
  String? payload;
  String? bonoId;
  String? purchaseId;
  String? eventId;
  Timestamp? createdAt;
  DateTime? firesAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'bonoId': bonoId,
      'eventId': eventId,
      'purchaseId': purchaseId,
    };
  }

  ReceivedNotification.fromObjectAllData(
      String documentId, DocumentSnapshot documentSnapshot) {
    id = int.parse(documentId);
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('title')) {
      title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('body')) {
      body = documentSnapshot.get("body").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('payload')) {
      payload = documentSnapshot.get("payload").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('eventId')) {
      eventId = documentSnapshot.get("eventId").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('bonoId')) {
      bonoId = documentSnapshot.get("bonoId").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('purchaseId')) {
      purchaseId = documentSnapshot.get("purchaseId").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('createdAt')) {
      createdAt = documentSnapshot.get("createdAt");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('firesAt')) {
      firesAt = (documentSnapshot.get("firesAt") as Timestamp).toDate();
    }
  }
}
