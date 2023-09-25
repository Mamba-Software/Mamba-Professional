// ignore_for_file: avoid_print
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/ShareBrandLink.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/04-Quan/010-Calendar/BrandCalendarWidget_old.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/ConfirmationDialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteBrandDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:mamba_castelldefels/Auth/views/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/000-Home/HomePro.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/RolesInfo.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/Trainers.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/002-Clients/Clients.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/MembershipRequestsPro.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/Bonos.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/008-Information/BrandInfo.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/009%20-%20Stats/Stats.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/03-Com/007-Contenido/BrandImages.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/04-Quan/010-Calendar/BrandEventsCubit/BrandEventsCubit.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/04-Quan/014-Historial/BrandEventHistoryPage.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/05-On/011-Locations/Locations.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/Profile.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/ProfileScreens/Settings/Settings.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../Globals/Widgets/GroupOfComponents/PayWall/BrandSubscription.dart';
import '../../../Globals/Widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';

// HomePage for the App. Here the user can change between the diferent pages.
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class BrandScreen extends StatefulWidget {
  const BrandScreen({Key? key}) : super(key: key);

  @override
  _BrandScreenState createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  
  bool isLoading = false;

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

  //favourite tabs of user
  List<int> favourites = [];

  // DateTime // Calendar View For Navigation Purposes
  DateTime? calendarDateTime;
  CalendarView? calendarView;

  @override
  void initState() {
    super.initState();
    //getFavourites();
  }

  //Return the ListTile of each screen of Mamba Pro
  Widget listTilePro(int _pageIndex, [bool isFavourite = false]) {
    if (_pageIndex == 0) {
      return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.07,
            image: currentBrand.logoUrl,
            borderWidth: 1,
            color: AppColors.grey,
          ),
          title: Text(
            currentBrand.name!,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          onTap: () =>  {
            Navigator.pop(context),
            setBrandActive(),
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
          /*
          trailing: isFavourite ? SizedBox(
            width: MediaQuery.of(context).size.width*0.15,
            child: IconButton(
                onPressed: () {
                  setState(() {
                    if (pageIndex == _pageIndex) {
                      iconStar = false;
                    }
                    favourites.remove(_pageIndex);
                    favourites.sort();
                    _userDataService.addFavouriteToUser(currentBrand.id!, currentUser.id!, favourites);
                    switch (pageIndex) {
                      case 9:
                        mixpanel!.track('drawer_stats_pinned_off');
                        break;
                      case 2:
                        mixpanel!.track('drawer_clients_pinned_off');
                        break;
                      case 1:
                        mixpanel!.track('drawer_trainers_pinned_off');
                        break;
                     // case 15:
                        mixpanel!.track('drawer_membership_requests_pinned_off');
                        break;
                      case 8:
                        mixpanel!.track('drawer_brand_info_pinned_off');
                        break;
                      case 5:
                        mixpanel!.track('drawer_bonos_pinned_off');
                        break;
                      case 10:
                        mixpanel!.track('drawer_calendar_pinned_off');
                        break;
                      case 14:
                        mixpanel!.track('drawer_event_history_pinned_off');
                        break;
                      case 7:
                        mixpanel!.track('drawer_images_pinned_off');
                        break;
                      case 11:
                        mixpanel!.track('drawer_locations_pinned_off');
                        break;
                      default:
                        break;
                    }
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
            width: MediaQuery.of(context).size.width*0.15,
          ),
           */
          onTap: () =>  {
            Navigator.pop(context),
            setBrandActive(),
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
      height: MediaQuery.of(context).size.height*0.25,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkGrey,
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration:
            BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(currentBrand.baseImage!),
                )
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height*0.25,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                begin: FractionalOffset.bottomCenter,
                end: FractionalOffset.topCenter,
                colors: [
                  AppColors.darkerGrey,
                  AppColors.darkerGrey.withOpacity(0.95),
                  AppColors.darkerGrey.withOpacity(0.9),
                  AppColors.darkerGrey.withOpacity(0.85),
                  AppColors.darkerGrey.withOpacity(0.8),
                  AppColors.darkerGrey.withOpacity(0.7),
                ],
                stops: const [
                  0.2,
                  0.3,
                  0.4,
                  0.5,
                  0.75,
                  1.0,
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03, vertical: MediaQuery.of(context).size.width*0.05),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircularImage(
                    size: MediaQuery.of(context).size.width*0.15,
                    image: currentBrand.logoUrl,
                    borderWidth: 0.5,
                    color: AppColors.white,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.03,),
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width*0.15,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              currentBrand.name!,
                              style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: navigateToRolesInformationModal,
                                  child: Text(
                                    returnBrandRoleString(),
                                    textAlign: TextAlign.left,
                                    style: Theme.of(context).textTheme.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.qr_code, color: AppColors.white, size: 14,),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context)!.invite,
                                      style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white),
                                    ),
                                  ],
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.white.withOpacity(0.3),
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  shape: RoundedRectangleBorder(  // add this
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: Size(30, 20),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => navigateShareBrandLink(),
                              )
                            ],
                          ),


                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          /*
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
                    GestureDetector(
                      onTap: navigateToProfileScreen,
                      child: CircularImage(
                        size: MediaQuery.of(context).size.height * 0.1,
                        image: currentUser.imageUrl,
                        color: AppColors.white,
                        borderWidth: 1,
                      ),
                    ),

                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Text(
                    currentUser.firstName! + ' ' + currentUser.lastName!,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline1?.copyWith(color:AppColors.white,fontWeight: FontWeight.normal),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                TextButton(
                  onPressed: navigateToRolesInformationModal,
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft),
                  child: Text(
                    returnBrandRoleString(),
                    textAlign: TextAlign.left,
                    //style: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondary),
                    style: Theme.of(context).textTheme.caption,
                  )
                ),
              ],
            ),
          ),
           */
        ],
      ),
    );
  }

  String returnBrandRoleString() {
    switch (currentUser.brandRole) {
      case 1:
        if (currentBrand.adminID == currentUser.id) {
          return StringUtils().toCapitalized(AppLocalizations.of(context)!.paySubscriptionDesc.split(" ")[2]);
        } else {
          return AppLocalizations.of(context)!.owner;
        }
      case 2:
        return AppLocalizations.of(context)!.administrador;
      case 3:
        return AppLocalizations.of(context)!.trainer;
      default:
        return AppLocalizations.of(context)!.trainer;
    }
  }

  Widget buildBrandListOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*
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
         */
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04),
          child: Text(
            AppLocalizations.of(context)!.management,
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        listTilePro(10),
        listTilePro(5),
        listTilePro(9),


        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04),
          child: Text(
            AppLocalizations.of(context)!.members,
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        listTilePro(2),
        listTilePro(1),
        //currentUser.brandRole < 3 ? listTilePro(15) : Container(),

        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04),
          child: Text(
            AppLocalizations.of(context)!.yourBrand,
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        listTilePro(17),
        listTilePro(7),
        listTilePro(11),
        listTilePro(8),
        //listTilePro(14),
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
    return currentUser.brandRole < 2 ?
    ListTile(
        leading: Icon(Icons.delete_outline, color: Colors.red, size: MediaQuery.of(context).size.width*0.07),
        title: Text(
          AppLocalizations.of(context)!.deleteBrand,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.red),
        ),
        onTap: () async {
          mixpanel!.track('delete_brand_dialog_open');
          var result = await showDialog(
              context: context,
              builder: (_) {
                return const DeleteBrandDialog();
              }
          );
          if (result) {
            mixpanel!.track('delete_brand_confirmed');
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
    ) :
    ListTile(
        leading: Icon(Icons.logout, color: Colors.red, size: MediaQuery.of(context).size.width*0.07),
        title: Text(
          AppLocalizations.of(context)!.exitBrand,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.red),
        ),
        onTap: () async {
          mixpanel!.track('exit_brand_dialog_open');
          // Leaves Brand
          var result = await showDialog(
              context: context,
              builder: (_) {
                return ConfirmationDialog(text: AppLocalizations.of(context)!.exitBrandConfirm);
              }
          );
          if (result) {
            mixpanel!.track('exit_brand_confirmed');
            setState(() {
              isLoading = true;
            });
            pageIndex = 10;
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
    );
  }

  Widget buildBodyNavigation() {
    switch (pageIndex) {
      case 0:
        mixpanel!.track('brand_homepage_view');
        return HomePro(
            brandId: currentBrand.id!,
            numTrainers: currentBrand.numTrainers!,
            numClients: currentBrand.numClients!,
            navigateToPage: (int page, [DateTime? dateTime, CalendarView? calendarView]) async {
              setState(() {
                calendarDateTime = dateTime;
                this.calendarView = calendarView;
                pageIndex = page;
              });
              await Future.delayed(const Duration(seconds: 2));
              setState(() {
                calendarDateTime = null;
                this.calendarView = null;
              });
            },
        );
      case 9:
        mixpanel!.track('brand_stats_view');
        return Stats(
          brandId: currentBrand.id!,
          pinned: iconStar,
          initIndex: 0,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 2:
        mixpanel!.track('brand_clients_view');
        return Clients(
          brandId: currentBrand.id!,
          numClients: currentBrand.numClients!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 1:
        mixpanel!.track('brand_trainers_view');
        return Trainers(
          brandId: currentBrand.id!,
          numTrainers: currentBrand.numTrainers!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 8:
        mixpanel!.track('brand_info_view');
        return BrandInfo(
          locale: Localizations.localeOf(context),
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 5:
        mixpanel!.track('brand_bonos_view');
        return BonosPro(
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 10:
        mixpanel!.track('brand_calendar_view');
        return BrandCalendarWidget(
          brandId: currentBrand.id!,
          dateTime: calendarDateTime,
          calendarView: calendarView,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 7:
        mixpanel!.track('brand_images_view');
        return BrandImages(
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 11:
        mixpanel!.track('brand_locations_view');
        return Locations(
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      case 17:
        mixpanel!.track('brand_subscription_view');
        return BrandSubscription(
          locale: Localizations.localeOf(context),
          brandId: currentBrand.id!,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
      default:
        mixpanel!.track('brand_homepage_view');
        return BrandCalendarWidget(
          brandId: currentBrand.id!,
          dateTime: calendarDateTime,
          calendarView: calendarView,
          pinned: iconStar,
          pinnedChanged: (boolean) {
            handleChangedFavourites();
          },
        );
        return HomePro(
          brandId: currentBrand.id!,
          numTrainers: currentBrand.numTrainers!,
          numClients: currentBrand.numClients!,
          navigateToPage: (int page, [DateTime? dateTime, CalendarView? calendarView, bool? addGroupEvent, bool? addPrivateEvent, bool? createBono]) async {
            setState(() {
              calendarDateTime = dateTime;
              this.calendarView = calendarView;
              pageIndex = page;
            });
            await Future.delayed(const Duration(seconds: 2));
            setState(() {
              calendarDateTime = null;
              this.calendarView = null;
            });
          },
        );
    }
  }

  // updateChatsAndNotifications
  /*void updateChatsAndNotifications() async {
    // Unread Chats
    unreadChats = await _userDataService.getUnreadConversations(currentUser.id!);
    // Unread Notifications
    unreadNotifications = await _userDataService.getUnreadNotifications(currentUser.id!);
    setState(() {});
  } */

  // Navigate to Bonos Request Screen
  void navigateToRolesInformationModal() async {
    mixpanel!.track('drawer_trainer_roles_info');
    showModalBottomSheet<bool?>(
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
            heightFactor: 0.935,
            child: RolesInfo()
        );
      },
    );
  }

  Future<void> navigateShareBrandLink() async {
    showModalBottomSheet<void>(
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
          heightFactor: 0.8,
          child: ShareBrandLink(),
        );
      },
    );
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        /*
        BlocProvider<BrandSuscriptionCubit>(
          create: (_) => BrandSuscriptionCubit(),
          lazy: false,
        ),*/
        BlocProvider<BrandEventsCubit>(
          create: (_) => BrandEventsCubit(),
          lazy: true,
        ),
      ],
      child: Scaffold(
        key: mambaProScaffoldKey,
        drawer: Drawer(
          backgroundColor: Theme.of(context).primaryColorDark,
          child: ListView(
            physics: const ClampingScrollPhysics(),
            // Remove padding
            padding: EdgeInsets.zero,
            children: [
              // Header
              buildHeader(),
              const Divider(color: AppColors.grey, thickness: 0, height: 1,),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              // Brand Options
              buildBrandListOptions(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              //Divider(color: Theme.of(context).primaryColor, thickness: 0, height: 1),
              /*
              // Leave/Delete Brand
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              buildBrandLeaveOption(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              */
            ],
          ),
        ),
        body: isLoading ? LoadingView() : buildBodyNavigation() ,

      ),
    );
  }

  Future<void> navigateToSubscriptionsScreen() async {

    //mixpanel!.track('brand_membership_requests_view');
    var result = await Navigator.push(
        context,
        CupertinoPageRoute<bool?>(
          builder: (context) => PayWall(
            brandId: currentBrand.id!,
          ),
        )
    );
    if (result == null || result == true) {
      setState(() {
        isLoading = true;
      });
    }
  }

  /// DEPRECATED FAVOURITES

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

  // ICON Notifications Chat
  /*
  Row(
                      children: [
                        CounterBadgeIcon(
                          counter: unreadNotifications,
                          child: IconButton(
                            icon: Icon(Icons.notifications, color: AppColors.white , size: MediaQuery.of(context).size.width*0.07),
                            alignment: Alignment.centerRight,
                            onPressed: navigateToNotificationsScreen,
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                        CounterBadgeIcon(
                          counter: unreadChats,
                          child: IconButton(
                            icon: Icon(Icons.chat, color:  AppColors.white, size: MediaQuery.of(context).size.width*0.07),
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
   */

}


