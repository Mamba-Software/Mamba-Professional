import 'package:geolocator/geolocator.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:notification_permissions/notification_permissions.dart';

class PermisionsService {
  // Notifications

  Future<PermissionStatus> askUserNotificationsPermision() async {
    // Check Notification Permissions
    print("Checking Notification Permissions...");
    PermissionStatus permission =
        await NotificationPermissions.requestNotificationPermissions(
            iosSettings: const NotificationSettingsIos(
                sound: true, badge: true, alert: true));
    switch (permission) {
      case PermissionStatus.denied:
        mixpanel!.track('notifications_permission_denied');
        break;
      case PermissionStatus.granted:
        mixpanel!.track('notifications_permission_granted');
        break;
      case PermissionStatus.unknown:
        mixpanel!.track('notifications_permission_unknown');
        break;
      case PermissionStatus.provisional:
        mixpanel!.track('notifications_permission_provisional');
        break;
      default:
        break;
    }
    print(permission.toString());
    return permission;
  }

  Future<String?> checkUserNotificationsPermision() async {
    return NotificationPermissions.getNotificationPermissionStatus()
        .then((status) {
      switch (status) {
        case PermissionStatus.denied:
          return "Denied";
        case PermissionStatus.granted:
          return "Granted";
        case PermissionStatus.unknown:
          return "Unknown";
        case PermissionStatus.provisional:
          return "Provisional";
        default:
          return null;
      }
    });
  }

  Future<LocationPermission> askUserLocationPermision() async {
    // Check Permissions
    print("Checking Location Permissions...");
    LocationPermission permission = await Geolocator.requestPermission();
    print(permission.toString());
    return permission;
  }

  // Location

  Future<bool> checkUserLocationPermision() async {
    // Check Permissions
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    // Return
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<Position> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    /*
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }
     */

    // Check Permissions
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      mixpanel!.track('location_permission_ask');
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        mixpanel!.track('location_permission_deniedForever');
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      if (permission == LocationPermission.denied) {
        mixpanel!.track('location_permission_denied');
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
      if (permission == LocationPermission.always) {
        mixpanel!.track('location_permission_always');
      }
      if (permission == LocationPermission.whileInUse) {
        mixpanel!.track('location_permission_whileInUse');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        desiredAccuracy: LocationAccuracy.best);
  }
}
