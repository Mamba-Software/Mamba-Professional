import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/AdminService/SettingsDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/HomeDialogs/AppUpdateDialog.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandWrapperPage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/AddBrandPics.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/EditBrandInfo.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandPage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Home/Homepage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Sesions/Sesions.dart';
import '../../../Globals/Styles/Styles.dart';
import '../../../Globals/Widgets/Components/Images/CircularImage.dart';
import '../Home/Chat/ChatCore/ChatCore.dart';
import '../Home/Notifications/Notifications.dart';
import '../MambaPro/Bonos.dart';
import '../MambaPro/BrandInfo.dart';
import '../MambaPro/Categories.dart';
import '../MambaPro/Content.dart';
import '../MambaPro/Locations.dart';
import '../MambaPro/Logo.dart';
import '../MambaPro/SesionsPro.dart';
import '../MambaPro/Trainers.dart';
import '../MambaPro/Clients.dart';
import '../MambaPro/HomePro.dart';
import '../MambaPro/UserCalendarPro.dart';
import 'Brand/BrandScreens/BrandCalendarWeekWidget.dart';
import 'Profile/Profile.dart';
import 'Sesions/SesionsScreens/UserCalendarMonthWidget.dart';

// HomePage for the App. Here the user can change between the diferent pages.
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class MambaClient extends StatefulWidget {
  const MambaClient({Key? key}) : super(key: key);

  @override
  _MambaClientState createState() => _MambaClientState();
}

class _MambaClientState extends State<MambaClient> {

  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  var _settingsDataService = new SettingsDataService();
  // Boolean Loading
  bool isLoading = false;
  // Boolean hasSeenStartUpDialog
  bool hasSeenStartUpDialog = false;
  // Boolean to controll switch state
  bool isSwitched = mambaProfessional;
  // String to show if mamba pro is activated
  String textValue = '';

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
    if(mambaProfessional = true) {
      getFavourites();
    }
    isLoading = true;
    // Init LocalNotificationsService
    LocalNotificationService.initialize(context);
    /// Message on which User has tapped from Terminated State
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("App in Terminated State Notification Trigger HomePage");
        final route = message.data["route"];
        currentIndex = int.parse(route[route.length-1]);
        pageController.jumpToPage(currentIndex);
      }
    });
    // If App in Foreground.
    FirebaseMessaging.onMessage.listen((message) {
      print("App in Foreground Notification Trigger HomePage");
      LocalNotificationService.display(message);
    });
    // If App in Background, Tap on Notification to be Opened
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("App in Background Notification Trigger HomePage");
      final route = message.data["route"];
      if (route == "SplashScreen1") {
        String routeFromMessage = route.substring(0, route.length - 1);;
        currentIndex = int.parse(route[route.length-1]);
        Navigator.of(context).pushNamedAndRemoveUntil(routeFromMessage, (Route<dynamic> route) => false, arguments: currentIndex);
      } else {
        if (ModalRoute.of(context)!.isCurrent) {
          print("Top Page, Moving to Notifications Page");
          currentIndex = int.parse(route[route.length-1]);
          if (currentIndex == 2) {
            Navigator.of(context).pushNamedAndRemoveUntil("Notifications", (Route<dynamic> route) => false, arguments: currentIndex);
          } else if (currentIndex == 3) {
            Navigator.of(context).pushNamedAndRemoveUntil("Chat", (Route<dynamic> route) => false, arguments: currentIndex);
          } else {
            pageController.jumpToPage(currentIndex);
          }
        } else {
          print("Not in Home Page, Moving to Splash Screen");
          String routeFromMessage = route.substring(0, route.length - 1);;
          currentIndex = int.parse(route[route.length-1]);
          if (currentIndex == 2) {
            Navigator.of(context).pushNamedAndRemoveUntil("Notifications", (Route<dynamic> route) => false, arguments: currentIndex);
          } else if (currentIndex == 3) {
            Navigator.of(context).pushNamedAndRemoveUntil("Chat", (Route<dynamic> route) => false, arguments: currentIndex);
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(routeFromMessage, (Route<dynamic> route) => false, arguments: currentIndex);
          }
        }
      }
    });
    // Defining the Page Controller
    pageController = PageController(initialPage: currentIndex);
    // Check if User minimum version
    checkMinimumAppVersion();
    // Getting User Information
    getUserAndBrand();
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  void initVariables() async {
    isSwitched = mambaProfessional;
    if(mambaProfessional) textValue = "Desactivar Dark mode";
    else textValue = "Activar Dark mode";
  }

  //Class to control swithc state
  void toggleSwitch(bool value) {

    if(isSwitched == false)
    {
      setState(() {
        isSwitched = true;
        textValue = AppLocalizations.of(context)!.mambaProActivated;

      });
      Navigator.pop(context);
      setState(() {
        mambaProfessional = isSwitched;
        print(mambaProfessional.toString());
      });
    }
    else
    {
      setState(() {
        isSwitched = false;

        textValue = AppLocalizations.of(context)!.mambaProDesactivated;

      });
      Navigator.pop(context);
      setState(() {
        mambaProfessional = isSwitched;
      });
    }
  }

  // Check version and Update App Dialog
  void checkMinimumAppVersion() async {
    // Check version
    bool result = await _settingsDataService.checkIfMinimumAppVersion(appVersion);
    if (result == false) {
      // Start up Dialog
      Future.delayed(Duration.zero, () {
        return showDialog(
            context: context,
            builder: (_) {
              return AppUpdateDialog();
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

  //Function to select the title of the page loaded
  Widget titlePageSelector()
  {
    if(pageIndex == 0)return Text(AppLocalizations.of(context)!.homeBottomNav, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 1)return Text(AppLocalizations.of(context)!.trainers, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 2)return Text(AppLocalizations.of(context)!.clients, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 4)return Text(AppLocalizations.of(context)!.categories, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 5)return Text(AppLocalizations.of(context)!.bonos, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 8)return Text(AppLocalizations.of(context)!.information, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 7)return Text(AppLocalizations.of(context)!.content, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 6)return Text(AppLocalizations.of(context)!.opinions, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 9)return Text(AppLocalizations.of(context)!.stats, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 10)return Text(AppLocalizations.of(context)!.calendar, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 11)return Text(AppLocalizations.of(context)!.locations, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 12)return Text(AppLocalizations.of(context)!.logo, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 13)return Text(AppLocalizations.of(context)!.feedback, style: Theme.of(context).appBarTheme.titleTextStyle,);
    return Container();
  }

  //Function to know the title on listview
  Widget titlePageSelectorListView(int _pageIndex)
  {
    if(_pageIndex == 0)return Text(AppLocalizations.of(context)!.homeBottomNav);
    if(_pageIndex == 1)return Text(AppLocalizations.of(context)!.trainers);
    if(_pageIndex == 2)return Text(AppLocalizations.of(context)!.clients);
    if(_pageIndex == 4)return Text(AppLocalizations.of(context)!.categories);
    if(_pageIndex == 5)return Text(AppLocalizations.of(context)!.bonos);
    if(_pageIndex == 8)return Text(AppLocalizations.of(context)!.information);
    if(_pageIndex == 7)return Text(AppLocalizations.of(context)!.content);
    if(_pageIndex == 6)return Text(AppLocalizations.of(context)!.opinions);
    if(_pageIndex == 9)return Text(AppLocalizations.of(context)!.stats);
    if(_pageIndex == 10)return Text(AppLocalizations.of(context)!.calendar);
    if(_pageIndex == 11)return Text(AppLocalizations.of(context)!.locations);
    if(_pageIndex == 12)return Text(AppLocalizations.of(context)!.logo);
    if(_pageIndex == 13)return Text(AppLocalizations.of(context)!.feedback);
    return Container();
  }

  //Function to select the icon to load
  Widget iconSelector(int pageIndexView)
  {
    if(pageIndexView == 0) return Icon(Icons.home_filled);
    if(pageIndexView == 1) return Icon(Icons.record_voice_over);
    if(pageIndexView == 2) return Icon(Icons.group);
    if(pageIndexView == 8) return Icon(Icons.feed);;
    if(pageIndexView == 13) return Icon(Icons.question_mark);
    if(pageIndexView == 4) return Icon(Icons.category);
    if(pageIndexView == 5) return Icon(Icons.shopping_bag);
    if(pageIndexView == 12) return Icon(Icons.run_circle);
    if(pageIndexView == 7) return Icon(Icons.collections);
    if(pageIndexView == 10) return Icon(Icons.calendar_month);
    if(pageIndexView == 11) return Icon(Icons.location_on);
    if(pageIndexView == 6) return Icon(Icons.chat_bubble_outline);
    if(pageIndexView == 9) return Icon(Icons.query_stats);
    return Container();
  }

  //Function to select the page to load
  Widget pageSelector()
  {
    if(pageIndex == 0) return HomePro(brandId: currentBrand.id!, numTrainers: currentBrand.numTrainers!, numClients: currentBrand.numClients!);
    if(pageIndex == 1) return Trainers(brandId: currentBrand.id!, numTrainers: currentBrand.numTrainers!, );
    if(pageIndex == 2) return Clients(brandId: currentBrand.id!, numClients: currentBrand.numClients!,);
    if(pageIndex == 4) return Categories(brandId: currentBrand.id!);
    if(pageIndex == 5) return Bonos(brandId: currentBrand.id!);
    if(pageIndex == 7) return Content(brandId: currentBrand.id!);
    if(pageIndex == 8) return BrandInfo(locale: Localizations.localeOf(context), brandId: currentBrand.id!);
    if(pageIndex == 12) return Logo(brandId: currentBrand.id!);
    if(pageIndex == 10) return BrandCalendarWeekWidget(
      brandId: currentBrand.id!,
      height: safeAreaHeight*0.68,
      width: safeAreaWidth*0.88,
    ); //return SesionsPro();
    if(pageIndex == 11) return Locations(brandId: currentBrand.id!);
    return Container();
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
    initVariables();
    return mambaProfessional ?  Scaffold(
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.06, horizontal: MediaQuery.of(context).size.width*0.08),
                  child: Container(
                    //color: Theme.of(context).primaryColorDark,
                    decoration: new BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0),
                          bottomLeft: const Radius.circular(10.0),
                          bottomRight: const Radius.circular(10.0),
                        ),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.exit_to_app, size: MediaQuery.of(context).size.width*0.06, color: Theme.of(context).primaryColor),
                      onPressed:() => {
                        setState(() {
                          mambaProfessional = false;
                        }),
                      },
                    ),
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
            ListTile(
                leading: iconSelector(0),
                title: Text('Home'),
                onTap: () =>  {
                  Navigator.pop(context),
                  setState(() {
                    pageIndex = 0;
                    setFavourites();
                  }),
                }
            ),
            ListView.builder(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.003),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: favourites.length,
                itemBuilder: (context, index) {
                  int favourite =  favourites[index];
                  return ListTile(
                      leading: iconSelector(favourite),
                      title: titlePageSelectorListView(favourite),
                      onTap: () =>
                      {
                        Navigator.pop(context),
                        setState(() {
                          pageIndex = favourite;
                          setFavourites();
                        }),
                      }
                  );
                }
            ),

            ListTile(
              title: Row(
                children: [
                  Icon(IconWho,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text('Quien'),
                ],
              ),
              onTap: () => setState(() {
                seeNextWho = !seeNextWho;
                if(IconWho == Icons.keyboard_arrow_up) IconWho = Icons.keyboard_arrow_down;
                else IconWho = Icons.keyboard_arrow_up;
              }),
            ),
            seeNextWho ?
            ListTile(
                leading: iconSelector(1),
                title: Text(AppLocalizations.of(context)!.trainers),
                onTap: () =>
                {
                  Navigator.pop(context),
                  setState(() {
                    pageIndex = 1;
                    setFavourites();

                  }),
                }
            ) : Container(),
            seeNextWho ? ListTile(
                leading: iconSelector(2),
                title: Text(AppLocalizations.of(context)!.clients),
                onTap: () => {
                  Navigator.pop(context),
                  setState(() {
                    pageIndex = 2;
                    setFavourites();
                  }),
                }
            ) : Container(),


            ListTile(
              title: Row(
                children: [
                  Icon(IconWhat),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text('Que'),
                ],
              ),
              onTap: () => setState(() {
                seeNextWhat = !seeNextWhat;
                if(IconWhat == Icons.keyboard_arrow_up) IconWhat = Icons.keyboard_arrow_down;
                else IconWhat = Icons.keyboard_arrow_up;
              }),
            ),
            seeNextWhat ?
            ListTile(
              leading: iconSelector(8),
              title: Text(AppLocalizations.of(context)!.information),
              onTap: () => {
                Navigator.pop(context),
                setState(() {
                  pageIndex = 8;
                  setFavourites();
                }),
              },
            ) : Container(),
            seeNextWhat ? ListTile(
              leading: iconSelector(12),
              title: Text(AppLocalizations.of(context)!.logo),
              onTap: () => {
                Navigator.pop(context),
                setState(() {
                  pageIndex = 12;
                  setFavourites();
                }),
              },
            ) : Container(),
            seeNextWhat ? ListTile(
              leading: iconSelector(4),
              title: Text(AppLocalizations.of(context)!.categories),
              onTap: () => {
                Navigator.pop(context),
                setState(() {
                  pageIndex = 4;
                  setFavourites();
                }),
              },
            ) : Container(),
            seeNextWhat ? ListTile(
              leading: iconSelector(5),
              title: Text(AppLocalizations.of(context)!.bonos),
              onTap: () => {
                Navigator.pop(context),
                setState(() {
                  pageIndex = 5;
                  setFavourites();
                }),
              },
            ) : Container(),


            ListTile(
              title: Row(
                children: [
                  Icon(IconHow),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text('Como'),
                ],
              ),
              onTap: () => setState(() {
                seeNextHow = !seeNextHow;
                if(IconHow == Icons.keyboard_arrow_up) IconHow = Icons.keyboard_arrow_down;
                else IconHow = Icons.keyboard_arrow_up;
              }),
            ),
            seeNextHow ?
            ListTile(
              leading: iconSelector(9),
              title: Text(AppLocalizations.of(context)!.stats),
              onTap: () => {
                Navigator.pop(context),
                setState(() {
                  pageIndex = 9;
                  setFavourites();
                }),
              },
            ) : Container(),
            seeNextHow ? ListTile(
              leading: iconSelector(7),
              title: Text(AppLocalizations.of(context)!.content),
              onTap: () => {
                Navigator.pop(context),
                setState(() {
                  pageIndex = 7;
                  setFavourites();
                }),
              },
            ) : Container(),
            seeNextHow ? ListTile(
              leading: iconSelector(6),
              title: Text(AppLocalizations.of(context)!.opinions),
              onTap: () => {
                Navigator.pop(context),
                setState(() {
                  pageIndex = 6;
                  setFavourites();
                }),
              },
            ) : Container(),
            seeNextHow ? ListTile(
              leading: iconSelector(13),
              title: Text(AppLocalizations.of(context)!.feedback),
              onTap: () => {
                Navigator.pop(context),
                setState(() {
                  pageIndex = 13;
                  setFavourites();
                }),
              },
            ) : Container(),


            ListTile(
              title: Row(
                children: [
                  Icon(IconWhen),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text('Cuando'),
                ],
              ),
              onTap: () => setState(() {
                seeNextWhen = !seeNextWhen;
                if(IconWhen == Icons.keyboard_arrow_up) IconWhen = Icons.keyboard_arrow_down;
                else IconWhen = Icons.keyboard_arrow_up;
              }),
            ),
            seeNextWhen ?
            ListTile(
              leading: iconSelector(10),
              title: Text(AppLocalizations.of(context)!.calendar),
              onTap: () => {
                Navigator.pop(context),
                setState(() {
                  pageIndex = 10;
                  setFavourites();
                }),
              },
            ) : Container(),

            ListTile(
              title: Row(
                children: [
                  Icon(IconWhere),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01),
                  Text('Donde'),
                ],
              ),
              onTap: () => setState(() {
                seeNextWhere = !seeNextWhere;
                if(IconWhere == Icons.keyboard_arrow_up) IconWhere = Icons.keyboard_arrow_down;
                else IconWhere = Icons.keyboard_arrow_up;
              }),
            ),
            seeNextWhere ?
            ListTile(
              leading: iconSelector(11),
              title: Text(AppLocalizations.of(context)!.locations),
              onTap: () => {
                Navigator.pop(context),
                setState(() {
                  pageIndex = 11;
                  setFavourites();
                }),
              },
            ) : Container(),

/*
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => null,
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Policies'),
              onTap: () => null,
            ),
            Divider(),
            ListTile(
              title: Text('Exit'),
              leading: Icon(Icons.exit_to_app),
              onTap: () => null,
            ),

 */
          ],
        ),
      ),
      appBar: AppBar(
        title: titlePageSelector(),
        centerTitle: true,
        actions: [
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
          ),
        ],
      ),
      body: pageSelector(),
    ) : Scaffold(
      appBar: null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        iconSize: MediaQuery.of(context).size.height*0.04,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 3.0),
              child: Icon(Icons.home_filled),
            ),
            label: AppLocalizations.of(context)!.homeBottomNav,
            //backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 3.0),
              child: Icon(Icons.groups),
            ),
            label: AppLocalizations.of(context)!.brandBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 3.0),
              child: Icon(Icons.calendar_month_outlined),
            ),
            label: AppLocalizations.of(context)!.sesionsBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 3.0),
              child: CircularImage(
                size: MediaQuery.of(context).size.height*0.04,
                image: currentUser.imageUrl!,
                borderWidth: 1,
                color: currentIndex == 3 ? Theme.of(context).primaryColor : AppColors.grey.withOpacity(0.5),
              ),
            ),
            label: AppLocalizations.of(context)!.profileBottomNav,
            //backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
        onTap: (index) {
          _onTappedBar(index);
        },
        showUnselectedLabels: true,
        selectedItemColor: Theme.of(context).primaryColor,
        selectedLabelStyle: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10, color:Theme.of(context).primaryColor),
        selectedIconTheme: IconThemeData(
            color: Theme.of(context).primaryColor
        ),
        unselectedItemColor: AppColors.grey.withOpacity(0.5),
        unselectedLabelStyle: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10, color: AppColors.grey.withOpacity(0.5)),
        unselectedIconTheme: IconThemeData(
            color: AppColors.grey.withOpacity(0.5)
        ),
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        //allowImplicitScrolling: true,
        children: <Widget>[
          Homepage(),
          BrandWrapperPage(),
          Sesions(),
          Profile(),
        ],
        onPageChanged: (page) async {
          unreadNotifications = await _userDataService.getUnreadNotifications(currentUser.id!);
          unreadChats = await _userDataService.getUnreadConversations(currentUser.id!);
          // Check User´s Brand List
          List<Brand> brands = await _brandDataService.getAllBrandsFromUser(currentUser.id!);
          currentUser.setBrandList = brands;
          // Check If User has New Brand
          if (hasBrand == false && currentUser.brandsList.isNotEmpty) {
            setState(() {
              currentIndex = 1;
            });
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute<Null>(
                  builder: (context) => SplashScreen(),
                  settings: RouteSettings(name: 'SplashScreen'),
                )
            );
          } else if (hasBrand == true && currentUser.brandsList.isEmpty)  {
            setState(() {
              currentIndex = 1;
            });
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute<Null>(
                  builder: (context) => SplashScreen(),
                  settings: RouteSettings(name: 'SplashScreen'),
                )
            );
          }
          setState(() {
            currentIndex = page;
          });
        },
      ),
    );
  }

  Future<void> _onTappedBar(int value) async {
    setState(() {
      currentIndex = value;
    });
    pageController.jumpToPage(value);
  }
}

