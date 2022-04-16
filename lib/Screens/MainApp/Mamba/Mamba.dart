import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandPage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Home/Homepage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Sesions/Sesions.dart';
import '../../../Globals/Styles/Styles.dart';
import '../../../Globals/Widgets/Components/Images/CircularImage.dart';
import '../MambaPro/Trainers.dart';
import '../MambaPro/Clients.dart';
import '../MambaPro/HomePro.dart';
import 'Profile/Profile.dart';

// HomePage for the App. Here the user can change between the diferent pages.
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class MambaClient extends StatefulWidget {
  const MambaClient({Key? key}) : super(key: key);

  @override
  _MambaClientState createState() => _MambaClientState();
}

class _MambaClientState extends State<MambaClient> {

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

  //Bools to controll show for drop down
  bool seeNextWho = false;
  bool seeNextWhat = false;
  bool seeNextHow = false;
  bool seeNextWhen = false;
  bool seeNextWhere = false;

  //Icons for drop down
  var IconWho = Icons.keyboard_arrow_down;
  var IconWhat = Icons.keyboard_arrow_down;
  var IconHow = Icons.keyboard_arrow_down;
  var IconWhen = Icons.keyboard_arrow_down;
  var IconWhere = Icons.keyboard_arrow_down;

  //Index to know which page to load
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
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
          pageController.jumpToPage(currentIndex);
        } else {
          print("Not in Home Page, Moving to Splash Screen");
          String routeFromMessage = route.substring(0, route.length - 1);;
          currentIndex = int.parse(route[route.length-1]);
          Navigator.of(context).pushNamedAndRemoveUntil(routeFromMessage, (Route<dynamic> route) => false, arguments: currentIndex);
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

  void initVariables() async {
    isSwitched = mambaProfessional;
    if(mambaProfessional) textValue = "Desactivar Mamba pro";
    else textValue = "Activar Mamba pro";
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

  //Function to select the title of the page loaded
  Widget titlePageSelector()
  {
    if(pageIndex == 0)return Text(AppLocalizations.of(context)!.homeBottomNav, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 1)return Text(AppLocalizations.of(context)!.trainers, style: Theme.of(context).appBarTheme.titleTextStyle,);
    if(pageIndex == 2)return Text(AppLocalizations.of(context)!.clients, style: Theme.of(context).appBarTheme.titleTextStyle,);
    return Container();
  }

  //Function to select the page to load
  Widget pageSelector()
  {
    if(pageIndex == 0) return HomePro(brandId: currentBrand.id!, numTrainers: currentBrand.numTrainers!, numClients: currentBrand.numClients!);
    if(pageIndex == 1) return Trainers(brandId: currentBrand.id!, numTrainers: currentBrand.numTrainers!, );
    if(pageIndex == 2) return Clients(brandId: currentBrand.id!, numClients: currentBrand.numClients!,);
    return Container();
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
      Brand brand = currentUser.brandsList[0];
      currentBrand.setBasicData = await _brandDataService.getBrandDetails(brand.id!);
      currentBrand.setUserList = await _brandDataService.getBrandUsers(brand.id!);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    initVariables();
    return mambaProfessional ?  Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          // Remove padding
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(currentUser.firstName! + ' ' + currentUser.lastName!,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, backgroundColor: Colors.white)),
              accountEmail: Text('Administrator',
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, backgroundColor: Colors.white)),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.network(
                    currentUser.imageUrl!,
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                    opacity: 1,
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        currentBrand.logoUrl!)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home_filled),
              title: Text('Home'),
              onTap: () => null,
            ),
            Divider(),

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
                leading: Icon(
                  Icons.record_voice_over,
                ),
                title: Text(AppLocalizations.of(context)!.trainers),
                onTap: () =>
                {
                  Navigator.pop(context),
                  setState(() {
                    pageIndex = 1;
                  }),
                }
            ) : Container(),
            seeNextWho ? ListTile(
              leading: Icon(
                Icons.group,
              ),
              title: Text(AppLocalizations.of(context)!.clients),
              onTap: () => {
                Navigator.pop(context),
                setState(() {
                  pageIndex = 2;
                }),
              }
            ) : Container(),
            Divider(),


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
              leading: Icon(
                Icons.record_voice_over,
              ),
              title: Text('Información'),
              onTap: () => null,
            ) : Container(),
            seeNextWhat ? ListTile(
              leading: Icon(
                Icons.record_voice_over,
              ),
              title: Text('Categorias'),
              onTap: () => null,
            ) : Container(),
            seeNextWhat ? ListTile(
              leading: Icon(
                Icons.record_voice_over,
              ),
              title: Text('Bonos'),
              onTap: () => null,
            ) : Container(),
            Divider(),


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
              leading: Icon(
                Icons.record_voice_over,
              ),
              title: Text('Estadísticas'),
              onTap: () => null,
            ) : Container(),
            seeNextHow ? ListTile(
              leading: Icon(
                Icons.record_voice_over,
              ),
              title: Text('Contenido'),
              onTap: () => null,
            ) : Container(),
            seeNextHow ? ListTile(
              leading: Icon(
                Icons.record_voice_over,
              ),
              title: Text('Opiniones'),
              onTap: () => null,
            ) : Container(),
            Divider(),


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
              leading: Icon(
                Icons.record_voice_over,
              ),
              title: Text('Calendario'),
              onTap: () => null,
            ) : Container(),
            Divider(),

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
              title: Text('Ubicaciones'),
              onTap: () => null,
            ) : Container(),
            seeNextWhere ? ListTile(
              title: Text('Online'),
              onTap: () => null,
            ) : Container(),
            Divider(),

            ListTile(
              title: Row(
                children: [
                  Switch(
                    onChanged: toggleSwitch,
                    value: isSwitched,
                    activeColor: Styles.mainColor,
                    activeTrackColor: Styles.mainColor,
                    inactiveThumbColor: Styles.mainColorTrans,
                    inactiveTrackColor: Styles.mainColorTrans,
                  ),
                  Text(
                      textValue,
                      style: Theme.of(context).textTheme.bodyText2
                  ),
                ],
              ),
            )
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
          BrandPage(),
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

  @override
  void dispose() {
    super.dispose();
  }
}

