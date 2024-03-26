
import 'package:http/http.dart' as http;
import 'package:mamba/commons/constants/constants.dart';

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
        await http.post(Uri.parse("${AppAssets.baseUrl}/cancelSubscription"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "subscriptionId": subscriptionId,
            }));
    return result;*/
  }
}
