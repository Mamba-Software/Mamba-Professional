// ignore_for_file: avoid_print

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/AdminService/SettingsDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Room/RoomDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/ChatCore.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/Notifications.dart';
import 'package:mamba_castelldefels/Globals/Permissions/PermisionsService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/MambaProSelector/MambaProUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/SharePlus/SharePlusUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/ConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/HomeDialogs/AppUpdateDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/HomeDialogs/BrandInviteDialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/NoBrandScreens/BrandIntroScreen.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/NoBrandScreens/RegistrarMarca.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/Profile.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/ProfileScreens/Settings/Settings.dart';
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

  bool isLoading = true;

  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _eventDataService = EventDataService();
  final _roomDataService=  RoomDataService();
  final _brandDataService = BrandDataService();
  final _mambaProUtils = MambaProUtils();

  final CalendarController _controller = CalendarController();

  //Icon to know if it's on favourites
  bool iconStar = false;
  bool isFirstBuild = true;

  // Bools to control show for drop down
  bool seeNextWho = true;
  bool seeNextWhat = true;
  bool seeNextHow = true;
  bool seeNextWhen = true;
  bool seeNextWhere = true;

  // Icons for drop down
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
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  // Function to get the favourites of the user
  void getFavourites() async {
    favourites = await _userDataService.getUserFavourites(currentBrand.id!, currentUser.id!);
    if (favourites.contains(pageIndex)) iconStar = true;
    if (isLoading && favourites.isNotEmpty) {
      setState(() {
        seeNextWho = false;
        seeNextWhat = false;
        seeNextHow = false;
        seeNextWhen = false;
        seeNextWhere = false;
        isLoading = false;
      });
    }
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
  void navigateToSettingsScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => const Settings(),
        )
    ).whenComplete(() {
      getFavourites();
    });
  }

  //Return the ListTile of each screen of Mamba Pro
  Widget listTilePro(int _pageIndex, [bool isFavourite = false]) {
    if (_pageIndex == 0) {
      return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.1,
            image: currentBrand.logoUrl,
          ),
          title: Text(
            currentBrand.name!,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          onTap: () =>  {
            Navigator.pop(context),
            setState(() {
              pageIndex = _pageIndex;
              setFavourites();
            }),
          }
      );
    } else {
      return ListTile(
          leading: _mambaProUtils.iconSelector(context, _pageIndex),
          title:  _mambaProUtils.titlePageSelectorListView(context, _pageIndex),
          trailing: isFavourite ? SizedBox(
            width: safeAreaWidth*0.15,
            child: IconButton(
                onPressed: () {
                  setState(() {
                    if (pageIndex == _pageIndex) {
                      iconStar = false;
                    }
                    favourites.remove(_pageIndex);
                    favourites.sort();
                    _userDataService.addFavouriteToUser(currentBrand.id!, currentUser.id!, favourites);
                  }
                  );
                },
                icon: Icon(
                  Icons.push_pin,
                  color: AppColors.red,
                  size: MediaQuery.of(context).size.width*0.06,
                )
            ),
          ) : SizedBox(
            width: safeAreaWidth*0.15,
          ),
          onTap: () =>  {
            Navigator.pop(context),
            setState(() {
              pageIndex = _pageIndex;
              setFavourites();
            }),
          }
      );
    }
  }

  Widget buildHeader() {
    return Container(
      height: safeAreaHeight*0.36,
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
                SizedBox(height: safeAreaHeight * 0.07),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircularImage(
                      size: safeAreaHeight * 0.1,
                      image: currentUser.imageUrl,
                      color: Theme.of(context).primaryColor,
                      borderWidth: 1,
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
              ],
            ),
          ),
          SizedBox(height: safeAreaHeight * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
            child: TextButton(
              onPressed: navigateToSettingsScreen,
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: safeAreaWidth * 0.025),
                  Text(
                      AppLocalizations.of(context)!.settings,
                      style: Theme.of(context).textTheme.bodyText2
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBrandListOptions() {
    return Column(
      children: [
        listTilePro(0),
        ListView.builder(
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.003),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: favourites.length,
            itemBuilder: (context, index) {
              int favourite =  favourites[index];
              return listTilePro(favourite, true);
            }
        ),

        Divider(color: Theme.of(context).primaryColor, thickness: 0, height: 1),
        ListTile(
          title: Row(
            children: [
              Icon(
                iconWho,
                color: Theme.of(context).primaryColorLight,
              ),
              SizedBox(width: MediaQuery.of(context).size.width*0.03),
              Text(
                AppLocalizations.of(context)!.quien,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).primaryColorLight, fontWeight: FontWeight.w700),
              ),
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
        seeNextWho ? listTilePro(2) : Container(),
        seeNextWho ? listTilePro(1) : Container(),
        seeNextWho ? listTilePro(15) : Container(),

        //Divider(color: Theme.of(context).backgroundColor, thickness: 1, indent: MediaQuery.of(context).size.width*0.03, endIndent: MediaQuery.of(context).size.width*0.03),
        ListTile(
          title: Row(
            children: [
              Icon(
                iconWhat,
                color: Theme.of(context).primaryColorLight,
              ),
              SizedBox(width: MediaQuery.of(context).size.width*0.03),
              Text(
                AppLocalizations.of(context)!.que,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).primaryColorLight, fontWeight: FontWeight.w700),
              ),
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
        seeNextWhat ? listTilePro(8) : Container(),
        seeNextWhat ? listTilePro(12) : Container(),
        //seeNextWhat ? listTilePro(4) : Container(),
        seeNextWhat ? listTilePro(5) : Container(),

        //Divider(color: Theme.of(context).backgroundColor, thickness: 1, indent: MediaQuery.of(context).size.width*0.03, endIndent: MediaQuery.of(context).size.width*0.03),
        ListTile(
          title:  Row(
            children: [
              Icon(
                iconWhen,
                color: Theme.of(context).primaryColorLight,
              ),
              SizedBox(width: MediaQuery.of(context).size.width*0.03),
              Text(
                AppLocalizations.of(context)!.cuando,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).primaryColorLight, fontWeight: FontWeight.w700),
              ),
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
              Icon(
                iconHow,
                color: Theme.of(context).primaryColorLight,
              ),
              SizedBox(width: MediaQuery.of(context).size.width*0.03),
              Text(
                AppLocalizations.of(context)!.como,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).primaryColorLight, fontWeight: FontWeight.w700),
              ),
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
        //seeNextHow ? listTilePro(9) : Container(),
        seeNextHow ? listTilePro(7) : Container(),
        //seeNextHow ? listTilePro(6) : Container(),
        seeNextHow ? listTilePro(13) : Container(),
        //seeNextHow ? listTilePro(16) : Container(),


        ListTile(
          title: Row(
            children: [
              Icon(
                iconWhere,
                color: Theme.of(context).primaryColorLight,
              ),
              SizedBox(width: MediaQuery.of(context).size.width*0.03),
              Text(
                AppLocalizations.of(context)!.donde,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).primaryColorLight, fontWeight: FontWeight.w700),
              ),
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
        seeNextWhere ? listTilePro(11) : Container(),
        Divider(color: Theme.of(context).primaryColor, thickness: 0, height: 1),
      ],
    );
  }

  Widget buildBrandLeaveOption() {
    return currentUser.id != currentBrand.adminID ?
    ListTile(
        leading: Icon(Icons.logout, color: Colors.red, size: MediaQuery.of(context).size.width*0.07),
        title: Text(
          AppLocalizations.of(context)!.exitBrand,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.red),
        ),
        onTap: () async {
          // Leaves Brand
          var result = await showDialog(
              context: context,
              builder: (_) {
                return ConfirmationDialog(text: AppLocalizations.of(context)!.exitBrandConfirm);
              }
          );
          if (result) {
            NotificationService().userLeavesBrand(currentUser.id!, currentBrand.id!);
            await _eventDataService.deleteUserFromUpcomingEvents(currentUser.id!, currentUser.isTrainer!);
            await _brandDataService.deleteUserFromBrand(currentUser.id!, currentBrand.id!);
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute<void>(
                  builder: (context) => const SplashScreen(),
                  settings: const RouteSettings(name: 'SplashScreen'),
                )
            );
          }
        }
    )
        :
    ListTile(
        leading: Icon(Icons.delete_outline, color: Colors.red, size: MediaQuery.of(context).size.width*0.07),
        title: Text(
          AppLocalizations.of(context)!.deleteBrand,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.red),
        ),
        onTap: () async {
          var result = await showDialog(
              context: context,
              builder: (_) {
                return const DeleteBrandDialog();
              }
          );
          if (result) {
            // New DataBase
            await _brandDataService.deleteBrand(currentBrand.id!);
            await _roomDataService.deleteRoom(currentBrand.roomId!);
            currentUser.setBrandList = [];
            await Future.delayed(const Duration(seconds: 4));
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute<void>(
                  builder: (context) =>
                  const SplashScreen(),
                  settings: const RouteSettings(
                      name: 'SplashScreen'),
                )
            );
          }
        }
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
            // Header
            buildHeader(),
            Divider(color: Theme.of(context).primaryColor, thickness: 0, height: 1,),
            SizedBox(height: safeAreaHeight * 0.02),
            // Brand Options
            // TODO: Passer Rol en aquesta funció
            buildBrandListOptions(),
            // Leave/Delete Brand
            buildBrandLeaveOption(),
            SizedBox(height: safeAreaHeight * 0.05),
          ],
        ),
      ),
      appBar: AppBar(
        title: _mambaProUtils.titlePageSelector(context, pageIndex),
        centerTitle: true,
        actions: [
          pageIndex == 10 ? IconButton(
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
              icon: pageIndex == 0 ? Container() :
              Icon(
                iconStar ? Icons.push_pin : Icons.push_pin_outlined,
                color: iconStar ? AppColors.red : Theme.of(context).primaryColor.withOpacity(0.5),
                size: MediaQuery.of(context).size.width*0.06,
              ),
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
                  _userDataService.addFavouriteToUser(currentBrand.id!, currentUser.id!, favourites);
                }
                );
              },
            ),
          )
        ],
      ),
      body: isLoading ? LoadingView() :
      _mambaProUtils.pageSelector(context,pageIndex, currentBrand.id!, currentBrand.numTrainers!, currentBrand.numClients!, _controller,safeAreaWidth, safeAreaHeight),
    );
  }
}

class DeleteBrandDialog extends StatefulWidget {
  const DeleteBrandDialog({Key? key}) : super(key: key);

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteBrandDialog> {

  // Delete Alert
  bool firstBuild = true;
  bool canDelete = false;
  bool wrongPassword = false;
  String deleteTemp = "";
  var deleteController;

  @override
  Widget build(BuildContext context) {
    if(firstBuild) {
      deleteTemp = "";
      firstBuild = false;
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 10.0),
                  child: Text(AppLocalizations.of(context)!.deleteBrandConfirmation, style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                ),
                Flexible(
                  child: Text("${AppLocalizations.of(context)!.writeDeleteBrand} ", style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center,),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                Flexible(
                  child: Text(currentBrand.name!, style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 15, right: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Flexible(
                        child: TextFormField(
                          controller: deleteController,
                          onChanged: (val) {
                            setState(() => {
                              deleteTemp = val
                            });
                            if (deleteTemp != currentBrand.name) {
                              setState(() => {
                                canDelete = false
                              });
                            } else {
                              setState(() => {
                                canDelete = true
                              });
                            }
                          },
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.red),
                          decoration: InputDecoration(
                            hintText: currentBrand.name,
                            hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.red.withOpacity(0.5)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: "32",
                        label: Text(AppLocalizations.of(context)!.delete, style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),),
                        icon: Icon(Icons.delete_outline, size: MediaQuery.of(context).size.width*0.06,),
                        backgroundColor: canDelete ? Colors.red : Colors.red[200],
                        foregroundColor: AppColors.white,
                        onPressed: canDelete ? () async  {
                          Navigator.pop(context, true);
                        } : null,
                      ),
                      FloatingActionButton.extended(
                        heroTag: "33",
                        icon: Icon(Icons.cancel_outlined, size: MediaQuery.of(context).size.width*0.06,),
                        label: Text(AppLocalizations.of(context)!.cancel, style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark),),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(context).primaryColorDark,
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                top: -90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: const Size(100, 100), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Colors.red, // button color
                          child: InkWell(
                            onTap: () async {
                              setState(() {});
                            },
                            child: const Icon(Icons.delete_outline_outlined, color: Colors.white, size: 60,), // icon
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }

  String splitCommonName(String name) {
    List<String> aux = name.split(" ");
    return aux[0];
  }
}

