// ignore_for_file: avoid_print
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/data/DataService/Room/RoomDataService.dart';
import 'package:mamba_castelldefels/data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/events/Calendar/views/BrandCalendarWidget.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/notifications/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:mamba_castelldefels/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/commons/utils/MambaProSelector/MambaProUtils.dart';
import 'package:mamba_castelldefels/commons/utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/PayWall/BrandSubscription.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';
import 'package:mamba_castelldefels/screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/ShareBrandLink.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:mamba_castelldefels/screens/MambaPro/HasBrandScreens/000-Home/HomePro.dart';
import 'package:mamba_castelldefels/screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/RolesInfo.dart';
import 'package:mamba_castelldefels/screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/Trainers.dart';
import 'package:mamba_castelldefels/screens/MambaPro/HasBrandScreens/01-Qui/002-Clients/Clients.dart';
import 'package:mamba_castelldefels/screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/Bonos.dart';
import 'package:mamba_castelldefels/screens/MambaPro/HasBrandScreens/02-Que/007%20-%20Purchases/views/BrandPurchaseHistory.dart';
import 'package:mamba_castelldefels/screens/MambaPro/HasBrandScreens/02-Que/008-Information/BrandInfo.dart';
import 'package:mamba_castelldefels/screens/MambaPro/HasBrandScreens/02-Que/009%20-%20Stats/Stats.dart';
import 'package:mamba_castelldefels/screens/MambaPro/HasBrandScreens/03-Com/007-Contenido/BrandImages.dart';
import 'package:mamba_castelldefels/screens/MambaPro/HasBrandScreens/05-On/011-Locations/Locations.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// HomePage for the App. Here the user can change between the diferent pages.
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  _BrandScreenState createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  bool isLoading = false;

  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _eventDataService = EventDataService();
  final _roomDataService = RoomDataService();
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
  Widget listTilePro(int pageIndexVar, [bool isFavourite = false]) {
    return ListTile(
        leading: _mambaProUtils.iconSelectorListView(context, pageIndexVar),
        title: _mambaProUtils.titlePageSelectorListView(context, pageIndexVar),
        onTap: () => {
              Navigator.pop(context),
              setBrandActive(),
              setState(() {
                pageIndex = pageIndexVar;
                setFavourites();
              }),
            });
  }

  Widget buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkGrey,
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(currentBrand.baseImage!),
            )),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
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
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.03,
                  vertical: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircularImage(
                    size: MediaQuery.of(context).size.width * 0.15,
                    image: currentBrand.logoUrl,
                    borderWidth: 0.5,
                    color: AppColors.white,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.15,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              currentBrand.name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(color: AppColors.white),
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
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      AppColors.white.withOpacity(0.3),
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  shape: RoundedRectangleBorder(
                                    // add this
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: const Size(30, 20),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => navigateShareBrandLink(),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.qr_code,
                                      color: AppColors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context)!.invite,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: AppColors.white),
                                    ),
                                  ],
                                ),
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
        ],
      ),
    );
  }

  Widget buildBottomPayment() {
    return BlocBuilder<BrandSuscriptionCubit, BrandSuscriptionState>(
        builder: (context, state) {
      switch (state.runtimeType) {
        case BrandSuscriptionLoadedTrue:
          final suscriptionState = state as BrandSuscriptionLoadedTrue;
          int difference = state.subscription.endDate!
              .toDate()
              .difference(DateTime.now())
              .inDays;
          String date = DateTimeUtils().formatDateTimeToStringDDMMYY(
              state.subscription.endDate!.toDate());
          return suscriptionState.subscription.subscriptionId == "7DAYSTRIAL"
              ? Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  padding: const EdgeInsets.only(left: 4.0),
                  child: ListTile(
                      title: Text(AppLocalizations.of(context)!.freeTrial,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                      subtitle: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          AppLocalizations.of(context)!
                              .freeTrialDaysLeft(difference.toString()),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      onTap: () => {
                            Navigator.pop(context),
                            setBrandActive(),
                            setState(() {
                              pageIndex = 17;
                              setFavourites();
                            }),
                          }),
                )
              : Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  padding: const EdgeInsets.only(left: 4.0),
                  child: ListTile(
                      title: Text(AppLocalizations.of(context)!.monthlyPlan,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left),
                      subtitle: Text(
                        AppLocalizations.of(context)!
                            .monthlyPlanDayRenewal(date.toString()),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.left,
                      ),
                      onTap: () => {
                            Navigator.pop(context),
                            setBrandActive(),
                            setState(() {
                              pageIndex = 17;
                              setFavourites();
                            }),
                          }),
                );
        case BrandSuscriptionLoadedFalse:
          return Container(
            height: MediaQuery.of(context).size.height * 0.1,
            padding: const EdgeInsets.only(left: 4.0),
            child: ListTile(
                title: Text(AppLocalizations.of(context)!.chooseYourPlan,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left),
                subtitle: Text(
                  AppLocalizations.of(context)!.chooseYourPlanDesc,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.left,
                ),
                onTap: () => {
                      Navigator.pop(context),
                      setBrandActive(),
                      setState(() {
                        pageIndex = 17;
                        setFavourites();
                      }),
                    }),
          );
        default:
          return Container();
      }
    });
  }

  String returnBrandRoleString() {
    switch (currentUser.brandRole) {
      case 1:
        if (currentBrand.adminID == currentUser.id) {
          return StringUtils().toCapitalized(
              AppLocalizations.of(context)!.paySubscriptionDesc.split(" ")[2]);
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
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04),
          child: Text(
            AppLocalizations.of(context)!.management,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        listTilePro(10),
        listTilePro(18),
        listTilePro(9),

        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04),
          child: Text(
            AppLocalizations.of(context)!.yourBrand,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        listTilePro(5),
        listTilePro(2),
        listTilePro(1),
        //currentUser.brandRole < 3 ? listTilePro(15) : Container(),

        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04),
          child: Text(
            AppLocalizations.of(context)!.information,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        //listTilePro(17),
        listTilePro(8),
        listTilePro(7),
        listTilePro(11),
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

  Widget buildBodyNavigation() {
    print(pageIndex);
    switch (pageIndex) {
      case 0:
        mixpanel!.track('brand_homepage_view');
        return HomePro(
          brandId: currentBrand.id!,
          numTrainers: currentBrand.numTrainers!,
          numClients: currentBrand.numClients!,
          navigateToPage: (int page,
              [DateTime? dateTime, CalendarView? calendarView]) async {
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
      case 18:
        mixpanel!.track('brand_subscription_view');
        return BrandPurchaseHistory(
          brandId: currentBrand.id!,
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
    }
  }

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
            heightFactor: 0.935, child: RolesInfo());
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
    return Scaffold(
      key: mambaProScaffoldKey,
      drawer: Drawer(
        surfaceTintColor: Theme.of(context).primaryColorDark,
        backgroundColor: Theme.of(context).primaryColorDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
          ),
        ),
        child: Column(
          children: [
            // Header
            buildHeader(),
            const Divider(
              color: AppColors.grey,
              thickness: 0,
              height: 1,
            ),
            // Brand List Options
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                // Remove padding
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  // Brand Options
                  buildBrandListOptions(),

                  /* TODO: Delete this
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  TextButton(
                    onPressed: () {
                      UtilsTest ut = UtilsTest();
                      ut.callTestFunction();
                    },
                    child: const Text('FUNCION DE PRUEBA BONOS'),
                  ),
                  // TODO: Delete this
                  */

                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                ],
              ),
            ),
            // Payment
            const Divider(
              color: AppColors.grey,
              thickness: 0,
              height: 1,
            ),
            buildBottomPayment(),
          ],
        ),
      ),
      body: isLoading ? LoadingView() : buildBodyNavigation(),
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
        ));
    if (result == null || result == true) {
      setState(() {
        isLoading = true;
      });
    }
  }

  /// DEPRECATED FAVOURITES

  // Function to get the favourites of the user
  void getFavourites() async {
    favourites = await _userDataService.getUserFavourites(
        currentBrand.id!, currentUser.id!);
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
    if (favourites.isNotEmpty && favourites.contains(pageIndex)) {
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
      } else {
        favourites.remove(pageIndex);
      }
      favourites.sort();
      _userDataService.addFavouriteToUser(
          currentBrand.id!, currentUser.id!, favourites);
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
