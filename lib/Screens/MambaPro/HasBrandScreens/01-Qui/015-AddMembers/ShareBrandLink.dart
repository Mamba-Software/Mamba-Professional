import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';


class ShareBrandLink extends StatefulWidget {
  const ShareBrandLink({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShareBrandLinkState();
}

class _ShareBrandLinkState extends State<ShareBrandLink> {

  //  Booleans
  final _dynamicLinkUtils = DynamicLinkUtils();
  String brandUrl = "";

  @override
  void initState() {
    super.initState();
    getBrandLink();
  }

  Future<void> getBrandLink() async {
    Uri brandUri = await _dynamicLinkUtils.createDynamicLinkWithId(currentBrand.id!, currentBrand.logoUrl!, currentBrand.name!);
    setState(() {
      brandUrl = brandUri.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height*0.02),
          Container(
            height: MediaQuery.of(context).size.height*0.007,
            width: MediaQuery.of(context).size.width*0.15,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.03),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                      AppLocalizations.of(context)!.addMembers,
                      style: Theme.of(context).textTheme.headline1!.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.left
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.04),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                      AppLocalizations.of(context)!.scanQRCode,
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.left
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.01),
          Container(
            height: MediaQuery.of(context).size.width*0.6,
            width: MediaQuery.of(context).size.width*0.6,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              ),
              border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
            ),
            child: QrImage(
              data: brandUrl,
              version: QrVersions.auto,
              size: MediaQuery.of(context).size.width*0.5,
              gapless: false,
              /*
              embeddedImage: CachedNetworkImageProvider(currentBrand.logoUrl!),
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: const Size(80, 80),
                color: Theme.of(context).primaryColor.withOpacity(0.25)
              ),
               */
            )
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.03),
          Row(
              children: <Widget>[
                Expanded(
                  child: Divider(color: Theme.of(context).primaryColor, height: 1, indent: MediaQuery.of(context).size.width*0.2, endIndent: MediaQuery.of(context).size.width*0.05),
                ),
                Text(
                    "o",
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.grey),
                    textAlign: TextAlign.center
                ),
                Expanded(
                  child: Divider(color: Theme.of(context).primaryColor, height: 1, indent: MediaQuery.of(context).size.width*0.05, endIndent: MediaQuery.of(context).size.width*0.2),
                ),
              ]
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.03),
          GestureDetector(
            onTap: () async {
              final Uri uri = await _dynamicLinkUtils.createDynamicLinkWithId(currentBrand.id!, currentBrand.logoUrl!, currentBrand.name!);
              await Share.share(uri.toString(), subject: currentBrand.logoUrl!);
            },
            child: Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.05),
              height: MediaQuery.of(context).size.height*0.1,
              width: MediaQuery.of(context).size.width*0.8,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.share,
                    color: Colors.green,
                    size: MediaQuery.of(context).size.width*0.06,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.02),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.copyCodeMessage,
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.02),
                  Icon(Icons.mobile_screen_share, color: Colors.green, size: MediaQuery.of(context).size.width*0.06,)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
  }
}