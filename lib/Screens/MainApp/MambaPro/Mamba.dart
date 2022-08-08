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
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/HomeDialogs/AppUpdateDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/HomeDialogs/BrandInviteDialog.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../Globals/Styles/Styles.dart';
import '../../../Globals/Utils/MambaProSelector/MambaProUtils.dart';

// HomePage for the App. Here the user can change between the diferent pages.
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class Mamba extends StatefulWidget {
  const Mamba({Key? key}) : super(key: key);

  @override
  _MambaState createState() => _MambaState();
}

class _MambaState extends State<Mamba> {

  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  var _settingsDataService = new SettingsDataService();
  var _mambaProUtils = new MambaProUtils();
  // Boolean Loading
  bool isLoading = false;
  // Boolean hasSeenStartUpDialog
  bool hasSeenStartUpDialog = false;
  // Notifications
  LocalNotificationService localNotificationService = LocalNotificationService();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  CalendarController _controller = CalendarController();

  //Icon to know if it's on favourites
  bool IconStar = false;
  bool isFirstBuild = true;

  //Bools to controll show for drop down
  bool seeNextFavourites = false;
  bool seeNextWho = false;
  bool seeNextWhat = false;
  bool seeNextHow = false;
  bool seeNextWhen = false;
  bool seeNextWhere = false;

  //Icons for drop down
  var IconFavourites = Icons.keyboard_arrow_down;
  var IconWho = Icons.keyboard_arrow_down;
  var IconWhat = Icons.keyboard_arrow_down;
  var IconHow = Icons.keyboard_arrow_down;
  var IconWhen = Icons.keyboard_arrow_down;
  var IconWhere = Icons.keyboard_arrow_down;

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

  //Function to get the favourites of the user
  void getFavourites() async{
    favourites = await _userDataService.getUserFavourites(currentBrand.id!, currentUser.id!);
    if(favourites.contains(pageIndex)) IconStar = true;
  }

  void setFavourites() {
    if(favourites.length != 0 && favourites.contains(pageIndex)) IconStar = true;
    else IconStar = false;
  }

  // Navigate to Notifications Screen
  void navigateToNotificationsScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => Notifications(),
        )
    ).whenComplete(() {
      getFavourites();
    });
  }

  // Navigate to Notifications Screen
  void navigateToChatScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => ChatCore(),
        )
    ).whenComplete(() {
      getFavourites();
    });
  }

  //Return the ListTile of each screen of Mamba Pro
  Widget ListTilePro(int _pageIndex)
  {
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
//
  // Gets the user info from firebase.
  void getUserAndBrand() async {
    // Get User Main Data
    currentUser.setBasicData = await _userDataService.getUserDetails(currentUser.id!);
    // Get User Brand
    List<Brand> brands = await _brandDataService.getAllBrandsFromUser(currentUser.id!);
    currentUser.setBrandList = brands;
    if (currentUser.brandsList.isNotEmpty) {
      // Setting the Brand to the User
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
            Stack(
              alignment: Alignment.topRight,
              children: [
                UserAccountsDrawerHeader(
                  //onDetailsPressed: () {print('test');},
                  arrowColor: Colors.red,
                  //currentAccountPictureSize: Size(MediaQuery.of(context).size.height*0.10,MediaQuery.of(context).size.height*0.3),
                  accountName: Text(currentUser.firstName! + ' ' + currentUser.lastName!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 13,fontWeight: FontWeight.bold, background: Paint()
                        ..color = Theme.of(context).primaryColorDark
                        ..strokeWidth = 20
                        ..strokeJoin = StrokeJoin.round
                        ..strokeCap = StrokeCap.round
                        ..style = PaintingStyle.stroke)),
                  accountEmail: Text(''),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.network(
                        currentUser.imageUrl!,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.height*0.10,
                        height: MediaQuery.of(context).size.height*0.3,
                      ),
                    ),
                  ),

                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorDark,
                    image: DecorationImage(
                        opacity: 1,
                        fit: BoxFit.fill,
                        image: NetworkImage(
                            currentBrand.logoUrl!)),
                  ),


                ),
              ],
            ),
            ListTile(
                title: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
                      child: Text('Administrador'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                      child: IconButton(
                        icon: Icon(Icons.notifications, size: MediaQuery.of(context).size.width*0.06,),
                        onPressed: navigateToNotificationsScreen,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                      child: IconButton(
                        icon: Icon(Icons.chat, size: MediaQuery.of(context).size.width*0.06,),
                        onPressed: navigateToChatScreen,
                      ),
                    ),
                  ],
                ),
            ),
            ListTilePro(0),
            ListView.builder(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.003),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: favourites.length,
                itemBuilder: (context, index) {
                  int favourite =  favourites[index];
                  return ListTilePro(favourite);
                }
            ),

            ListTile(
              title: Row(
                children: [
                  Icon(IconWho,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text(AppLocalizations.of(context)!.quien),
                ],
              ),
              onTap: () => setState(() {
                seeNextWho = !seeNextWho;
                if(IconWho == Icons.keyboard_arrow_up) IconWho = Icons.keyboard_arrow_down;
                else IconWho = Icons.keyboard_arrow_up;
              }),
            ),
            seeNextWho ?
            ListTilePro(1) : Container(),
            seeNextWho ? ListTilePro(2) : Container(),
            seeNextWho ? ListTilePro(15) : Container(),

            ListTile(
              title: Row(
                children: [
                  Icon(IconWhat),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text(AppLocalizations.of(context)!.que),
                ],
              ),
              onTap: () => setState(() {
                seeNextWhat = !seeNextWhat;
                if(IconWhat == Icons.keyboard_arrow_up) IconWhat = Icons.keyboard_arrow_down;
                else IconWhat = Icons.keyboard_arrow_up;
              }),
            ),
            seeNextWhat ?
            ListTilePro(8) : Container(),
            seeNextWhat ? ListTilePro(12) : Container(),
            seeNextWhat ? ListTilePro(4) : Container(),
            seeNextWhat ? ListTilePro(5) : Container(),

            ListTile(
              title: Row(
                children: [
                  Icon(IconHow),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text(AppLocalizations.of(context)!.como),
                ],
              ),
              onTap: () => setState(() {
                seeNextHow = !seeNextHow;
                if(IconHow == Icons.keyboard_arrow_up) IconHow = Icons.keyboard_arrow_down;
                else IconHow = Icons.keyboard_arrow_up;
              }),
            ),
            seeNextHow ?
            ListTilePro(9) : Container(),
            seeNextHow ? ListTilePro(7) : Container(),
            seeNextHow ? ListTilePro(6) : Container(),
            seeNextHow ? ListTilePro(13) : Container(),
            seeNextHow ? ListTilePro(16) : Container(),

            ListTile(
              title: Row(
                children: [
                  Icon(IconWhen),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text(AppLocalizations.of(context)!.cuando),
                ],
              ),
              onTap: () => setState(() {
                seeNextWhen = !seeNextWhen;
                if(IconWhen == Icons.keyboard_arrow_up) IconWhen = Icons.keyboard_arrow_down;
                else IconWhen = Icons.keyboard_arrow_up;
              }),
            ),
            seeNextWhen ?
            ListTilePro(10) : Container(),
            seeNextWhen ?
            ListTilePro(14) : Container(),

            ListTile(
              title: Row(
                children: [
                  Icon(IconWhere),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text(AppLocalizations.of(context)!.donde),
                ],
              ),
              onTap: () => setState(() {
                seeNextWhere = !seeNextWhere;
                if(IconWhere == Icons.keyboard_arrow_up) IconWhere = Icons.keyboard_arrow_down;
                else IconWhere = Icons.keyboard_arrow_up;
              }),
            ),
            seeNextWhere ?
            ListTilePro(11) : Container(),

            //exit
            /*
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.05),
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.exit_to_app, size: MediaQuery.of(context).size.width*0.06, color: Colors.red),
                            onPressed:() => {
                              setState(() {
                                mambaProfessional = false;
                              }),
                            },
                          ),
                          Text('Exit'),
                        ],
                      ),
                    ),
                  ],
                ),
            ),

             */

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
            icon: _controller.view == CalendarView.month ? Container(
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
            ) : Container(
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
              icon: pageIndex == 0? Container() : Icon(IconStar? Icons.star : Icons.star_border, size: MediaQuery.of(context).size.width*0.06,),
              onPressed: () {
                setState(() {
                  IconStar = !IconStar;
                  if (IconStar == true) {
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
      body: _mambaProUtils.pageSelector(context,pageIndex, currentBrand.id!, currentBrand.numTrainers!, currentBrand.numClients!, _controller,safeAreaWidth, safeAreaHeight),
    );
  }

  Future<void> _onTappedBar(int value) async {
    setState(() {
      currentIndex = value;
    });
    pageController.jumpToPage(value);
    print(ModalRoute.of(context)?.settings.name);
  }
}

