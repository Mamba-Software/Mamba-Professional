import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';

//DynamicLinksUtils Class is used to administrate all the dynamic links, creations and gets
class DynamicLinkUtils {
  Future<Uri> createDynamicLinkWithIdClient(
      String id, String urlImage, String brandName) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // The Dynamic Link URI domain. You can view created URIs on your Firebase console
      uriPrefix: 'https://mambastyleapp.page.link',
      // The deep Link passed to your application which you can use to affect change
      link: Uri.parse('https://mambastyleapp.page.link/?id=$id'),
      //link: Uri.parse('https://mambastyleapp.page.link/Share'),
      // Android application details needed for opening correct app on device/Play Store
      androidParameters: const AndroidParameters(
        packageName: "com.mamba.mambastyleapp",
        minimumVersion: 1,
      ),
      // iOS application details needed for opening correct app on device/App Store
      iosParameters: const IOSParameters(
        bundleId: "com.mamba.mambastyleapp",
        appStoreId: "1601684650",
        minimumVersion: '1',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Únete a $brandName',
          description: '¡Haz clic para descargar Mamba!',
          imageUrl: Uri.parse(urlImage)),
    );
    return (await dynamicLinks.buildShortLink(parameters)).shortUrl;
  }

  Future<Uri> createDynamicLinkWithIdTrainer(
      String id, String urlImage, String brandName) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // The Dynamic Link URI domain. You can view created URIs on your Firebase console
      uriPrefix: 'https://mambastyleapp.page.link',
      // The deep Link passed to your application which you can use to affect change
      link: Uri.parse('https://mambastyleapp.page.link/?id=$id'),
      //link: Uri.parse('https://mambastyleapp.page.link/Share'),
      // Android application details needed for opening correct app on device/Play Store
      androidParameters: const AndroidParameters(
        packageName: "com.mamba.mambaprofessionalapp",
        minimumVersion: 1,
      ),
      // iOS application details needed for opening correct app on device/App Store
      iosParameters: const IOSParameters(
        bundleId: "com.mamba.mambaprofessionalapp",
        appStoreId: "1642701679",
        minimumVersion: '1',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Únete a $brandName',
          description: '¡Haz clic para descargar Mamba!',
          imageUrl: Uri.parse(urlImage)),
    );
    return (await dynamicLinks.buildShortLink(parameters)).shortUrl;
  }

  Future<Uri> createDynamicLinkEventId(
      String eventId,
      bool isPrivate,
      String eventImageUrl,
      String eventName,
      String brandName,
      String userName) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    String title = "";
    if (isPrivate) {
      title =
          '$userName de $brandName te está invitando a un evento privado titulado $eventName';
    } else {
      title =
          '$userName de $brandName te está invitando a un evento grupal titulado $eventName';
    }
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // The Dynamic Link URI domain. You can view created URIs on your Firebase console
      uriPrefix: 'https://mambastyleapp.page.link',
      // The deep Link passed to your application which you can use to affect change
      link: Uri.parse('https://mambastyleapp.page.link/?eventId=$eventId'),
      //link: Uri.parse('https://mambastyleapp.page.link/Share'),
      // Android application details needed for opening correct app on device/Play Store
      androidParameters: const AndroidParameters(
        packageName: "com.mamba.mambastyleapp",
        minimumVersion: 1,
      ),
      // iOS application details needed for opening correct app on device/App Store
      iosParameters: const IOSParameters(
        bundleId: "com.mamba.mambastyleapp",
        appStoreId: "1601684650",
        minimumVersion: '1',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: title,
          description: '¡Haz clic para confirmar tu asistencia!',
          imageUrl: Uri.parse(eventImageUrl)),
    );
    return (await dynamicLinks.buildShortLink(parameters)).shortUrl;
  }

  Future<void> retrieveDynamicLink() async {
    try {
      final PendingDynamicLinkData? data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri? deepLink = data?.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.containsKey('id')) {
          dynamicLinkBrandId = deepLink.queryParameters['id'];
          print("INITIAL DYNAMIC LINK");
          print(dynamicLinkBrandId);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
