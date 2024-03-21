import 'dart:convert';

import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/stripe/Data/data_repository/stripe_connect_data_provider.dart';
import 'package:http/http.dart' as http;

class StripeConnectRepository {
  Future<(String?, String?)> createAccount(Brand brandModel) async {
    try {
      String parameters = "userId=${brandModel.id}&userName=${brandModel.name}";
      if (brandModel.stripeAccountId != null &&
          brandModel.stripeAccountId != '') {
        parameters += '&stripeAccountId=${brandModel.stripeAccountId}';
      }
      http.Response result =
          await StripeConnectDataProvider.createAccountApi(parameters);

      if (result.statusCode == 200) {
        var bodyData = jsonDecode(result.body);
        String? url = bodyData['url'];
        if (url != null && url != '') {
          return (url, result.body);
        }
      }
      return (null, result.body);
    } catch (e) {
      return (null, e.toString());
    }
  }
}
