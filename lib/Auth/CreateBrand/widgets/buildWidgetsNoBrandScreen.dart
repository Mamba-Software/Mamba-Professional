// Build the Widget of the Image
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/ChatCore.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/Notifications.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/QRCode/QRScanner.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/Profile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget buildUserPicture(BuildContext context, double safeAreaWidth, double safeAreaHeight) {
  return Center(
    child: GestureDetector(
      onTap: navigateToProfileScreen,
      child: SizedBox(
        height: safeAreaHeight * 0.1,
        child: Center(
          child: CircularImage(size: safeAreaHeight * 0.08, image: currentUser.imageUrl, color: Theme.of(context).backgroundColor, borderWidth: 2,),
        ),
      ),
    ),
  );
}

// Build Greeting Widget
Widget buildGreetingWidget(BuildContext context, double safeAreaWidth, double safeAreaHeight) {
  return Container(
    height: safeAreaHeight*0.1,
    width: safeAreaHeight*0.84,
    decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildUserPicture(),
        SizedBox(width: safeAreaWidth*0.02,),
        Expanded(
          child: Container(
            child: isLoading ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: AppColors.grey,
                  highlightColor: AppColors.grey.withOpacity(0.5),
                  child: Container(
                    height: safeAreaHeight * 0.02,
                    width: safeAreaWidth * 0.2,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: AppColors.grey,
                  highlightColor: AppColors.grey.withOpacity(0.5),
                  child: Container(
                    height: safeAreaHeight * 0.03,
                    width: safeAreaWidth * 0.3,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ],
            ) : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    StringUtils().greetingMessage(context),
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.grey),
                    textAlign: TextAlign.center
                ),
                Text(
                    currentUser.firstName!,
                    style: Theme.of(context).textTheme.headline1,
                    textAlign: TextAlign.center
                ),
              ],
            ),
          ),
        ),
        isLoading ? SizedBox(
          width: safeAreaWidth*0.2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: AppColors.grey,
                highlightColor: AppColors.grey.withOpacity(0.5),
                child: Container(
                  height: safeAreaHeight * 0.04,
                  width: safeAreaHeight * 0.04,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              SizedBox(width: safeAreaWidth*0.02,),
              Shimmer.fromColors(
                baseColor: AppColors.grey,
                highlightColor: AppColors.grey.withOpacity(0.5),
                child: Container(
                  height: safeAreaHeight * 0.04,
                  width: safeAreaHeight * 0.04,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),

            ],
          ),
        ) : Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CounterBadgeIcon(
              counter: unreadNotifications,
              child: IconButton(
                icon: Icon(Icons.notifications, color: Theme.of(context).primaryColor, size: safeAreaWidth*0.06),
                alignment: Alignment.centerRight,
                onPressed: navigateToNotificationsScreen,
              ),
            ),
            CounterBadgeIcon(
              counter: unreadChats,
              child: IconButton(
                icon: Icon(Icons.chat, color: Theme.of(context).primaryColor, size: safeAreaWidth*0.06),
                alignment: Alignment.centerRight,
                onPressed: navigateToChatScreen,
              ),
            ),
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
          )
      );
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
              image: "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/calendarImage.jpg?alt=media&token=b187bd98-1d6b-4ae2-a49e-60ad59a8f65a"
          ),
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
                  ]
              ),
              border: Border.all(color: Theme.of(context).primaryColor, width: 1),
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
                  width: width*0.9,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                            AppLocalizations.of(context)!.createBrand,
                            style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height*0.02,
                ),
                SizedBox(
                  width: width*0.9,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                            AppLocalizations.of(context)!.createBrandTitle,
                            style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.grey),
                            textAlign: TextAlign.left
                        ),
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
          SizedBox(height: height*0.1,),
          RectangularImage(
              height: height,
              width: width,
              borderRadius: 10,
              image: "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/scanQRCode.jpg?alt=media&token=eed96d79-cb69-42de-9423-da03317e7fa8"
          ),
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
                  ]
              ),
              border: Border.all(color: Theme.of(context).primaryColor, width: 1),
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
                  width: width*0.9,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                            AppLocalizations.of(context)!.joinBrand,
                            style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height*0.02,
                ),
                SizedBox(
                  width: width*0.9,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                            AppLocalizations.of(context)!.joinBrandTitle,
                            style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.grey),
                            textAlign: TextAlign.left
                        ),
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



// Navigate to Notifications Screen
void _navigateToProfileScreen(BuildContext context) {
  Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => const Profile(),
      )
  );
}

// Navigate to Notifications Screen
void navigateToNotificationsScreen(BuildContext context) {
  Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => const Notifications(),
      )
  ).whenComplete(() async {
    var temp = await _userDataService.getUnreadNotifications(currentUser.id!);
    setState(() {
      unreadNotifications = temp;
    });
  });
}

// Navigate to Notifications Screen
void navigateToChatScreen(BuildContext context) {
  Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => const ChatCore(),
      )
  ).whenComplete(() async {
    var temp = await _userDataService.getUnreadConversations(currentUser.id!);
    setState(() {
      unreadChats = temp;
    });
  });
}

// Navigate to Notifications Screen
void navigateToProfileScreen(BuildContext context) {
  Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => const Profile(),
      )
  );
}
