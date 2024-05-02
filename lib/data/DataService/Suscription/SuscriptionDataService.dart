import 'package:mamba/data/DataService/Suscription/SuscriptionFirebaseCalls.dart';
import '../../../../subscription/models/Subscription.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class SuscriptionDataService {
  final _firebase = SuscriptionFirebaseCalls();

  // Check Data

  // Get Data
  Future<Subscription> getBrandSubscription(String adminAppUserId) =>
      _firebase.getBrandSubscription(adminAppUserId);

  // Add Data

  // Update Data

  // Delete Data

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // STREAMS
}
