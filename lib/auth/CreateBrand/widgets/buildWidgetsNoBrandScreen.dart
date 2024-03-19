// Build the Widget of the Image
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/auth/CreateBrand/views/mobile/RegistrarMarca.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:mamba_castelldefels/commons/utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/commons/widgets/Components/Images/RectangularImage.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/QRCode/QRScanner.dart';
import 'package:mamba_castelldefels/notifications/Unread/widgets/askSupport.dart';
import 'package:mamba_castelldefels/notifications/Unread/widgets/unreadChats.dart';
import 'package:mamba_castelldefels/notifications/Unread/widgets/unreadNotifications.dart';
import 'package:mamba_castelldefels/screens/MambaPro/Profile/Profile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget buildUserPicture(
    BuildContext context, double safeAreaWidth, double safeAreaHeight) {
  return Center(
    child: GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute<void>(
              builder: (context) => const Profile(),
            ));
      },
      child: SizedBox(
        height: safeAreaHeight * 0.1,
        child: Center(
          child: CircularImage(
            size: safeAreaHeight * 0.08,
            image: currentUser.imageUrl,
            color: Theme.of(context).colorScheme.background,
            borderWidth: 2,
          ),
        ),
      ),
    ),
  );
}

Widget buildGreetingWidget(
    BuildContext context, double safeAreaWidth, double safeAreaHeight) {
  return Container(
    height: safeAreaHeight * 0.1,
    width: safeAreaHeight * 0.84,
    decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildUserPicture(context, safeAreaWidth, safeAreaHeight),
        SizedBox(
          width: safeAreaWidth * 0.02,
        ),
        Expanded(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(StringUtils().greetingMessage(context),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.grey),
                    textAlign: TextAlign.center),
                Text(currentUser.firstName!,
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            askSupport(context),
            unreadNotifications(context),
            unreadChats(context),
          ],
        ),
      ],
    ),
  );
}

Widget buildCreateBrandWidget(BuildContext context, var height, var width) {
  return GestureDetector(
    onTap: () async {
      var result2 = await Navigator.push(
          context,
          CupertinoPageRoute<bool>(
            builder: (context) => RegistrarMarca(
              locale: Localizations.localeOf(context),
            ),
            settings: const RouteSettings(name: 'RegistrarMarca'),
          ));
      if (result2 == null) mixpanel!.track('register_brand_closed');
    },
    child: Material(
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          RectangularImage(
              height: height,
              width: width,
              borderRadius: 10,
              image:
                  "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/calendarImage.jpg?alt=media&token=b187bd98-1d6b-4ae2-a49e-60ad59a8f65a"),
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.grey.withOpacity(0.0),
                    Colors.black,
                  ],
                  stops: const [
                    0.0,
                    0.75
                  ]),
              border:
                  Border.all(color: Theme.of(context).primaryColor, width: 1),
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: const Center(),
          ),
          Padding(
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width * 0.9,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(AppLocalizations.of(context)!.createBrand,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                SizedBox(
                  width: width * 0.9,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                            AppLocalizations.of(context)!.createBrandTitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.grey),
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildJoinBrandWidget(BuildContext context, var height, var width) {
  return GestureDetector(
    onTap: () async {
      mixpanel!.track('scan_qr_code_open');
      var result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (BuildContext context) {
          return const FractionallySizedBox(
            heightFactor: 0.7,
            child: QRScanner(),
          );
        },
      );
      if (result == null) mixpanel!.track('scan_qr_code_close');
    },
    child: Material(
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          SizedBox(
            height: height * 0.1,
          ),
          RectangularImage(
              height: height,
              width: width,
              borderRadius: 10,
              image:
                  "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/scanQRCode.jpg?alt=media&token=eed96d79-cb69-42de-9423-da03317e7fa8"),
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.grey.withOpacity(0.0),
                    Colors.black,
                  ],
                  stops: const [
                    0.0,
                    0.75
                  ]),
              border:
                  Border.all(color: Theme.of(context).primaryColor, width: 1),
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: const Center(),
          ),
          Padding(
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width * 0.9,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(AppLocalizations.of(context)!.joinBrand,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                SizedBox(
                  width: width * 0.9,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                            AppLocalizations.of(context)!.joinBrandTitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.grey),
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
