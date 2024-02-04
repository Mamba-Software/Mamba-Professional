import 'package:http/http.dart' as http;
import 'package:mamba_castelldefels/Globals/Constants.dart';

class StripeConnectDataProvider {
  static Future createAccountApi(String parameters) async {
    http.Response result = await http
        .get(Uri.parse("${Constants.baseUrl}/createAccount?$parameters"));
    return result;
  }
}
