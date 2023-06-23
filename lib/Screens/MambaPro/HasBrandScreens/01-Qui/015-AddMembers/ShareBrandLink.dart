import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/RegisterBrandMember.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';


class ShareBrandLink extends StatefulWidget {
  final bool? addStaff;
  final bool? onlyStaff;

  const ShareBrandLink({Key? key, this.addStaff, this.onlyStaff}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShareBrandLinkState();
}

class _ShareBrandLinkState extends State<ShareBrandLink> {

  // Booleans
  bool isTrainer = false;
  bool isImage = false;
  // Variables
  final _dynamicLinkUtils = DynamicLinkUtils();
  String brandUrlClient = "";
  String brandUrlTrainer = "";

  @override
  void initState() {
    if (widget.onlyStaff == true) {
      isTrainer = true;
    }
    super.initState();
    getBrandLink();
  }

  Future<void> getBrandLink() async {
    Uri brandUriClient = await _dynamicLinkUtils.createDynamicLinkWithIdClient(currentBrand.id!, currentBrand.logoUrl!, currentBrand.name!);
    Uri brandUriTrainer = await _dynamicLinkUtils.createDynamicLinkWithIdTrainer(currentBrand.id!, currentBrand.logoUrl!, currentBrand.name!);
    setState(() {
      brandUrlClient = brandUriClient.toString();
      brandUrlTrainer = brandUriTrainer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return isTrainer == false ? Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height*0.02),
          Container(
            height: MediaQuery.of(context).size.height*0.007,
            width: MediaQuery.of(context).size.width*0.15,
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(
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
                      AppLocalizations.of(context)!.add+" "+AppLocalizations.of(context)!.clients,
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
              height: MediaQuery.of(context).size.width*0.7,
              width: MediaQuery.of(context).size.width*0.7,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
              ),
              child: QrImage(
                data: brandUrlClient,
                version: QrVersions.auto,
                size: MediaQuery.of(context).size.width*0.5,
                gapless: true,
                /*
                embeddedImage: Image.asset(Constants.logoQRMamba).image,
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: const Size(65, 65),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () async {
                  await Share.share(brandUrlClient, subject: currentBrand.logoUrl!);
                },
                child: Container(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                  height: MediaQuery.of(context).size.height*0.1,
                  width: MediaQuery.of(context).size.width*0.4,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.share,
                        color: Colors.green,
                        size: MediaQuery.of(context).size.width*0.06,
                      ),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.copyCodeMessage,
                          style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.green),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute<String>(
                      builder: (context) =>
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus &&
                                currentFocus.focusedChild != null) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            }
                          },
                          child: const RegisterBrandMember(
                            isTrainer: false,
                          ),
                        ),
                      )
                  ).whenComplete(() {
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                  height: MediaQuery.of(context).size.height*0.1,
                  width: MediaQuery.of(context).size.width*0.4,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.edit_note_outlined,
                        color: Colors.green,
                        size: MediaQuery.of(context).size.width*0.08,
                      ),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.addClientsManually,
                          style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.green),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.02),
          (widget.addStaff != null && widget.addStaff == false) ? Container() : currentUser.brandRole < 3 ? TextButton(
              child: Text(
                AppLocalizations.of(context)!.add+" "+AppLocalizations.of(context)!.staff,
                style: Theme.of(context).textTheme.caption?.copyWith(fontWeight: FontWeight.w700),
              ),
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                setState(() {
                  isTrainer = true;
                });
              }
          ) : Container(),
        ],
      ),
    ) : Scaffold(
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
                      AppLocalizations.of(context)!.add+" "+AppLocalizations.of(context)!.staff,
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
              height: MediaQuery.of(context).size.width*0.7,
              width: MediaQuery.of(context).size.width*0.7,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
              ),
              child: QrImage(
                data: brandUrlTrainer,
                version: QrVersions.auto,
                size: MediaQuery.of(context).size.width*0.5,
                gapless: true,
                /*
                embeddedImage: Image.asset(Constants.logoQRMamba).image,
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: const Size(65, 65),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () async {
                  await Share.share(brandUrlTrainer, subject: currentBrand.logoUrl!);
                },
                child: Container(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                  height: MediaQuery.of(context).size.height*0.1,
                  width: MediaQuery.of(context).size.width*0.4,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.share,
                        color: Colors.green,
                        size: MediaQuery.of(context).size.width*0.06,
                      ),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.copyCodeMessage,
                          style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.green),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute<String>(
                        builder: (context) =>
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                FocusScopeNode currentFocus = FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus &&
                                    currentFocus.focusedChild != null) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }
                              },
                              child: const RegisterBrandMember(
                                isTrainer: false,
                              ),
                            ),
                      )
                  ).whenComplete(() {
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                  height: MediaQuery.of(context).size.height*0.1,
                  width: MediaQuery.of(context).size.width*0.4,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.edit_note_outlined,
                        color: Colors.green,
                        size: MediaQuery.of(context).size.width*0.08,
                      ),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.addClientsManually.split(" ")[0]+" "+AppLocalizations.of(context)!.addClientsManually.split(" ")[1]+" "+AppLocalizations.of(context)!.staff.toLowerCase(),
                          style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.green),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.02),
          (widget.onlyStaff != null && widget.onlyStaff == true) ? Container() : currentUser.brandRole < 3 ? TextButton(
              child: Text(
                AppLocalizations.of(context)!.add+" "+AppLocalizations.of(context)!.clients,
                style: Theme.of(context).textTheme.caption?.copyWith(fontWeight: FontWeight.w700),
              ),
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                setState(() {
                  isTrainer = false;
                });
              }
          ) : Container(),
        ],
      ),
    );


  }


  @override
  void dispose() {
    super.dispose();
  }
}