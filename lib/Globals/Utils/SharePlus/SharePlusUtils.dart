import 'dart:io';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share_plus/share_plus.dart';
import '../../GlobalVars.dart';

//SharePlusUtils Class is used to administrate the share links
class SharePlusUtils {

  Future<void>  shareMambaLink(String? userFirstName) async {

    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // The Dynamic Link URI domain. You can view created URIs on your Firebase console
      uriPrefix: 'https://mambastyleapp.page.link',
      // The deep Link passed to your application which you can use to affect change
      link: Uri.parse('https://mambastyleapp.page.link'),
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
          title: userFirstName! + ' te está invitando a Mamba Professional',
          description: '¡Haz clic para descargar!',
          imageUrl: Uri.parse('https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/mambapro_logo.jpg?alt=media&token=3ba956c1-6cc7-4219-9e41-d3c1f10e0dc6')),
    );

    final Uri uri = (await dynamicLinks.buildShortLink(parameters)).shortUrl;

    await Share.share(uri.toString(), subject: 'https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/mambapro_logo.jpg?alt=media&token=3ba956c1-6cc7-4219-9e41-d3c1f10e0dc6');

  }

}
