
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class StripeConnectDataProvider {
  
  static Future createAccountApi(String parameters) async {
    String? baseUrl = dotenv.env['URLSTRIPE'];
    
    http.Response result = await http
        .get(Uri.parse("$baseUrl/createAccount?$parameters"));
    return result;
  }

  static Future cancelSubscription({required String subscriptionId}) async {
    //TODO CANCEL SUB DESDE PRO
    /*
    http.Response result =
        await http.post(Uri.parse("${AppAssets.baseUrl}/cancelSubscription"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "subscriptionId": subscriptionId,
            }));
    return result;*/
  }
}
