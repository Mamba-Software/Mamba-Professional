import 'package:geoflutterfire2/geoflutterfire2.dart';

class GeoFlutterUtils {

  static Map<String, dynamic> getGeoPoint(double latitude, double longitude) {
    final geo = GeoFlutterFire();
    GeoFirePoint myLocation = geo.point(latitude: latitude, longitude: longitude);
    return {'geoPosition': myLocation.data};
  }

}
