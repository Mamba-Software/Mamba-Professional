import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';

class StripeConnectDataProvider {
  static Future createAccountApi(String parameters) async {
    http.Response result = await http
        .get(Uri.parse("${Constants.baseUrl}/createAccount?$parameters"));
    return result;
  }

  static Future cancelSubscription({required String subscriptionId}) async {
    //TODO CANCEL SUB DESDE PRO
    /*
    http.Response result =
        await http.post(Uri.parse("${AppConstants.baseUrl}/cancelSubscription"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "subscriptionId": subscriptionId,
            }));
    return result;*/
  }
}
