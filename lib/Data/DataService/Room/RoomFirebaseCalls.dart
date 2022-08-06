import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';

// Firebase Room Service Class. All calls to Firebase are in this class.
class RoomFirebaseCalls {

  // Firebase Instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final batch = FirebaseFirestore.instance.batch();

  // Firebase collections
  String rooms = isProduction ? 'Rooms' : '7777 Rooms';

  //Update

  Future<void> updateRoom(String? roomId,
      Map<String, dynamic> metadata) async {
    await _firestore.collection(rooms).doc(roomId).update({
      "metadata": metadata
    });
  }

  Future<void> updateRoomLastMessage(String? roomId, var lastMessages) async {
    print(lastMessages.toString());
    await _firestore.collection(rooms).doc(roomId).update({
      "lastMessages": [lastMessages],
    });
  }

  //Delete

  Future<void> deleteRoom(String roomId) async {
    // Delete Messages
    await _firestore
        .collection(rooms)
        .doc(roomId)
        .collection("messages")
        .get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        batch.delete(ds.reference);
      }
    });
    // Delete Room
    await _firestore.collection(rooms).doc(roomId).delete();
  }

}
