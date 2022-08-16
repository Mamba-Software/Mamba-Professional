// ignore_for_file: avoid_print

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
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/HomeDialogs/AppUpdateDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/HomeDialogs/BrandInviteDialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/NoBrandScreens/BrandIntroScreen.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/NoBrandScreens/RegistrarMarca.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/Profile.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// HomePage for the App. Here the user can change between the diferent pages.
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class BrandScreen extends StatefulWidget {
  const BrandScreen({Key? key}) : super(key: key);

  @override
  _BrandScreenState createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {

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
  bool hasBrand = false;
  // Boolean hasSeenStartUpDialog
  bool hasSeenStartUpDialog = false;
  // Notifications
  LocalNotificationService localNotificationService = LocalNotificationService();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  final CalendarController _controller = CalendarController();

  //Icon to know if it's on favourites
  bool iconStar = false;
  bool isFirstBuild = true;

  //Bools to controll show for drop down
  bool seeNextFavourites = false;
  bool seeNextWho = false;
  bool seeNextWhat = false;
  bool seeNextHow = false;
  bool seeNextWhen = false;
  bool seeNextWhere = false;

  //Icons for drop down
  var iconFavourites = Icons.keyboard_arrow_down;
  var iconWho = Icons.keyboard_arrow_down;
  var iconWhat = Icons.keyboard_arrow_down;
  var iconHow = Icons.keyboard_arrow_down;
  var iconWhen = Icons.keyboard_arrow_down;
  var iconWhere = Icons.keyboard_arrow_down;

  //Index to know which page to load
  int pageIndex = 0;

  //favourite tabs of user
  List<int> favourites = [];

  @override
  void initState() {
    super.initState();
    getFavourites();
    isLoading = true;
    // Handle LocalNotificationsService
    localNotificationService.initialize();
    handleAndlistenNotifications(context);
    // Firebase Cloud Messaging Notifications
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("App in Terminated State Notification Trigger HomePage");
        String route = message.data["route"];
        // Handling OnClickNotification Firebase Messaging Notification
        localNotificationService.onClickedNotification(context, route);
      }
    });
    // If App in Foreground.
    FirebaseMessaging.onMessage.listen((message) {
      print("App in Foreground Notification Trigger HomePage");
      ReceivedNotification notif = ReceivedNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/1000,
        title: message.notification!.title,
        body: message.notification!.body,
        payload: message.data["route"],
      );
      localNotificationService.showNotification(notif);
    });
    // If App in Background, Tap on Notification to be Opened
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("App in Background Notification Trigger HomePage");
      String route = message.data["route"];
      // Handling OnClickNotification Firebase Messaging Notification
      localNotificationService.onClickedNotification(context, route);
    });
    // Listen Dynamic Link Foreground / Background State
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      dynamicLinkBrandId = dynamicLinkData.link.queryParameters['id'];
      checkBrandInvite();
    }).onError((error) {
      print(error.toString());
    });
    // Defining the Page Controller
    pageController = PageController(initialPage: currentIndex);
    // Getting User Information
    getUserAndBrand();
    // On StartUp Dialogs
    launchOnStartUpDialogs();
  }

  // On StartUp Dialogs
  Future<void> launchOnStartUpDialogs() async {
    // First check if minimum version
    print("Checking Minimum App Version...");
    checkMinimumAppVersion();
    print("Checking if invited into Brand...");
    // Check if invited into Brand
    checkBrandInvite();
    print("Checking Notification Permissions...");
    // Check Notification Permissions
    var notificationString = await PermisionsService().checkUserNotificationsPermision();
    if (notificationString == "Provisional" || notificationString == "Unknown") {
      await PermisionsService().askUserNotificationsPermision();
    }
    print("Checking Location Permissions...");
    // Check Location Permissions
    await PermisionsService().getUserLocation();

  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  // Check version and Update App Dialog
  void checkMinimumAppVersion() async {
    // Check version
    List<bool> result = await _settingsDataService.checkIfMinimumAppVersion(appVersion);
    print(result[0]);
    print(result[1]);
    if (result[0] == false) {
      if (result[1]) {
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AppUpdateDialog(
                  isMandatory: true,
                ),
              );
            },
          );
        });
      } else {
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppUpdateDialog(
                isMandatory: false,
              );
            },
          );
        });
      }
    }
  }

  // Check invited by Brand
  void checkBrandInvite() async {
    if (dynamicLinkBrandId != null && currentUser.brandsList.isEmpty) {
      // Start up Dialog
      Future.delayed(Duration.zero, () {
        return showDialog(
            context: context,
            builder: (_) {
              return BrandInviteDialog(
                  brandId: dynamicLinkBrandId,
              );
            }
        );
      });
    }
  }

  // Gets the user info from firebase.
  void getUserAndBrand() async {
    // Get User Main Data
    currentUser.setBasicData = await _userDataService.getUserDetails(currentUser.id!);
    // Get User Brand
    List<Brand> brands = await _brandDataService.getAllBrandsFromUser(currentUser.id!);
    currentUser.setBrandList = brands;
    if (currentUser.brandsList.isNotEmpty) {
      // Setting the Brand to the User
      hasBrand = true;
      Brand brand = currentUser.brandsList[0];
      currentBrand.setBasicData = await _brandDataService.getBrandDetails(brand.id!);
      currentBrand.setUserList = await _brandDataService.getBrandUsers(brand.id!);
    }
    setState(() {
      isLoading = false;
    });
  }

  // listenNotifications if User Taps on Notifications
  Future<void> handleAndlistenNotifications(BuildContext context) async {
    // Did Launch the App
    await localNotificationService.didNotificationLaunch(context);
    // Handle Local Notifications
    await localNotificationService.handleLocalNotifications(context);
    // Listen to the Notifications Stream
    localNotificationService.onNotifications.stream.listen(
            (payload) => localNotificationService.onClickedNotification(context, payload!)
    );
  }

  /// /////----------------------------

  //Function to get the favourites of the user
  void getFavourites() async{
    favourites = await _userDataService.getUserFavourites(currentBrand.id!, currentUser.id!);
    if(favourites.contains(pageIndex)) iconStar = true;
  }

  //Function to set the favourites of the user
  void setFavourites() {
    if(favourites.isNotEmpty && favourites.contains(pageIndex)) {
      iconStar = true;
    } else {
      iconStar = false;
    }
  }

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
    ).whenComplete(() {
      getFavourites();
    });
  }

  //Return the ListTile of each screen of Mamba Pro
  Widget listTilePro(int _pageIndex) {
    return ListTile(
        leading: _mambaProUtils.iconSelector(_pageIndex),
        title:  _mambaProUtils.titlePageSelectorListView(context, _pageIndex),
        onTap: () =>  {
          Navigator.pop(context),
          setState(() {
            pageIndex = _pageIndex;
            setFavourites();
          }),
        }
    );
  }

  Widget buildHeader() {
    return Container(
      height: safeAreaHeight*0.31,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: safeAreaHeight * 0.06),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: navigateToProfileScreen,
                      child: CircularImage(
                        size: safeAreaHeight * 0.1,
                        image: currentUser.imageUrl,
                        color: Theme.of(context).primaryColor,
                        borderWidth: 1,
                      ),
                    ),
                    Row(
                      children: [
                        CounterBadgeIcon(
                          counter: unreadNotifications,
                          child: IconButton(
                            icon: Icon(Icons.notifications, color: Theme.of(context).primaryColor, size: safeAreaWidth*0.07),
                            alignment: Alignment.centerRight,
                            onPressed: navigateToNotificationsScreen,
                          ),
                        ),
                        SizedBox(width: safeAreaWidth * 0.03),
                        CounterBadgeIcon(
                          counter: unreadChats,
                          child: IconButton(
                            icon: Icon(Icons.chat, color: Theme.of(context).primaryColor, size: safeAreaWidth*0.07),
                            alignment: Alignment.centerRight,
                            onPressed: navigateToChatScreen,
                          ),
                        ),
                        /*
                        IconButton(
                          icon: Icon(Icons.settings, color: Theme.of(context).primaryColor, size: safeAreaWidth*0.06),
                          alignment: Alignment.centerRight,
                          onPressed: navigateToSettingsScreen,
                        ),
                         */
                      ],
                    ),
                  ],
                ),
                SizedBox(height: safeAreaHeight * 0.03),
                Text(
                    currentUser.firstName! + ' ' + currentUser.lastName!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.normal)
                ),
                SizedBox(height: safeAreaHeight * 0.02),
                Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(height: safeAreaHeight * 0.02),
              ],
            ),
          ),
          /*
          ListTile(
              leading: Icon(
                Icons.mobile_screen_share,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                  AppLocalizations.of(context)!.shareAppTitle,
                  style: Theme.of(context).textTheme.bodyText1
              ),
              onTap: () {
                _sharePlusUtils.shareMambaLink(currentUser.firstName!);
              }
          ),
           */
        ],
      ),
    );
  }

  Widget buildBrandListOptions() {
    return Container(
        child: Column(
          children: [
            listTilePro(0),
            ListView.builder(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.003),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: favourites.length,
                itemBuilder: (context, index) {
                  int favourite =  favourites[index];
                  return listTilePro(favourite);
                }
            ),

            ListTile(
              title: Row(
                children: [
                  Icon(iconWho,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text(AppLocalizations.of(context)!.quien),
                ],
              ),
              onTap: () => setState(() {
                seeNextWho = !seeNextWho;
                if(iconWho == Icons.keyboard_arrow_up) {
                  iconWho = Icons.keyboard_arrow_down;
                } else {
                  iconWho = Icons.keyboard_arrow_up;
                }
              }),
            ),
            seeNextWho ?
            listTilePro(1) : Container(),
            seeNextWho ? listTilePro(2) : Container(),
            seeNextWho ? listTilePro(15) : Container(),

            ListTile(
              title: Row(
                children: [
                  Icon(iconWhat),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text(AppLocalizations.of(context)!.que),
                ],
              ),
              onTap: () => setState(() {
                seeNextWhat = !seeNextWhat;
                if(iconWhat == Icons.keyboard_arrow_up) {
                  iconWhat = Icons.keyboard_arrow_down;
                } else {
                  iconWhat = Icons.keyboard_arrow_up;
                }
              }),
            ),
            seeNextWhat ?
            listTilePro(8) : Container(),
            seeNextWhat ? listTilePro(12) : Container(),
            seeNextWhat ? listTilePro(4) : Container(),
            seeNextWhat ? listTilePro(5) : Container(),

            ListTile(
              title: Row(
                children: [
                  Icon(iconHow),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text(AppLocalizations.of(context)!.como),
                ],
              ),
              onTap: () => setState(() {
                seeNextHow = !seeNextHow;
                if(iconHow == Icons.keyboard_arrow_up) {
                  iconHow = Icons.keyboard_arrow_down;
                } else {
                  iconHow = Icons.keyboard_arrow_up;
                }
              }),
            ),
            seeNextHow ?
            listTilePro(9) : Container(),
            seeNextHow ? listTilePro(7) : Container(),
            seeNextHow ? listTilePro(6) : Container(),
            seeNextHow ? listTilePro(13) : Container(),
            seeNextHow ? listTilePro(16) : Container(),

            ListTile(
              title: Row(
                children: [
                  Icon(iconWhen),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text(AppLocalizations.of(context)!.cuando),
                ],
              ),
              onTap: () => setState(() {
                seeNextWhen = !seeNextWhen;
                if(iconWhen == Icons.keyboard_arrow_up) {
                  iconWhen = Icons.keyboard_arrow_down;
                } else {
                  iconWhen = Icons.keyboard_arrow_up;
                }
              }),
            ),
            seeNextWhen ? listTilePro(10) : Container(),
            seeNextWhen ? listTilePro(14) : Container(),

            ListTile(
              title: Row(
                children: [
                  Icon(iconWhere),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text(AppLocalizations.of(context)!.donde),
                ],
              ),
              onTap: () => setState(() {
                seeNextWhere = !seeNextWhere;
                if(iconWhere == Icons.keyboard_arrow_up) {
                  iconWhere = Icons.keyboard_arrow_down;
                } else {
                  iconWhere = Icons.keyboard_arrow_up;
                }
              }),
            ),
            seeNextWhere ?
            listTilePro(11) : Container(),
          ],
        ),
      );
  }

  Widget buildNoBrandOptions() {
    return Container(
      child: Column(
        children: [
          ListTile(
              leading: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                  AppLocalizations.of(context)!.createBrand,
                  style: Theme.of(context).textTheme.bodyText1
              ),
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
              }
          ),
          ListTile(
              leading: Icon(
                Icons.qr_code,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                  AppLocalizations.of(context)!.scanQRCode,
                  style: Theme.of(context).textTheme.bodyText1
              ),
              onTap: () {
                _sharePlusUtils.shareMambaLink(currentUser.firstName!);
              }
          ),
        ],
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
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Theme.of(context).primaryColorDark,
        child: ListView(
          // Remove padding
          padding: EdgeInsets.zero,
          children: [
            /*
            UserAccountsDrawerHeader(
              onDetailsPressed: () {print('test');},

              accountName: Text(
                  currentUser.firstName! + ' ' + currentUser.lastName!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 13,fontWeight: FontWeight.bold, background: Paint()
                    ..color = Theme.of(context).primaryColorDark
                    ..strokeWidth = 20
                    ..strokeJoin = StrokeJoin.round
                    ..strokeCap = StrokeCap.round
                    ..style = PaintingStyle.stroke)
              ),
              accountEmail: const Text(''),

              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.network(
                    currentUser.imageUrl!,
                    fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.height*0.10,
                    height: MediaQuery.of(context).size.height*0.3,
                  ),
                ),
              ),
              //currentAccountPictureSize: Size(MediaQuery.of(context).size.width*0.3,MediaQuery.of(context).size.width*0.3),

              otherAccountsPictures: const [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                      "https://randomuser.me/api/portraits/women/74.jpg"),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                      "https://randomuser.me/api/portraits/men/47.jpg"),
                ),
              ]




            ),
             */

            // Header
            buildHeader(),
            Divider(color: Theme.of(context).primaryColor, thickness: 0,height: 1,),
            SizedBox(height: safeAreaHeight * 0.02),

            // Build Options
            hasBrand == false ? buildNoBrandOptions() : Container(),
            hasBrand == true ? buildBrandListOptions() : Container(),


          ],
        ),
      ),
      appBar:  AppBar(
        title: _mambaProUtils.titlePageSelector(context, pageIndex),
        centerTitle: true,
        actions: [
          pageIndex == 10? IconButton(
            onPressed: () {
              if (_controller.view == CalendarView.month) {
                setState(() {
                  _controller.view = CalendarView.week;
                });
              } else {
                setState(() {
                  _controller.view = CalendarView.month;
                  pageIndex = 10;
                });
              }
            },
            icon: _controller.view == CalendarView.month ? SizedBox(
              width: safeAreaWidth*0.15,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_view_week,
                    color: Theme.of(context).primaryColor,
                    size: safeAreaWidth*0.05,
                  ),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                        AppLocalizations.of(context)!.weekString,
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.center
                    ),
                  ),
                ],
              ),
            ) : SizedBox(
              width: safeAreaWidth*0.15,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_view_month,
                    color: Theme.of(context).primaryColor,
                    size: safeAreaWidth*0.05,
                  ),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                        AppLocalizations.of(context)!.monthString,
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.center
                    ),
                  ),
                ],
              ),
            ),
          ) : Container(),
          Padding(
            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
            child: IconButton(
              icon: pageIndex == 0? Container() : Icon(iconStar? Icons.star : Icons.star_border, size: MediaQuery.of(context).size.width*0.06,),
              onPressed: () {
                setState(() {
                  iconStar = !iconStar;
                  if (iconStar == true) {
                    favourites.add(pageIndex);
                  }
                  else {
                    favourites.remove(pageIndex);
                  }
                  favourites.sort();
                  _userDataService.addFavouriteToUser(
                      currentBrand.id!, currentUser.id!, favourites);
                }
                );
              },
            ),
          )
        ],
      ),
      body: Container(),
      //_mambaProUtils.pageSelector(context,pageIndex, currentBrand.id!, currentBrand.numTrainers!, currentBrand.numClients!, _controller,safeAreaWidth, safeAreaHeight),
    );
  }
}

