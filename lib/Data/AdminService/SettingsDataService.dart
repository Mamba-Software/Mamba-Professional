import 'package:mamba_castelldefels/Data/DataService/FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class SettingsDataService {

  final _firebase = FirebaseDatabaseService();

  // Check Data
  Future<List<bool>> checkIfMinimumAppVersion(String clientAppVersion) => _firebase.checkIfMinimumAppVersion(clientAppVersion);
  Future<String> checkMonthOffer() => _firebase.checkMonthOffer();

  // Get Data

  // Add Data

  // Update Data

  // Delete Data

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams


}