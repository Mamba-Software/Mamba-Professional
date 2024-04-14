import 'package:mamba/data/DataService/Room/RoomFirebaseCalls.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class RoomDataService {
  final _firebase = RoomFirebaseCalls();

  // Check Data

  // Get Data

  // Add Data

  // Update Data
  Future<void> updateRoom(String? roomId, Map<String, dynamic> metadata) =>
      _firebase.updateRoom(roomId, metadata);
  Future<void> updateRoomLastMessage(String? roomId, var lastMessages) =>
      _firebase.updateRoomLastMessage(roomId, lastMessages);

  // Delete Data
  Future<void> deleteRoom(String roomId) => _firebase.deleteRoom(roomId);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams
}
