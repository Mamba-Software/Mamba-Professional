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

  static Future createStripeAccount(Brand brand) async {
    BrandDataService _brandDataService = BrandDataService();
    String apiKey =
        "sk_test_51OWbhYIhy0dvY0FfOinR0wbP0UoVeu2WEr1ovTTw1crqSqNy51tza6koJuVUwkg8JdLYLStZIwCXKwwKQ9nmarSp00ykqCvB62";
    String url = 'https://api.stripe.com/v1/accounts';

    final int unixTimestamp =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();
    String ipAddress =
        '192.168.20.20'; // This should be dynamically obtained or set as per your requirement

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'type': 'custom',
        'country': 'ES',
        'individual[first_name]':
            brand.name, // Assuming brand.userName exists and is appropriate
        'individual[last_name]': brand.name,
        'individual[dob][day]': '1',
        'individual[dob][month]': '1',
        'individual[dob][year]': '1990',
        'individual[phone]': '+34666777888',
        'individual[id_number]': '000000000',
        'individual[address][country]': 'ES',
        'individual[address][state]': 'Barcelona',
        'individual[address][city]': 'Barcelona',
        'individual[address][line1]': 'Carrer de la Diputació, 238',
        'individual[address][postal_code]': '08007',
        'tos_acceptance[date]': unixTimestamp.toString(),
        'tos_acceptance[ip]': ipAddress,
        'business_type': 'individual',
        'business_profile[mcc]': '8999',
        'business_profile[url]': 'https://techanion.com',
        'metadata[user_id]':
            brand.id, // Assuming brand.id exists and is appropriate
        'metadata[user_name]': brand.name,
        'capabilities[card_payments][requested]': 'true',
        'capabilities[transfers][requested]': 'true',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _brandDataService.updateBrandStripe(brand.id!, false, data['id']);
      print("Account created: ${data['id']}");
    } else {
      print("Failed to create account: ${response.body}");
    }
    return response;
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
