import 'package:mamba_castelldefels/Data/DataService/Payments/PaymentFirebaseCalls.dart';

import '../../Models/Purchase.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class PaymentDataService {

  final _firebase = PaymentFirebaseCalls();

  // Check Data

  // Get Data

  // Add Data
  Future<void> addPurchaseToPayments(Purchase purchase) => _firebase.addPurchaseToPayments(purchase);

  // Update Data

  // Delete Data

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams


}