// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Auth/CreateBrand/views/RegistrarMarca.dart';
import 'package:mamba_castelldefels/Auth/CreateBrand/widgets/buildWidgetsNoBrandScreen.dart';
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
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/Profile.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/ProfileScreens/Settings/Settings.dart';
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
    mixpanel!.track('no_brands_homepage');
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

