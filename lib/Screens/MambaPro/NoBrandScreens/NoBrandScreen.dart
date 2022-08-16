// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/AdminService/SettingsDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/ChatCore.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/Notifications.dart';
import 'package:mamba_castelldefels/Globals/Permissions/PermisionsService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/MambaProSelector/MambaProUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/SharePlus/SharePlusUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/QRCode/QRScanner.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/NoBrandScreens/BrandIntroScreen.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/NoBrandScreens/RegistrarMarca.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/Profile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// HomePage for the App. Here the user can change between the diferent pages.
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class NoBrandScreen extends StatefulWidget {
  const NoBrandScreen({Key? key}) : super(key: key);

  @override
  _NoBrandScreenState createState() => _NoBrandScreenState();
}

class _NoBrandScreenState extends State<NoBrandScreen> {

  // Screen Dimensions
  double safeAreaHeight = 0;
  double safeAreaWidth = 0;

  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _settingsDataService = SettingsDataService();
  final _mambaProUtils = MambaProUtils();
  final SharePlusUtils _sharePlusUtils = SharePlusUtils();
  // Boolean Loading
  bool isLoading = false;
  bool isFirstBuild = true;

  @override
  void initState() {
    super.initState();
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  /// /////----------------------------

  // Navigate to Notifications Screen
  void navigateToNotificationsScreen() {
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
  void navigateToChatScreen() {
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
  void navigateToProfileScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => const Profile(),
        )
    );
  }

  // Build Greeting Widget
  Widget buildGreetingWidget() {
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

  // Build the Widget of the Image
  Widget buildUserPicture() {
    return !isLoading ? Center(
      child: GestureDetector(
        onTap: navigateToProfileScreen,
        child: SizedBox(
          height: safeAreaHeight * 0.1,
          child: Center(
            child: CircularImage(size: safeAreaHeight * 0.08, image: currentUser.imageUrl, color: Theme.of(context).backgroundColor, borderWidth: 2,),
          ),
        ),
      ),
    ) : Center(
      child: Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Container(
          height: safeAreaHeight * 0.08,
          width: safeAreaHeight * 0.08,
          decoration: const BoxDecoration(
            color: AppColors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget buildCreateBrandWidget(var height, var width) {
    return isLoading ?
      Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal:safeAreaWidth*0.08),
              child: Container(
                height: safeAreaHeight*0.03,
                width: safeAreaWidth*0.4,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: safeAreaHeight*0.02,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal:safeAreaWidth*0.08),
              child: Container(
                height: safeAreaHeight*0.20,
                width: safeAreaWidth,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      )
        :
      GestureDetector(
        onTap: () async {
          bool? result = await Navigator.push(
              context,
              CupertinoPageRoute<bool>(
                builder: (context) => BrandIntroScreen(),
              )
          );
          if (result != null && result) {
            Navigator.push(
                context,
                CupertinoPageRoute<Null>(
                  builder: (context) => RegistrarMarca(
                    locale: Localizations.localeOf(context),
                  ),
                  settings: const RouteSettings(name: 'RegistrarMarca'),
                )
            );
          }
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

  Widget buildJoinBrandWidget(var height, var width) {
    return isLoading ?
      Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal:safeAreaWidth*0.08),
              child: Container(
                height: safeAreaHeight*0.03,
                width: safeAreaWidth*0.4,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: safeAreaHeight*0.02,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal:safeAreaWidth*0.08),
              child: Container(
                height: safeAreaHeight*0.20,
                width: safeAreaWidth,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      )
        :
      GestureDetector(
        onTap: () async {
          Navigator.push(
              context,
              CupertinoPageRoute<void>(
                builder: (context) => const QRScanner(),
              )
          );
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

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }

    return Scaffold (
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
        ),
        body: SafeArea(
          left: false,
          right: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: safeAreaHeight*0.06,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                  child: buildGreetingWidget(),
                ),
                SizedBox(height: safeAreaHeight*0.1,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                  child: buildCreateBrandWidget(safeAreaHeight*0.20, safeAreaWidth),
                ),
                SizedBox(height: safeAreaHeight*0.06,),
                Row(
                    children: <Widget>[
                      Expanded(
                          child: Divider(color: Theme.of(context).primaryColor, height: 1, indent: safeAreaWidth*0.10, endIndent: safeAreaWidth*0.05),
                      ),
                      Text(
                          "o",
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.grey),
                          textAlign: TextAlign.center
                      ),
                      Expanded(
                        child: Divider(color: Theme.of(context).primaryColor, height: 1, indent: safeAreaWidth*0.05, endIndent: safeAreaWidth*0.10),
                      ),
                    ]
                ),
                SizedBox(height: safeAreaHeight*0.06,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                  child: buildJoinBrandWidget(safeAreaHeight*0.20, safeAreaWidth),
                ),
              ],
            ),
          ),
        )
    );
  }
}

