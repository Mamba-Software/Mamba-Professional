import 'package:mamba/commons/managers/language_manager.dart';
import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ShareBrandLink extends StatefulWidget {
  final bool? addStaff;
  final bool? onlyStaff;

  const ShareBrandLink({super.key, this.addStaff, this.onlyStaff});

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
    Uri brandUriClient = await _dynamicLinkUtils.createDynamicLinkWithIdClient(
        currentBrand.id!, currentBrand.logoUrl!, currentBrand.name!);
    Uri brandUriTrainer =
        await _dynamicLinkUtils.createDynamicLinkWithIdTrainer(
            currentBrand.id!, currentBrand.logoUrl!, currentBrand.name!);
    setState(() {
      brandUrlClient = brandUriClient.toString();
      brandUrlTrainer = brandUriTrainer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return isTrainer == false
        ? Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Container(
                  height: MediaQuery.of(context).size.height * 0.007,
                  width: MediaQuery.of(context).size.width * 0.15,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                            "${context.l10n.invite} ${context.l10n.clients}",
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(context.l10n.scanQRCode,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.width * 0.7,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2),
                        ),
                        child: QrImage(
                          data: brandUrlClient,
                          version: QrVersions.auto,
                          size: MediaQuery.of(context).size.width * 0.5,
                          gapless: true,
                          /*
                    embeddedImage: Image.asset(Assets.logoQRMamba).image,
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: const Size(65, 65),
                    ),
                     */
                        )),
                    Visibility(
                      visible: brandUrlClient == "",
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.7,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withOpacity(0.5),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2),
                        ),
                        child: Center(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width * 0.07,
                            width: MediaQuery.of(context).size.width * 0.07,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Row(children: <Widget>[
                  Expanded(
                    child: Divider(
                        color: Theme.of(context).primaryColor,
                        height: 1,
                        indent: MediaQuery.of(context).size.width * 0.2,
                        endIndent: MediaQuery.of(context).size.width * 0.05),
                  ),
                  Text("o",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppColors.grey),
                      textAlign: TextAlign.center),
                  Expanded(
                    child: Divider(
                        color: Theme.of(context).primaryColor,
                        height: 1,
                        indent: MediaQuery.of(context).size.width * 0.05,
                        endIndent: MediaQuery.of(context).size.width * 0.2),
                  ),
                ]),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                GestureDetector(
                  onTap: () async {
                    await Share.share(brandUrlClient,
                        subject: currentBrand.logoUrl!);
                  },
                  child: Container(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.03),
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.8,
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
                          size: MediaQuery.of(context).size.width * 0.06,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            context.l10n.copyCodeMessage,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.green),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.send_to_mobile_outlined,
                          color: Colors.green,
                          size: MediaQuery.of(context).size.width * 0.06,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                (widget.addStaff != null && widget.addStaff == false)
                    ? Container()
                    : currentUser.brandRole < 3
                        ? TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                isTrainer = true;
                              });
                            },
                            child: Text(
                              "${context.l10n.add} ${context.l10n.staff}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ))
                        : Container(),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Container(
                  height: MediaQuery.of(context).size.height * 0.007,
                  width: MediaQuery.of(context).size.width * 0.15,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                            "${context.l10n.invite} ${context.l10n.staff}",
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(context.l10n.scanQRCode,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.width * 0.7,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2),
                        ),
                        child: QrImage(
                          data: brandUrlTrainer,
                          version: QrVersions.auto,
                          size: MediaQuery.of(context).size.width * 0.5,
                          gapless: true,
                          /*
                    embeddedImage: Image.asset(Assets.logoQRMamba).image,
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: const Size(65, 65),
                    ),
                     */
                        )),
                    Visibility(
                      visible: brandUrlTrainer == "",
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.7,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withOpacity(0.5),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2),
                        ),
                        child: Center(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width * 0.07,
                            width: MediaQuery.of(context).size.width * 0.07,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Row(children: <Widget>[
                  Expanded(
                    child: Divider(
                        color: Theme.of(context).primaryColor,
                        height: 1,
                        indent: MediaQuery.of(context).size.width * 0.2,
                        endIndent: MediaQuery.of(context).size.width * 0.05),
                  ),
                  Text("o",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppColors.grey),
                      textAlign: TextAlign.center),
                  Expanded(
                    child: Divider(
                        color: Theme.of(context).primaryColor,
                        height: 1,
                        indent: MediaQuery.of(context).size.width * 0.05,
                        endIndent: MediaQuery.of(context).size.width * 0.2),
                  ),
                ]),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                GestureDetector(
                  onTap: () async {
                    await Share.share(brandUrlTrainer,
                        subject: currentBrand.logoUrl!);
                  },
                  child: Container(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.03),
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.8,
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
                          size: MediaQuery.of(context).size.width * 0.06,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            context.l10n.copyCodeMessage,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.green),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.send_to_mobile_outlined,
                          color: Colors.green,
                          size: MediaQuery.of(context).size.width * 0.06,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                (widget.onlyStaff != null && widget.onlyStaff == true)
                    ? Container()
                    : currentUser.brandRole < 3
                        ? TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                isTrainer = false;
                              });
                            },
                            child: Text(
                              "${context.l10n.add} ${context.l10n.clients}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ))
                        : Container(),
              ],
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
