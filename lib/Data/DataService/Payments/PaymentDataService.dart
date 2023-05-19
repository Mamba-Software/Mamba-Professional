import 'package:mamba_castelldefels/Data/DataService/Payments/PaymentFirebaseCalls.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';

import '../../Models/Purchase.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class PaymentDataService {

  final _firebase = PaymentFirebaseCalls();

  // Check Data

  // Get Data

  // Add Data
  Future<String> addPurchaseToPayments(Purchase purchase, Bono bonoSelected) => _firebase.addPurchaseToPayments(purchase, bonoSelected);

  // Update Data

  // Delete Data

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams


}