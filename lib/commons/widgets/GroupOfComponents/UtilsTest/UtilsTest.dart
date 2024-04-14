import 'package:cloud_functions/cloud_functions.dart';

class UtilsTest {
  callTestFunction() async {
    String cloudFunction = 'scheduledCheckBonoFunctionOnCall';
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1')
              .httpsCallable(cloudFunction);

      await callable.call();
      return -1;
    } catch (e) {
      print(e.toString());
      return -1;
    }
  }
}
