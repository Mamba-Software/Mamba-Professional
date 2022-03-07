import 'package:mamba_castelldefels/Data/DataService/FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class SettingsDataService {

  final _firebase = FirebaseDatabaseService();

  // Check Data
  Future<bool> checkIfMinimumAppVersion(String clientAppVersion) => _firebase.checkIfMinimumAppVersion(clientAppVersion);

  // Get Data

  // Add Data

  // Update Data

  // Delete Data

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams


}