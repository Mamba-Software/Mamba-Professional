import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mamba_castelldefels/Stripe/Data/data_repository/stripe_connect_data_provider.dart';

class PaymentRepository {
  Future<bool> cancelSubscription({required String subscriptionId}) async {
    if (subscriptionId == '') return true;
    http.Response response = await StripeConnectDataProvider.cancelSubscription(
      subscriptionId: subscriptionId,
    );
    if (response.statusCode == 200) {
      var bodyData = jsonDecode(response.body);
      return true;
    } else {
      // throw Exception('Failed to load payment intent');
      return false;
    }
  }
}
