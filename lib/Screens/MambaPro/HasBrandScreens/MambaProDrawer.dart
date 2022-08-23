// ignore_for_file: avoid_print
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/ChatCore.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/Notifications.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/ProfileScreens/Settings/Settings.dart';
/*

class MambaProDrawer extends StatefulWidget {

  const MambaProDrawer({required Key key}) : super(key: key);

  @override
  _MambaProDrawerState createState() => _MambaProDrawerState();
}

class _MambaProDrawerState extends State<MambaProDrawer> {
  @override
  void initState() {
    super.initState();
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
    );
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
      height: MediaQuery.of(context).size.height*0.36,
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircularImage(
                      size: MediaQuery.of(context).size.height * 0.1,
                      image: currentUser.imageUrl,
                      color: Theme.of(context).primaryColor,
                      borderWidth: 1,
                    ),
                    Row(
                      children: [
                        CounterBadgeIcon(
                          counter: unreadNotifications,
                          child: IconButton(
                            icon: Icon(Icons.notifications, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.07),
                            alignment: Alignment.centerRight,
                            onPressed: navigateToNotificationsScreen,
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                        CounterBadgeIcon(
                          counter: unreadChats,
                          child: IconButton(
                            icon: Icon(Icons.chat, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.07),
                            alignment: Alignment.centerRight,
                            onPressed: navigateToChatScreen,
                          ),
                        ),
                        /*
                        IconButton(
                          icon: Icon(Icons.settings, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.06),
                          alignment: Alignment.centerRight,
                          onPressed: navigateToSettingsScreen,
                        ),
                         */
                      ],
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Text(
                    currentUser.firstName! + ' ' + currentUser.lastName!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.normal)
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                  SizedBox(width: MediaQuery.of(context).size.width * 0.025),
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
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Divider(color: Theme.of(context).primaryColor, thickness: 0, height: 2),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),

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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).primaryColorDark,
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          // Header
          buildHeader(),
          Divider(color: Theme.of(context).primaryColor, thickness: 0, height: 1,),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          // Brand Options
          // TODO: Passer Rol en aquesta funció
          buildBrandListOptions(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Divider(color: Theme.of(context).primaryColor, thickness: 0, height: 1),
          // Leave/Delete Brand
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          buildBrandLeaveOption(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        ],
      ),
    );
  }
}

*/


