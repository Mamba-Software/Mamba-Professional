import 'dart:io';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//DynamicLinksUtils Class is used to administrate all the dynamic links, creations and gets
class DynamicLinkUtils {

  Future<Uri>  createDynamicLinkWithId(String id) async {
    print("aqui");
    print(id);
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // The Dynamic Link URI domain. You can view created URIs on your Firebase console
      uriPrefix: 'https://mambastyleapp.page.link',
      // The deep Link passed to your application which you can use to affect change
      link: Uri.parse('https://mambastyleapp.page.link/?id=${id}'),
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
    );

    return await dynamicLinks.buildLink(parameters);
  }

  Future<String?> retrieveDynamicLink(BuildContext context) async {
    try {
      final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
       Uri? deepLink = data?.link;
      print(deepLink);

      if (deepLink != null) {
        print("entra");
        if (deepLink!.queryParameters.containsKey('id')) {
          String? id = deepLink!.queryParameters['id'];
          return id;
        }
      }

    } catch (e) {
      print(e.toString());
    }

  }

}
