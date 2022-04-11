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
          title: userFirstName! + ' te está invitando a Mamba',
          description: '¡Haz clic para descargar!',
          imageUrl: Uri.parse('https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/mamba_logo.png?alt=media&token=a4307bd0-0c20-497f-abe7-0ada93129b85')),
    );

    final Uri uri = (await dynamicLinks.buildShortLink(parameters)).shortUrl;

    await Share.share(uri.toString(), subject: 'https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/mamba_logo.png?alt=media&token=a4307bd0-0c20-497f-abe7-0ada93129b85');

  }

}
