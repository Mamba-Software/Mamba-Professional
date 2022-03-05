import 'dart:io';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//DynamicLinksUtils Class is used to administrate all the dynamic links, creations and gets
class DynamicLinkUtils {

  Future<Uri>  createDynamicLinkWithId(String id, String urlImage, String brandName) async {

    print(Uri.parse('https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/brandPics%2F9d978520-be41-4d90-94df-f49db3be5eac.png?alt=media&token=94d8bcd2-ce89-4c85-a314-6ffd15fa632e'));
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // The Dynamic Link URI domain. You can view created URIs on your Firebase console
      uriPrefix: 'https://mambastyleapp.page.link',
      // The deep Link passed to your application which you can use to affect change
      link: Uri.parse('https://mambastyleapp.page.link/?id=${id}'),
      //link: Uri.parse('https://mambastyleapp.page.link/Share'),
      // Android application details needed for opening correct app on device/Play Store
      androidParameters: const AndroidParameters(
        packageName: "com.mamba.mambastyleapp",
        minimumVersion: 1,
      ),
      // iOS application details needed for opening correct app on device/App Store
      iosParameters: const IOSParameters(
        bundleId: "com.mamba.mambastyleapp",
        minimumVersion: '1',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: brandName,
          description: 'Únete a mi marca en Mamba',
          imageUrl: Uri.parse(urlImage)),
    );

    return (await dynamicLinks.buildShortLink(parameters)).shortUrl;
  }

}
