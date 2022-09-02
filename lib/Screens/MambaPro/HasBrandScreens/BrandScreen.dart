// ignore_for_file: avoid_print
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Room/RoomDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/ChatCore.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/Notifications.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/MambaProSelector/MambaProUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/BrandCalendarWidget.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/ConfirmationDialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteBrandDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/000-Home/HomePro.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/Trainers.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/002-Clients/Clients.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/MembershipRequestsPro.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/Bonos.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/008-Information/BrandInfo.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/03-Com/007-Contenido/Content.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/04-Quan/014-Historial/BrandEventHistoryPage.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/05-On/011-Locations/Locations.dart';
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

  //Icon to know if it's on favourites
  bool iconStar = false;
  bool isFirstBuild = true;

  // Bools to control show for drop down
  bool seeNextWho = false;
  bool seeNextWhat = false;
  bool seeNextHow = false;
  bool seeNextWhen = false;
  bool seeNextWhere = false;

  // Icons for drop down
  var iconWho = Icons.keyboard_arrow_up;
  var iconWhat = Icons.keyboard_arrow_up;
  var iconHow = Icons.keyboard_arrow_up;
  var iconWhen = Icons.keyboard_arrow_up;
  var iconWhere = Icons.keyboard_arrow_up;

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
    if (favourites.contains(pageIndex)) {
      iconStar = true;
    }
    if (isLoading) {
      setState(() {
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
  void navigateToProfileScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => const Profile(),
        )
    );
  }

  // Function to Handle Favourites when User clicks on them
  void handleChangedFavourites() {
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
    });
  }

  //Return the ListTile of each screen of Mamba Pro
  Widget listTilePro(int _pageIndex, [bool isFavourite = false]) {
    if (_pageIndex == 0) {
      return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.07,
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
          leading: _mambaProUtils.iconSelectorListView(context, _pageIndex),
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
      height: safeAreaHeight*0.32,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkGrey,
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
                    GestureDetector(
                      onTap: navigateToProfileScreen,
                      child: CircularImage(
                        size: safeAreaHeight * 0.1,
                        image: currentUser.imageUrl,
                        color: AppColors.white,
                        borderWidth: 1,
                      ),
                    ),
                    Row(
                      children: [
                        CounterBadgeIcon(
                          counter: unreadNotifications,
                          child: IconButton(
                            icon: Icon(Icons.notifications, color: AppColors.white, size: safeAreaWidth*0.07),
                            alignment: Alignment.centerRight,
                            onPressed: navigateToNotificationsScreen,
                          ),
                        ),
                        SizedBox(width: safeAreaWidth * 0.03),
                        CounterBadgeIcon(
                          counter: unreadChats,
                          child: IconButton(
                            icon: Icon(Icons.chat, color: AppColors.white, size: safeAreaWidth*0.07),
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
                    style: Theme.of(context).textTheme.headline1?.copyWith(color:AppColors.white,fontWeight: FontWeight.normal)
                ),
                SizedBox(height: safeAreaHeight * 0.02),
                Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color:AppColors.white)
                ),
              ],
            ),
          ),
          /*
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
          */
        ],
      ),
    );
  }

  Widget buildBrandListOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        SizedBox(height: safeAreaHeight * 0.01),
        Divider(color: Theme.of(context).primaryColor, thickness: 0, height: 2),
        SizedBox(height: safeAreaHeight * 0.01),

        SizedBox(height: safeAreaHeight * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.04),
          child: Text(
            AppLocalizations.of(context)!.management,
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: safeAreaHeight * 0.01),
        listTilePro(10),
        listTilePro(5),
        listTilePro(14),

        SizedBox(height: safeAreaHeight * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.04),
          child: Text(
            AppLocalizations.of(context)!.members,
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: safeAreaHeight * 0.01),
        listTilePro(2),
        listTilePro(1),
        listTilePro(15),

        SizedBox(height: safeAreaHeight * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.04),
          child: Text(
            AppLocalizations.of(context)!.yourBrand,
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: safeAreaHeight * 0.01),
        listTilePro(8),
        listTilePro(7),
        listTilePro(11),



        /*
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
            // Clicked on Open/Close
            seeNextWho = !seeNextWho;
            if (iconWho == Icons.keyboard_arrow_up) {
              iconWho = Icons.keyboard_arrow_down;
            } else {
              iconWho = Icons.keyboard_arrow_up;
            }
            // Rest on Close
            seeNextWhen = false;
            seeNextWhat = false;
            seeNextHow = false;
            seeNextWhere = false;
            iconWhen = Icons.keyboard_arrow_up;
            iconWhat = Icons.keyboard_arrow_up;
            iconHow = Icons.keyboard_arrow_up;
            iconWhere = Icons.keyboard_arrow_up;
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
            // Clicked on Open/Close
            seeNextWhat = !seeNextWhat;
            if (iconWhat == Icons.keyboard_arrow_up) {
              iconWhat = Icons.keyboard_arrow_down;
            } else {
              iconWhat = Icons.keyboard_arrow_up;
            }
            // Rest on Close
            seeNextWho = false;
            seeNextWhen = false;
            seeNextHow = false;
            seeNextWhere = false;
            iconWho = Icons.keyboard_arrow_up;
            iconWhen = Icons.keyboard_arrow_up;
            iconHow = Icons.keyboard_arrow_up;
            iconWhere = Icons.keyboard_arrow_up;

          }),
        ),
        seeNextWhat ? listTilePro(8) : Container(),
        //seeNextWhat ? listTilePro(12) : Container(),
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
            // Clicked on Open/Close
            seeNextWhen = !seeNextWhen;
            if (iconWhen == Icons.keyboard_arrow_up) {
              iconWhen = Icons.keyboard_arrow_down;
            } else {
              iconWhen = Icons.keyboard_arrow_up;
            }
            // Rest on Close
            seeNextWho = false;
            seeNextWhat = false;
            seeNextHow = false;
            seeNextWhere = false;
            iconWho = Icons.keyboard_arrow_up;
            iconWhat = Icons.keyboard_arrow_up;
            iconHow = Icons.keyboard_arrow_up;
            iconWhere = Icons.keyboard_arrow_up;
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
            // Clicked on Open/Close
            seeNextHow = !seeNextHow;
            if (iconHow == Icons.keyboard_arrow_up) {
              iconHow = Icons.keyboard_arrow_down;
            } else {
              iconHow = Icons.keyboard_arrow_up;
            }
            // Rest on Close
            seeNextWhen = false;
            seeNextWhat = false;
            seeNextWho = false;
            seeNextWhere = false;
            iconWhen = Icons.keyboard_arrow_up;
            iconWhat = Icons.keyboard_arrow_up;
            iconWho = Icons.keyboard_arrow_up;
            iconWhere = Icons.keyboard_arrow_up;
          }),
        ),
        //seeNextHow ? listTilePro(9) : Container(),
        seeNextHow ? listTilePro(7) : Container(),
        //seeNextHow ? listTilePro(6) : Container(),
        //seeNextHow ? listTilePro(13) : Container(),
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
            // Clicked on Open/Close
            seeNextWhere = !seeNextWhere;
            if (iconWhere == Icons.keyboard_arrow_up) {
              iconWhere = Icons.keyboard_arrow_down;
            } else {
              iconWhere = Icons.keyboard_arrow_up;
            }
            // Rest on Close
            seeNextWhen = false;
            seeNextWhat = false;
            seeNextWho = false;
            seeNextHow = false;
            iconWhen = Icons.keyboard_arrow_up;
            iconWhat = Icons.keyboard_arrow_up;
            iconWho = Icons.keyboard_arrow_up;
            iconHow = Icons.keyboard_arrow_up;

          }),
        ),
        seeNextWhere ? listTilePro(11) : Container(),
         */

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
            setState(() {
              isLoading = true;
            });
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
            setState(() {
              isLoading = true;
            });
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

  Widget buildBodyNavigation() {
    switch (pageIndex) {
      case 0:
        return HomePro(
            brandId: currentBrand.id!,
            numTrainers: currentBrand.numTrainers!,
            numClients: currentBrand.numClients!
        );
      case 2:
        return Clients(
          brandId: currentBrand.id!,
          numClients: currentBrand.numClients!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 1:
        return Trainers(
          brandId: currentBrand.id!,
          numTrainers: currentBrand.numTrainers!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 15:
        return MembershipRequestsPro(
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 8:
        return BrandInfo(
          locale: Localizations.localeOf(context),
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 5:
        return BonosPro(
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 10:
        return BrandCalendarWidget(
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 14:
        return BrandEventHistoryPage(
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 7:
        return Content(
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 13:
        // Placeholder for Feedback
        return Content(
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 11:
        return Locations(
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      default:
        return HomePro(brandId: currentBrand.id!, numTrainers: currentBrand.numTrainers!, numClients: currentBrand.numClients!);
    }
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
      key: mambaProScaffoldKey,
      drawer: Drawer(
        backgroundColor: Theme.of(context).primaryColorDark,
        child: ListView(
          // Remove padding
          padding: EdgeInsets.zero,
          children: [
            // Header
            buildHeader(),
            Divider(color: AppColors.grey, thickness: 0, height: 1,),
            SizedBox(height: safeAreaHeight * 0.02),
            // Brand Options
            // TODO: Passer Rol en aquesta funció
            buildBrandListOptions(),
            SizedBox(height: safeAreaHeight * 0.015),
            Divider(color: Theme.of(context).primaryColor, thickness: 0, height: 1),
            // Leave/Delete Brand
            SizedBox(height: safeAreaHeight * 0.015),
            buildBrandLeaveOption(),
            SizedBox(height: safeAreaHeight * 0.05),
          ],
        ),
      ),
      body: isLoading ? LoadingView() : buildBodyNavigation() ,

    );
  }
}


