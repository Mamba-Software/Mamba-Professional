import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/UserBonos/UserPurchaseHistory/views/UserPurchaseCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/SelectCalendar/SelectCalendarDate.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/BrandPurchaseHistory/models/PurchaseHistoryModel.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../../Globals/Constants.dart';
import '../cubit/UserPurchasesCubit.dart';

class UserPurchaseHistory extends StatelessWidget {
  final String userId;
  final String brandId;  

  const UserPurchaseHistory({Key? key, required this.brandId, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserPurchasesCubit>(
      create: (context) => UserPurchasesCubit(userId, brandId),
      child: UserPurchaseHistoryBody(brandId: brandId, userId: userId),
    );
  }
}

class UserPurchaseHistoryBody extends StatefulWidget {
  final String brandId;
  final String userId;

  const UserPurchaseHistoryBody({Key? key, required this.brandId, required this.userId}) : super(key: key);

  @override
  _UserPurchaseHistoryBodyState createState() => _UserPurchaseHistoryBodyState();
}

class _UserPurchaseHistoryBodyState extends State<UserPurchaseHistoryBody> {

  String brandId = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  void _show(BuildContext context, DateTime startDate, DateTime endDate, DateTime dateJoinedBrand) async {
    List<DateTime>? result = await showModalBottomSheet<List<DateTime>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.935,
          child: SelectCalendarDate(
            dateRange: [startDate, endDate],
            dateJoined: dateJoinedBrand,
            isFuture: false,
            acceptToday: true,
          ),
        );
      },
    );
    if (result != null) {
      context.read<UserPurchasesCubit>().filterByDateRange(result.first, result.last);
    }
  }

  String returnCorrectText(BuildContext context, DateTime startDate, DateTime endDate, DateTime dateJoinedBrand, bool acceptToday) {
    DateTime now = DateTime.now();
    DateTime maxEndDate = acceptToday ? now : now.subtract(const Duration(days: 1));
    int daysDifference = endDate.difference(startDate).inDays;

    // Check for "this month" selection
    if (startDate.day == 1 && startDate.month == now.month && startDate.year == now.year
        && endDate.day == maxEndDate.day && endDate.month == maxEndDate.month && endDate.year == maxEndDate.year) {
      return AppLocalizations.of(context)!.thisEventAndRest.split(" ")[0]+" "+StringUtils().toCapitalized(AppLocalizations.of(context)!.month);
    }

    // Check for "previous month" selection
    if (startDate.day == 1 && startDate.month == now.month - 1 && startDate.year == now.year
        && endDate.day == DateTime(now.year, now.month, 0).day && endDate.month == now.month - 1 && endDate.year == now.year) {
      return AppLocalizations.of(context)!.previousMonth;
    }

    // Check for "Historic" selection
    if (startDate.day == dateJoinedBrand.day && startDate.month == dateJoinedBrand.month && startDate.year == dateJoinedBrand.year
        && endDate.day == maxEndDate.day && endDate.month == maxEndDate.month && endDate.year == maxEndDate.year) {
      return AppLocalizations.of(context)!.historic;
    }

    switch (daysDifference) {
      case 7:
      case 14:
      case 30:
      case 90:
        if (maxEndDate.day == endDate.day && maxEndDate.month == endDate.month && maxEndDate.year == endDate.year) {
          return AppLocalizations.of(context)!.lastNDays(endDate.difference(startDate).inDays.toString());
        } else {
          return AppLocalizations.of(context)!.personlized;
        }
      default:
        return AppLocalizations.of(context)!.personlized;
    }
  }

  String returnFilteredStatusString(List<bool> filterByPurchaseStatus) {
    String filteredRoles = "";
    int cnt = 0;
    if (filterByPurchaseStatus[0]) {
      filteredRoles += AppLocalizations.of(context)!.verfied+", ";
      cnt += 1;
    }
    if (filterByPurchaseStatus[1]) {
      filteredRoles += AppLocalizations.of(context)!.unverfied+", ";
      cnt += 1;
    }
    if (filterByPurchaseStatus[2]) {
      filteredRoles += AppLocalizations.of(context)!.toConfirm;
      cnt += 1;
    }
    if (cnt == 1) {
      return filteredRoles.split(", ")[0];
    }
    if (cnt == 2 && filterByPurchaseStatus[2] == false) {
      return filteredRoles.split(", ")[0]+", "+filteredRoles.split(", ")[1];
    }
    return filteredRoles;
  }

  String returnFilteredActiveBonosString(List<bool> filterByActivePurchases) {
    String activeStaff = "";
    int cnt = 0;
    if (filterByActivePurchases[0]) {
      activeStaff += AppLocalizations.of(context)!.yes+", ";
      cnt += 1;
    }
    if (filterByActivePurchases[1]) {
      activeStaff += AppLocalizations.of(context)!.no;
      cnt += 1;
    }
    if (cnt == 1) {
      return activeStaff.split(", ")[0];
    }
    return activeStaff;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserPurchasesCubit, UserPurchasesState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case UserPurchasesLoaded:
            // Handles Loaded State
            final userPurchasesCubit = context.read<UserPurchasesCubit>();
            UserPurchasesLoaded loadedState = state as UserPurchasesLoaded;
            DateTime startDate = loadedState.startDate;
            DateTime endDate = loadedState.endDate;
            DateTime dateJoinedBrand = loadedState.dateJoinedBrand;
            List<bool> filterByPurchaseStatus = loadedState.filterByPurchaseStatus;
            List<bool> filterByActivePurchases = loadedState.filterByActivePurchases;
            List<bool> allFilters = filterByPurchaseStatus + filterByActivePurchases;
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: MediaQuery.of(context).size.height * 0.14,
                title: Text(
                  AppLocalizations.of(context)!.purchaseHistory,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.03),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.08,
                      height: MediaQuery.of(context).size.width * 0.08,
                      decoration: BoxDecoration(
                        color: allFilters.contains(false) ? Theme.of(context).primaryColor : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        splashRadius: 20,
                        splashColor: Theme.of(context).backgroundColor, // Splash color
                        padding: EdgeInsets.zero,
                        alignment: Alignment.center,
                        icon: Icon(
                          Icons.filter_list,
                          color: allFilters.contains(false) ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColor,
                          size: MediaQuery.of(context).size.width*0.06,
                        ),
                        onPressed: () async {
                          await showModalBottomSheet<int?>(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  final PageController _pageController = PageController(initialPage: 0);
                                  ValueNotifier<int> _currentPage = ValueNotifier(0);
                                  ValueNotifier<bool> isTypePurchase = ValueNotifier(true);
                                  return FractionallySizedBox(
                                    heightFactor: 0.33,
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.5,
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            ValueListenableBuilder<int>(
                                              valueListenable: _currentPage,
                                              builder: (context, value, child) {
                                                return ListTile(
                                                  title: Text(
                                                      AppLocalizations.of(context)!.filterBy,
                                                      style: Theme.of(context).textTheme.caption,
                                                      textAlign: TextAlign.left
                                                  ),
                                                  trailing: TextButton(
                                                      child: Text(
                                                          AppLocalizations.of(context)!.clear,
                                                          style: Theme.of(context).textTheme.caption
                                                      ),
                                                      onPressed: () {
                                                        filterByPurchaseStatus = [true, true, true];
                                                        filterByActivePurchases = [true, true];
                                                        userPurchasesCubit.filterBy(filterByPurchaseStatus, filterByActivePurchases);
                                                        Navigator.pop(context);
                                                      }
                                                  ),
                                                  dense: true,
                                                  onTap: value == 0 ? null : () {
                                                    _pageController.previousPage(
                                                      duration: const Duration(milliseconds: 500),
                                                      curve: Curves.ease,
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.21,
                                              width: MediaQuery.of(context).size.width,
                                              child: PageView(
                                                physics: const NeverScrollableScrollPhysics(),
                                                controller: _pageController,
                                                onPageChanged: (int page) {
                                                  _currentPage.value = page;
                                                },
                                                children: <Widget>[
                                                  Column(
                                                    children: [
                                                      ListTile(
                                                        onTap: () {
                                                          isTypePurchase.value = true;
                                                          _pageController.nextPage(
                                                            duration: const Duration(milliseconds: 500),
                                                            curve: Curves.ease,
                                                          );
                                                        },
                                                        title: Text(
                                                            AppLocalizations.of(context)!.state,
                                                            style: Theme.of(context).textTheme.bodyText1,
                                                            textAlign: TextAlign.left
                                                        ),
                                                        subtitle: Text(
                                                            returnFilteredStatusString(filterByPurchaseStatus),
                                                            style: Theme.of(context).textTheme.caption,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            textAlign: TextAlign.left
                                                        ),
                                                        trailing: SizedBox(
                                                          width: MediaQuery.of(context).size.width * 0.15,
                                                          child: Center(
                                                              child: Icon(Icons.arrow_forward_ios, size:MediaQuery.of(context).size.width * 0.04,color: AppColors.grey)
                                                          ),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        onTap: () {
                                                          isTypePurchase.value = false;
                                                          _pageController.nextPage(
                                                            duration: const Duration(milliseconds: 500),
                                                            curve: Curves.ease,
                                                          );
                                                        },
                                                        title: Text(
                                                            AppLocalizations.of(context)!.bono+" "+AppLocalizations.of(context)!.active+"s",
                                                            style: Theme.of(context).textTheme.bodyText1,
                                                            textAlign: TextAlign.left
                                                        ),
                                                        subtitle: Text(
                                                            returnFilteredActiveBonosString(filterByActivePurchases),
                                                            style: Theme.of(context).textTheme.caption,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            textAlign: TextAlign.left
                                                        ),
                                                        trailing: SizedBox(
                                                          width: MediaQuery.of(context).size.width * 0.15,
                                                          child: Center(
                                                              child: Icon(Icons.arrow_forward_ios, size:MediaQuery.of(context).size.width * 0.04,color: AppColors.grey)
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  ValueListenableBuilder<bool>(
                                                    valueListenable: isTypePurchase,
                                                    builder: (context, value, child) {
                                                      return value ? Column(
                                                        children: [
                                                          ListTile(
                                                            onTap: () {
                                                              // Check if the Only True
                                                              var filterActive = List.from(filterByPurchaseStatus);
                                                              filterActive.retainWhere((element) => element == true);
                                                              if (!(filterActive.length == 1 && filterByPurchaseStatus[0])) {
                                                                filterByPurchaseStatus[0] = !filterByPurchaseStatus[0];
                                                                userPurchasesCubit.filterBy(filterByPurchaseStatus, filterByActivePurchases);
                                                                Navigator.pop(context);
                                                              }
                                                            },
                                                            title: Text(
                                                                AppLocalizations.of(context)!.verfied,
                                                                style: Theme.of(context).textTheme.bodyText1,
                                                                textAlign: TextAlign.left
                                                            ),
                                                            trailing: filterByPurchaseStatus[0] ? SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.15,
                                                              child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                            ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                          ),
                                                          ListTile(
                                                            onTap: () {
                                                              // Check if the Only True
                                                              var filterActive = List.from(filterByPurchaseStatus);
                                                              filterActive.retainWhere((element) => element == true);
                                                              if (!(filterActive.length == 1 && filterByPurchaseStatus[1])) {
                                                                filterByPurchaseStatus[1] = !filterByPurchaseStatus[1];
                                                                userPurchasesCubit.filterBy(filterByPurchaseStatus, filterByActivePurchases);
                                                                Navigator.pop(context);
                                                              }
                                                            },
                                                            title: Text(
                                                                AppLocalizations.of(context)!.unverfied,
                                                                style: Theme.of(context).textTheme.bodyText1,
                                                                textAlign: TextAlign.left
                                                            ),
                                                            trailing: filterByPurchaseStatus[1] ? SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.15,
                                                              child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                            ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                          ),
                                                          ListTile(
                                                            onTap: () {
                                                              // Check if the Only True
                                                              var filterActive = List.from(filterByPurchaseStatus);
                                                              filterActive.retainWhere((element) => element == true);
                                                              if (!(filterActive.length == 1 && filterByPurchaseStatus[2])) {
                                                                filterByPurchaseStatus[2] = !filterByPurchaseStatus[2];
                                                                userPurchasesCubit.filterBy(filterByPurchaseStatus, filterByActivePurchases);
                                                                Navigator.pop(context);
                                                              }
                                                            },
                                                            title: Text(
                                                                AppLocalizations.of(context)!.toConfirm,
                                                                style: Theme.of(context).textTheme.bodyText1,
                                                                textAlign: TextAlign.left
                                                            ),
                                                            trailing: filterByPurchaseStatus[2] ? SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.15,
                                                              child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                            ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                          ),
                                                        ],
                                                      ) : Column(
                                                        children: [
                                                          ListTile(
                                                            onTap: () {
                                                              // Check if the Only True
                                                              var filterActive = List.from(filterByActivePurchases);
                                                              filterActive.retainWhere((element) => element == true);
                                                              if (!(filterActive.length == 1 && filterByActivePurchases[0])) {
                                                                filterByActivePurchases[0] = !filterByActivePurchases[0];
                                                                userPurchasesCubit.filterBy(filterByPurchaseStatus, filterByActivePurchases);
                                                                Navigator.pop(context);
                                                              }
                                                            },
                                                            title: Text(
                                                                AppLocalizations.of(context)!.active,
                                                                style: Theme.of(context).textTheme.bodyText1,
                                                                textAlign: TextAlign.left
                                                            ),
                                                            trailing: filterByActivePurchases[0] ? SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.15,
                                                              child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                            ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                          ),
                                                          ListTile(
                                                            onTap: () {
                                                              // Check if the Only True
                                                              var filterActive = List.from(filterByActivePurchases);
                                                              filterActive.retainWhere((element) => element == true);
                                                              if (!(filterActive.length == 1 && filterByActivePurchases[1])) {
                                                                filterByActivePurchases[1] = !filterByActivePurchases[1];
                                                                userPurchasesCubit.filterBy(filterByPurchaseStatus, filterByActivePurchases);
                                                                Navigator.pop(context);
                                                              }
                                                            },
                                                            title: Text(
                                                                AppLocalizations.of(context)!.desactive,
                                                                style: Theme.of(context).textTheme.bodyText1,
                                                                textAlign: TextAlign.left
                                                            ),
                                                            trailing: filterByActivePurchases[1] ? SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.15,
                                                              child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                            ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04, right: MediaQuery.of(context).size.width * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.08,
                                height: MediaQuery.of(context).size.width * 0.08,
                                margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.015),
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  splashRadius: 20,
                                  splashColor: Theme.of(context).backgroundColor, // Splash color
                                  padding: const EdgeInsets.only(right: 2),
                                  alignment: Alignment.center,
                                  icon: Icon(
                                    loadedState.orderByDescending ? FontAwesomeIcons.arrowDownWideShort : FontAwesomeIcons.arrowUpShortWide,
                                    color: Theme.of(context).primaryColor,
                                    size: MediaQuery.of(context).size.width*0.035,
                                  ),
                                  onPressed: () async {
                                    context.read<UserPurchasesCubit>().orderByDate(!loadedState.orderByDescending);
                                  },
                                ),
                              ),
                              TextButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      returnCorrectText(context, startDate, endDate, dateJoinedBrand, true),
                                      style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Icon(Icons.keyboard_arrow_down_outlined, color: Theme.of(context).primaryColor)
                                  ],
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.grey.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(  // add this
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.only(left: 16.0, right: 10.0),
                                ),
                                onPressed: () => _show(context, startDate, endDate, dateJoinedBrand),
                              ),
                            ],
                          ),
                          Text(
                            '${DateFormat('d MMM, yy\'').format(startDate)} - ${DateFormat('d MMM, yy\'').format(endDate)}',
                            style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              body: loadedState.purchasesHistoryObjects.isNotEmpty ? Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: state.purchasesHistoryObjects.length,
                        itemBuilder: (context, index) {
                          PurchaseHistoryModel obj = loadedState.purchasesHistoryObjects[index];
                          return UserPurchaseCard(
                            bono: obj.bono,
                            user: obj.user,
                            brand: obj.brand,
                            bonoRequest: obj.bonoReq,
                            purchase: obj.purchase,
                          );
                        }
                    ),
                  ),
                ],
              ) : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width*0.30,
                          child: Image.asset(Constants.emptyCalendar)
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.015),
                      Text(AppLocalizations.of(context)!.noData, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
                      SizedBox(height: MediaQuery.of(context).size.height*0.1),
                    ],
                  ),
                ],
              ),
            );
          default:
            // Handle all other states aka Loading or Initial
            DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
            DateTime endDate = DateTime.now();
            DateTime dateJoinedBrand = DateTime(
                int.parse(currentBrand.dateJoined!.split("-")[2]),
                int.parse(currentBrand.dateJoined!.split("-")[1]),
                int.parse(currentBrand.dateJoined!.split("-")[0]),
                0,
                0
            );
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: MediaQuery.of(context).size.height * 0.14,
                title: Text(
                  AppLocalizations.of(context)!.purchaseHistory,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.04),
                    child: Icon(
                      Icons.filter_list,
                      color: Theme.of(context).primaryColor,
                      size: MediaQuery.of(context).size.width*0.06,
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04, right: MediaQuery.of(context).size.width * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.08,
                                height: MediaQuery.of(context).size.width * 0.08,
                                margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.015),
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  //borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                                ),
                                child: IconButton(
                                  splashRadius: 20,
                                  splashColor: Theme.of(context).backgroundColor, // Splash color
                                  padding: const EdgeInsets.only(right: 2),
                                  alignment: Alignment.center,
                                  icon: Icon(
                                    FontAwesomeIcons.arrowDownWideShort,
                                    color: Theme.of(context).primaryColor,
                                    size: MediaQuery.of(context).size.width*0.035,
                                  ),
                                  onPressed: null,
                                ),
                              ),
                              TextButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      returnCorrectText(context, startDate, endDate, dateJoinedBrand, true),
                                      style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Icon(Icons.keyboard_arrow_down_outlined, color: Theme.of(context).primaryColor)
                                  ],
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.grey.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(  // add this
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.only(left: 16.0, right: 10.0),
                                ),
                                onPressed: () => _show(context, startDate, endDate, dateJoinedBrand),
                              ),
                            ],
                          ),
                          Text(
                            '${DateFormat('d MMM, yy\'').format(startDate)} - ${DateFormat('d MMM, yy\'').format(endDate)}',
                            style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: IgnorePointer(
                  child: Column(
                    children: [
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.width * 0.03),
                              child: Row(
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: AppColors.grey,
                                    highlightColor: AppColors.grey.withOpacity(0.5),
                                    child: Container(
                                      height: MediaQuery.of(context).size.width*0.15,
                                      width: MediaQuery.of(context).size.width*0.15,
                                      decoration: const BoxDecoration(
                                        color: AppColors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width * 0.04), // adjust this value as needed
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        /// USER
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Shimmer.fromColors(
                                              baseColor: AppColors.grey,
                                              highlightColor: AppColors.grey.withOpacity(0.5),
                                              child: Container(
                                                height: MediaQuery.of(context).size.height*0.02,
                                                width: MediaQuery.of(context).size.width*0.25,
                                                decoration: const BoxDecoration(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0),
                                                  ),
                                                  color: AppColors.grey,
                                                ),
                                              ),
                                            ),
                                            Shimmer.fromColors(
                                              baseColor: AppColors.grey,
                                              highlightColor: AppColors.grey.withOpacity(0.5),
                                              child: Container(
                                                height: MediaQuery.of(context).size.height*0.02,
                                                width: MediaQuery.of(context).size.width*0.15,
                                                decoration: const BoxDecoration(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0),
                                                  ),
                                                  color: AppColors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                                        /// BONO
                                        Shimmer.fromColors(
                                          baseColor: AppColors.grey,
                                          highlightColor: AppColors.grey.withOpacity(0.5),
                                          child: Container(
                                            height: MediaQuery.of(context).size.height*0.015,
                                            width: MediaQuery.of(context).size.width*0.45,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5.0),
                                              ),
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                                        /// DETAILS
                                        Shimmer.fromColors(
                                          baseColor: AppColors.grey,
                                          highlightColor: AppColors.grey.withOpacity(0.5),
                                          child: Container(
                                            height: MediaQuery.of(context).size.height*0.015,
                                            width: MediaQuery.of(context).size.width*0.55,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5.0),
                                              ),
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                                        /// DATE
                                        Shimmer.fromColors(
                                          baseColor: AppColors.grey,
                                          highlightColor: AppColors.grey.withOpacity(0.5),
                                          child: Container(
                                            height: MediaQuery.of(context).size.height*0.013,
                                            width: MediaQuery.of(context).size.width*0.25,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5.0),
                                              ),
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.03),
                    ],
                  ),
                ),
              ),
            );
        }
      },
    );
  }

}


