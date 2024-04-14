import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Calendars/SelectCalendar/SelectCalendarDate.dart';
import 'package:mamba/notifications/Unread/widgets/askSupport.dart';
import 'package:mamba/notifications/Unread/widgets/profileImage.dart';
import 'package:mamba/notifications/Unread/widgets/unreadChats.dart';
import 'package:mamba/notifications/Unread/widgets/unreadNotifications.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/007%20-%20Purchases/cubit/BrandPurchasesCubit.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/007%20-%20Purchases/models/PurchaseHistoryModel.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/007%20-%20Purchases/views/BrandPurchaseCard.dart';
import 'package:shimmer/shimmer.dart';

class BrandPurchaseHistory extends StatelessWidget {
  final String brandId;

  const BrandPurchaseHistory({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BrandPurchasesCubit>(
      create: (context) => BrandPurchasesCubit(brandId),
      child: BrandPurchaseHistoryBody(brandId: brandId),
    );
  }
}

class BrandPurchaseHistoryBody extends StatefulWidget {
  final String brandId;

  const BrandPurchaseHistoryBody({super.key, required this.brandId});

  @override
  _BrandPurchaseHistoryBodyState createState() =>
      _BrandPurchaseHistoryBodyState();
}

class _BrandPurchaseHistoryBodyState extends State<BrandPurchaseHistoryBody> {
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    if (!_scrollController!.hasClients) {
      return false;
    }
    if (_scrollController!.position.userScrollDirection ==
        ScrollDirection.forward) {
      // User is down up, so AppBar should expand.
      return false;
    }
    // Use the same condition as before to check if AppBar is expanded.
    return _scrollController!.offset >
        (MediaQuery.of(context).size.height * 0.15 - kToolbarHeight);
  }

  // Variables
  String brandId = "";
  bool canEdit = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(
        () => _isAppBarExpanded
            ? setState(() {
                appBarExpanded = true;
              })
            : setState(() {
                appBarExpanded = false;
              }),
      );
    canEdit = currentUser.brandRole < 3 ? true : false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _show(BuildContext context, DateTime startDate, DateTime endDate,
      DateTime dateJoinedBrand) async {
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
      context
          .read<BrandPurchasesCubit>()
          .filterByDateRange(result.first, result.last);
    }
  }

  String returnCorrectText(BuildContext context, DateTime startDate,
      DateTime endDate, DateTime dateJoinedBrand, bool acceptToday) {
    DateTime now = DateTime.now();
    DateTime maxEndDate =
        acceptToday ? now : now.subtract(const Duration(days: 1));
    int daysDifference = endDate.difference(startDate).inDays;

    // Check for "this month" selection
    if (startDate.day == 1 &&
        startDate.month == now.month &&
        startDate.year == now.year &&
        endDate.day == maxEndDate.day &&
        endDate.month == maxEndDate.month &&
        endDate.year == maxEndDate.year) {
      return "${AppLocalizations.of(context)!.thisEventAndRest.split(" ")[0]} ${StringUtils().toCapitalized(AppLocalizations.of(context)!.month)}";
    }

    // Check for "previous month" selection
    if (startDate.day == 1 &&
        startDate.month == now.month - 1 &&
        startDate.year == now.year &&
        endDate.day == DateTime(now.year, now.month, 0).day &&
        endDate.month == now.month - 1 &&
        endDate.year == now.year) {
      return AppLocalizations.of(context)!.previousMonth;
    }

    // Check for "Historic" selection
    if (startDate.day == dateJoinedBrand.day &&
        startDate.month == dateJoinedBrand.month &&
        startDate.year == dateJoinedBrand.year &&
        endDate.day == maxEndDate.day &&
        endDate.month == maxEndDate.month &&
        endDate.year == maxEndDate.year) {
      return AppLocalizations.of(context)!.historic;
    }

    switch (daysDifference) {
      case 7:
      case 14:
      case 30:
      case 90:
        if (maxEndDate.day == endDate.day &&
            maxEndDate.month == endDate.month &&
            maxEndDate.year == endDate.year) {
          return AppLocalizations.of(context)!
              .lastNDays(endDate.difference(startDate).inDays.toString());
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
      filteredRoles += "${AppLocalizations.of(context)!.verfied}, ";
      cnt += 1;
    }
    if (filterByPurchaseStatus[1]) {
      filteredRoles += "${AppLocalizations.of(context)!.unverfied}, ";
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
      return "${filteredRoles.split(", ")[0]}, ${filteredRoles.split(", ")[1]}";
    }
    return filteredRoles;
  }

  String returnFilteredActiveBonosString(List<bool> filterByActivePurchases) {
    String activeStaff = "";
    int cnt = 0;
    if (filterByActivePurchases[0]) {
      activeStaff += "${AppLocalizations.of(context)!.yes}, ";
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
    return BlocBuilder<BrandPurchasesCubit, BrandPurchasesState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case BrandPurchasesLoaded:
            // Handles Loaded State
            final brandPurchasesCubit = context.read<BrandPurchasesCubit>();
            BrandPurchasesLoaded loadedState = state as BrandPurchasesLoaded;
            DateTime startDate = loadedState.startDate;
            DateTime endDate = loadedState.endDate;
            DateTime dateJoinedBrand = loadedState.dateJoinedBrand;
            List<bool> filterByPurchaseStatus =
                loadedState.filterByPurchaseStatus;
            List<bool> filterByActivePurchases =
                loadedState.filterByActivePurchases;
            List<bool> allFilters =
                filterByPurchaseStatus + filterByActivePurchases;
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    surfaceTintColor: AppColors.darkGrey,
                    backgroundColor: AppColors.darkGrey,
                    expandedHeight: MediaQuery.of(context).size.height * 0.14,
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    elevation: 0,
                    floating: true,
                    pinned: true,
                    title: AnimatedOpacity(
                        opacity: appBarExpanded ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(AppLocalizations.of(context)!.payments,
                            style: Theme.of(context)
                                .appBarTheme
                                .titleTextStyle
                                ?.copyWith(
                                  color: AppColors.white,
                                ))),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        color: AppColors.darkGrey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.05,
                                  right: MediaQuery.of(context).size.width *
                                      0.025),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.payments,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          color: AppColors.white,
                                        ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.08,
                                    width: MediaQuery.of(context).size.width *
                                        0.40,
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.width *
                                        0.09,
                                    width: MediaQuery.of(context).size.width *
                                        0.09,
                                    child: ClipOval(
                                      child: Material(
                                        color: allFilters.contains(false)
                                            ? AppColors.white
                                            : Colors
                                                .transparent, // Button color
                                        child: InkWell(
                                          splashColor: Theme.of(context)
                                              .colorScheme
                                              .background, // Splash color
                                          onTap: () async {
                                            await showModalBottomSheet<int?>(
                                              context: context,
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                ),
                                              ),
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              builder: (BuildContext context) {
                                                return StatefulBuilder(
                                                  builder: (BuildContext
                                                          context,
                                                      StateSetter setState) {
                                                    final PageController
                                                        pageController =
                                                        PageController(
                                                            initialPage: 0);
                                                    ValueNotifier<int>
                                                        currentPage =
                                                        ValueNotifier(0);
                                                    ValueNotifier<bool>
                                                        isTypePurchase =
                                                        ValueNotifier(true);
                                                    return FractionallySizedBox(
                                                      heightFactor: 0.33,
                                                      child: SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .all(MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.02),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              ValueListenableBuilder<
                                                                  int>(
                                                                valueListenable:
                                                                    currentPage,
                                                                builder:
                                                                    (context,
                                                                        value,
                                                                        child) {
                                                                  return ListTile(
                                                                    title: Text(
                                                                        AppLocalizations.of(context)!
                                                                            .filterBy,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodySmall,
                                                                        textAlign:
                                                                            TextAlign.left),
                                                                    trailing: TextButton(
                                                                        child: Text(AppLocalizations.of(context)!.clear, style: Theme.of(context).textTheme.bodySmall),
                                                                        onPressed: () {
                                                                          filterByPurchaseStatus =
                                                                              [
                                                                            true,
                                                                            true,
                                                                            true
                                                                          ];
                                                                          filterByActivePurchases =
                                                                              [
                                                                            true,
                                                                            true
                                                                          ];
                                                                          brandPurchasesCubit.filterBy(
                                                                              filterByPurchaseStatus,
                                                                              filterByActivePurchases);
                                                                          Navigator.pop(
                                                                              context);
                                                                        }),
                                                                    dense: true,
                                                                    onTap: value ==
                                                                            0
                                                                        ? null
                                                                        : () {
                                                                            pageController.previousPage(
                                                                              duration: const Duration(milliseconds: 500),
                                                                              curve: Curves.ease,
                                                                            );
                                                                          },
                                                                  );
                                                                },
                                                              ),
                                                              SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.21,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child: PageView(
                                                                  physics:
                                                                      const NeverScrollableScrollPhysics(),
                                                                  controller:
                                                                      pageController,
                                                                  onPageChanged:
                                                                      (int
                                                                          page) {
                                                                    currentPage
                                                                            .value =
                                                                        page;
                                                                  },
                                                                  children: <Widget>[
                                                                    Column(
                                                                      children: [
                                                                        ListTile(
                                                                          onTap:
                                                                              () {
                                                                            isTypePurchase.value =
                                                                                true;
                                                                            pageController.nextPage(
                                                                              duration: const Duration(milliseconds: 500),
                                                                              curve: Curves.ease,
                                                                            );
                                                                          },
                                                                          title: Text(
                                                                              AppLocalizations.of(context)!.state,
                                                                              style: Theme.of(context).textTheme.bodyLarge,
                                                                              textAlign: TextAlign.left),
                                                                          subtitle: Text(
                                                                              returnFilteredStatusString(filterByPurchaseStatus),
                                                                              style: Theme.of(context).textTheme.bodySmall,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              textAlign: TextAlign.left),
                                                                          trailing:
                                                                              SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15,
                                                                            child:
                                                                                Center(child: Icon(Icons.arrow_forward_ios, size: MediaQuery.of(context).size.width * 0.04, color: AppColors.grey)),
                                                                          ),
                                                                        ),
                                                                        ListTile(
                                                                          onTap:
                                                                              () {
                                                                            isTypePurchase.value =
                                                                                false;
                                                                            pageController.nextPage(
                                                                              duration: const Duration(milliseconds: 500),
                                                                              curve: Curves.ease,
                                                                            );
                                                                          },
                                                                          title: Text(
                                                                              AppLocalizations.of(context)!.activeRates,
                                                                              style: Theme.of(context).textTheme.bodyLarge,
                                                                              textAlign: TextAlign.left),
                                                                          subtitle: Text(
                                                                              returnFilteredActiveBonosString(filterByActivePurchases),
                                                                              style: Theme.of(context).textTheme.bodySmall,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              textAlign: TextAlign.left),
                                                                          trailing:
                                                                              SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15,
                                                                            child:
                                                                                Center(child: Icon(Icons.arrow_forward_ios, size: MediaQuery.of(context).size.width * 0.04, color: AppColors.grey)),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    ValueListenableBuilder<
                                                                        bool>(
                                                                      valueListenable:
                                                                          isTypePurchase,
                                                                      builder: (context,
                                                                          value,
                                                                          child) {
                                                                        return value
                                                                            ? Column(
                                                                                children: [
                                                                                  ListTile(
                                                                                    onTap: () {
                                                                                      // Check if the Only True
                                                                                      var filterActive = List.from(filterByPurchaseStatus);
                                                                                      filterActive.retainWhere((element) => element == true);
                                                                                      if (!(filterActive.length == 1 && filterByPurchaseStatus[0])) {
                                                                                        filterByPurchaseStatus[0] = !filterByPurchaseStatus[0];
                                                                                        brandPurchasesCubit.filterBy(filterByPurchaseStatus, filterByActivePurchases);
                                                                                        Navigator.pop(context);
                                                                                      }
                                                                                    },
                                                                                    title: Text(AppLocalizations.of(context)!.verfied, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                                    trailing: filterByPurchaseStatus[0]
                                                                                        ? SizedBox(
                                                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                                                            child: Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                                          )
                                                                                        : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                                                  ),
                                                                                  ListTile(
                                                                                    onTap: () {
                                                                                      // Check if the Only True
                                                                                      var filterActive = List.from(filterByPurchaseStatus);
                                                                                      filterActive.retainWhere((element) => element == true);
                                                                                      if (!(filterActive.length == 1 && filterByPurchaseStatus[1])) {
                                                                                        filterByPurchaseStatus[1] = !filterByPurchaseStatus[1];
                                                                                        brandPurchasesCubit.filterBy(filterByPurchaseStatus, filterByActivePurchases);
                                                                                        Navigator.pop(context);
                                                                                      }
                                                                                    },
                                                                                    title: Text(AppLocalizations.of(context)!.unverfied, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                                    trailing: filterByPurchaseStatus[1]
                                                                                        ? SizedBox(
                                                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                                                            child: Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                                          )
                                                                                        : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                                                  ),
                                                                                  ListTile(
                                                                                    onTap: () {
                                                                                      // Check if the Only True
                                                                                      var filterActive = List.from(filterByPurchaseStatus);
                                                                                      filterActive.retainWhere((element) => element == true);
                                                                                      if (!(filterActive.length == 1 && filterByPurchaseStatus[2])) {
                                                                                        filterByPurchaseStatus[2] = !filterByPurchaseStatus[2];
                                                                                        brandPurchasesCubit.filterBy(filterByPurchaseStatus, filterByActivePurchases);
                                                                                        Navigator.pop(context);
                                                                                      }
                                                                                    },
                                                                                    title: Text(AppLocalizations.of(context)!.toConfirm, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                                    trailing: filterByPurchaseStatus[2]
                                                                                        ? SizedBox(
                                                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                                                            child: Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                                          )
                                                                                        : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            : Column(
                                                                                children: [
                                                                                  ListTile(
                                                                                    onTap: () {
                                                                                      // Check if the Only True
                                                                                      var filterActive = List.from(filterByActivePurchases);
                                                                                      filterActive.retainWhere((element) => element == true);
                                                                                      if (!(filterActive.length == 1 && filterByActivePurchases[0])) {
                                                                                        filterByActivePurchases[0] = !filterByActivePurchases[0];
                                                                                        brandPurchasesCubit.filterBy(filterByPurchaseStatus, filterByActivePurchases);
                                                                                        Navigator.pop(context);
                                                                                      }
                                                                                    },
                                                                                    title: Text(AppLocalizations.of(context)!.yes, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                                    trailing: filterByActivePurchases[0]
                                                                                        ? SizedBox(
                                                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                                                            child: Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                                          )
                                                                                        : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                                                  ),
                                                                                  ListTile(
                                                                                    onTap: () {
                                                                                      // Check if the Only True
                                                                                      var filterActive = List.from(filterByActivePurchases);
                                                                                      filterActive.retainWhere((element) => element == true);
                                                                                      if (!(filterActive.length == 1 && filterByActivePurchases[1])) {
                                                                                        filterByActivePurchases[1] = !filterByActivePurchases[1];
                                                                                        brandPurchasesCubit.filterBy(filterByPurchaseStatus, filterByActivePurchases);
                                                                                        Navigator.pop(context);
                                                                                      }
                                                                                    },
                                                                                    title: Text(AppLocalizations.of(context)!.no, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                                    trailing: filterByActivePurchases[1]
                                                                                        ? SizedBox(
                                                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                                                            child: Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                                          )
                                                                                        : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
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
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.09,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.09,
                                              child: Icon(
                                                Icons.filter_list,
                                                color:
                                                    allFilters.contains(false)
                                                        ? AppColors.darkGrey
                                                        : AppColors.white,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.07,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      titlePadding: EdgeInsets.zero,
                      //centerTitle: true,
                    ),
                    centerTitle: false,
                    leading: Builder(
                      builder: (BuildContext innerContext) => Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.02),
                        child: IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: AppColors.white,
                              size: MediaQuery.of(context).size.height * 0.04,
                            ),
                            onPressed: () =>
                                mambaProScaffoldKey.currentState?.openDrawer()),
                      ),
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          askSupport(context),
                          unreadNotifications(context),
                          unreadChats(context),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.025),
                          profileImage(context),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03),
                        ],
                      ),
                    ],
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegateSecond(
                      Container(
                        height: (MediaQuery.of(context).size.height * 0.07) + 1,
                        color: AppColors.darkGrey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.04,
                                  right:
                                      MediaQuery.of(context).size.width * 0.04),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.09,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.09,
                                        margin: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightGrey
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          splashRadius: 20,
                                          splashColor: Theme.of(context)
                                              .colorScheme
                                              .background, // Splash color
                                          padding:
                                              const EdgeInsets.only(right: 2),
                                          alignment: Alignment.center,
                                          icon: Icon(
                                            loadedState.orderByDescending
                                                ? FontAwesomeIcons
                                                    .arrowDownWideShort
                                                : FontAwesomeIcons
                                                    .arrowUpShortWide,
                                            color: AppColors.white,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                          ),
                                          onPressed: () async {
                                            context
                                                .read<BrandPurchasesCubit>()
                                                .orderByDate(!loadedState
                                                    .orderByDescending);
                                          },
                                        ),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: AppColors.lightGrey
                                              .withOpacity(0.1),
                                          shape: RoundedRectangleBorder(
                                            // add this
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.only(
                                              left: 16.0, right: 10.0),
                                        ),
                                        onPressed: () => _show(
                                            context,
                                            startDate,
                                            endDate,
                                            dateJoinedBrand),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              returnCorrectText(
                                                  context,
                                                  startDate,
                                                  endDate,
                                                  dateJoinedBrand,
                                                  true),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: AppColors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            const Icon(
                                                Icons
                                                    .keyboard_arrow_down_outlined,
                                                color: AppColors.white)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${DateFormat('d MMM, yy\'').format(startDate)}  - ${DateFormat('d MMM, yy\'').format(endDate)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Container(
                              color: AppColors.grey,
                              height: 1.0,
                            ),
                          ],
                        ),
                      ),
                      (MediaQuery.of(context).size.height * 0.07) + 1,
                    ),
                    pinned: true,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 5)),
                  loadedState.purchasesHistoryObjects.isNotEmpty
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              PurchaseHistoryModel obj =
                                  loadedState.purchasesHistoryObjects[index];
                              return BrandPurchaseCard(
                                bono: obj.bono,
                                user: obj.user,
                                brand: obj.brand,
                                bonoRequest: obj.bonoReq,
                                purchase: obj.purchase,
                              );
                            },
                            childCount: loadedState.purchasesHistoryObjects
                                .length, // 1000 list items
                          ),
                        )
                      : SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.25),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Image.asset(Constants.emptyCalendar)),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.005),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "${AppLocalizations.of(context)!.noData.split(" ")[0]} ${AppLocalizations.of(context)!.payments.toLowerCase()}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                ],
              ),
            );
          default:
            // Handle all other states aka Loading or Initial
            DateTime startDate =
                DateTime.now().subtract(const Duration(days: 7));
            DateTime endDate = DateTime.now();
            DateTime dateJoinedBrand = DateTime(
                int.parse(currentBrand.dateJoined!.split("-")[2]),
                int.parse(currentBrand.dateJoined!.split("-")[1]),
                int.parse(currentBrand.dateJoined!.split("-")[0]),
                0,
                0);
            // Handles Loaded State
            List<bool> allFilters = [];
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    surfaceTintColor: AppColors.darkGrey,
                    backgroundColor: AppColors.darkGrey,
                    expandedHeight: MediaQuery.of(context).size.height * 0.14,
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    elevation: 0,
                    floating: true,
                    pinned: true,
                    title: AnimatedOpacity(
                        opacity: appBarExpanded ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(AppLocalizations.of(context)!.payments,
                            style: Theme.of(context)
                                .appBarTheme
                                .titleTextStyle
                                ?.copyWith(
                                  color: AppColors.white,
                                ))),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        color: AppColors.darkGrey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.05,
                                  right: MediaQuery.of(context).size.width *
                                      0.025),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.payments,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          color: AppColors.white,
                                        ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.08,
                                    width: MediaQuery.of(context).size.width *
                                        0.40,
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.width *
                                        0.09,
                                    width: MediaQuery.of(context).size.width *
                                        0.09,
                                    child: ClipOval(
                                      child: Material(
                                        color:
                                            Colors.transparent, // Button color
                                        child: InkWell(
                                          splashColor: Theme.of(context)
                                              .colorScheme
                                              .background, // Splash color
                                          onTap: null,
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.09,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.09,
                                              child: Icon(
                                                Icons.filter_list,
                                                color:
                                                    allFilters.contains(false)
                                                        ? AppColors.darkGrey
                                                        : AppColors.white,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.07,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      titlePadding: EdgeInsets.zero,
                      //centerTitle: true,
                    ),
                    centerTitle: false,
                    leading: Builder(
                      builder: (BuildContext innerContext) => Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.02),
                        child: IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: AppColors.white,
                              size: MediaQuery.of(context).size.height * 0.04,
                            ),
                            onPressed: () =>
                                mambaProScaffoldKey.currentState?.openDrawer()),
                      ),
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          unreadNotifications(context),
                          unreadChats(context),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03),
                          GestureDetector(
                            onTap: () => navigateToProfileScreen(context),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.width * 0.08,
                              child: Center(
                                child: CircularImage(
                                  size:
                                      MediaQuery.of(context).size.width * 0.08,
                                  image: currentUser.imageUrl,
                                  color: AppColors.grey,
                                  borderWidth: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                    ],
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegateSecond(
                      Container(
                        height: (MediaQuery.of(context).size.height * 0.07) + 1,
                        color: AppColors.darkGrey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.04,
                                  right:
                                      MediaQuery.of(context).size.width * 0.04),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.09,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.09,
                                        margin: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightGrey
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          splashRadius: 20,
                                          splashColor: Theme.of(context)
                                              .colorScheme
                                              .background, // Splash color
                                          padding:
                                              const EdgeInsets.only(right: 2),
                                          alignment: Alignment.center,
                                          icon: Icon(
                                            FontAwesomeIcons.arrowDownWideShort,
                                            color: AppColors.white,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                          ),
                                          onPressed: null,
                                        ),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: AppColors.lightGrey
                                              .withOpacity(0.1),
                                          shape: RoundedRectangleBorder(
                                            // add this
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.only(
                                              left: 16.0, right: 10.0),
                                        ),
                                        onPressed: () => _show(
                                            context,
                                            startDate,
                                            endDate,
                                            dateJoinedBrand),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              returnCorrectText(
                                                  context,
                                                  startDate,
                                                  endDate,
                                                  dateJoinedBrand,
                                                  true),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: AppColors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            const Icon(
                                                Icons
                                                    .keyboard_arrow_down_outlined,
                                                color: AppColors.white)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${DateFormat('d MMM, yy\'').format(startDate)}  - ${DateFormat('d MMM, yy\'').format(endDate)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Container(
                              color: AppColors.grey,
                              height: 1.0,
                            ),
                          ],
                        ),
                      ),
                      (MediaQuery.of(context).size.height * 0.07) + 1,
                    ),
                    pinned: true,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 5)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.04,
                              vertical:
                                  MediaQuery.of(context).size.width * 0.03),
                          child: Row(
                            children: [
                              Shimmer.fromColors(
                                baseColor: AppColors.grey,
                                highlightColor: AppColors.grey.withOpacity(0.5),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  decoration: const BoxDecoration(
                                    color: AppColors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.04), // adjust this value as needed
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// USER
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Shimmer.fromColors(
                                          baseColor: AppColors.grey,
                                          highlightColor:
                                              AppColors.grey.withOpacity(0.5),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
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
                                          highlightColor:
                                              AppColors.grey.withOpacity(0.5),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
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
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.012),

                                    /// BONO
                                    Shimmer.fromColors(
                                      baseColor: AppColors.grey,
                                      highlightColor:
                                          AppColors.grey.withOpacity(0.5),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.015,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.012),

                                    /// DETAILS
                                    Shimmer.fromColors(
                                      baseColor: AppColors.grey,
                                      highlightColor:
                                          AppColors.grey.withOpacity(0.5),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.015,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.55,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.012),

                                    /// DATE
                                    Shimmer.fromColors(
                                      baseColor: AppColors.grey,
                                      highlightColor:
                                          AppColors.grey.withOpacity(0.5),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.013,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
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
                      },
                      childCount: 10, // 1000 list items
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                ],
              ),
            );
        }
      },
    );
  }
}

class _SliverAppBarDelegateSecond extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegateSecond(this._widget, this._height);

  final Widget _widget;
  final double _height;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkGrey,
      ),
      child: _widget,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegateSecond oldDelegate) {
    return true;
  }
}
