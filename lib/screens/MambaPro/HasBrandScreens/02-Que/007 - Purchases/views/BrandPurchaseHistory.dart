import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Calendars/SelectCalendar/SelectCalendarDate.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/widgets/appbar/ResponsiveSliverAppBar.dart';
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
      return "${context.l10n.thisEventAndRest.split(" ")[0]} ${StringUtils().toCapitalized(context.l10n.month)}";
    }

    // Check for "previous month" selection
    if (startDate.day == 1 &&
        startDate.month == now.month - 1 &&
        startDate.year == now.year &&
        endDate.day == DateTime(now.year, now.month, 0).day &&
        endDate.month == now.month - 1 &&
        endDate.year == now.year) {
      return context.l10n.previousMonth;
    }

    // Check for "Historic" selection
    if (startDate.day == dateJoinedBrand.day &&
        startDate.month == dateJoinedBrand.month &&
        startDate.year == dateJoinedBrand.year &&
        endDate.day == maxEndDate.day &&
        endDate.month == maxEndDate.month &&
        endDate.year == maxEndDate.year) {
      return context.l10n.historic;
    }

    switch (daysDifference) {
      case 7:
      case 14:
      case 30:
      case 90:
        if (maxEndDate.day == endDate.day &&
            maxEndDate.month == endDate.month &&
            maxEndDate.year == endDate.year) {
          return context.l10n
              .lastNDays(endDate.difference(startDate).inDays.toString());
        } else {
          return context.l10n.personlized;
        }
      default:
        return context.l10n.personlized;
    }
  }

  String returnFilteredStatusString(List<bool> filterByPurchaseStatus) {
    String filteredRoles = "";
    int cnt = 0;
    if (filterByPurchaseStatus[0]) {
      filteredRoles += "${context.l10n.verfied}, ";
      cnt += 1;
    }
    if (filterByPurchaseStatus[1]) {
      filteredRoles += "${context.l10n.unverfied}, ";
      cnt += 1;
    }
    if (filterByPurchaseStatus[2]) {
      filteredRoles += context.l10n.toConfirm;
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
      activeStaff += "${context.l10n.yes}, ";
      cnt += 1;
    }
    if (filterByActivePurchases[1]) {
      activeStaff += context.l10n.no;
      cnt += 1;
    }
    if (cnt == 1) {
      return activeStaff.split(", ")[0];
    }
    return activeStaff;
  }

  FlexibleSpaceBar returnFlexibleSpaceBar(
      double height, BrandPurchasesLoaded state) {
    final brandPurchasesCubit = context.read<BrandPurchasesCubit>();
    BrandPurchasesLoaded loadedState = state;
    List<bool> filterByPurchaseStatus = loadedState.filterByPurchaseStatus;
    List<bool> filterByActivePurchases = loadedState.filterByActivePurchases;
    List<bool> allFilters = filterByPurchaseStatus + filterByActivePurchases;

    return FlexibleSpaceBar(
      background: Container(
        color: AppColors.darkGrey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height / 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.payments,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.white,
                        ),
                  ),
                  SizedBox(
                    height: iconSizeBig,
                    width: iconSizeBig,
                    child: ClipOval(
                      child: Material(
                        color: allFilters.contains(false)
                            ? AppColors.white
                            : Colors.transparent, // Button color
                        child: InkWell(
                          splashColor: AppColors.white.withOpacity(0.2), // Splash color
                          onTap: () async {
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
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    final PageController pageController =
                                        PageController(initialPage: 0);
                                    ValueNotifier<int> currentPage =
                                        ValueNotifier(0);
                                    ValueNotifier<bool> isTypePurchase =
                                        ValueNotifier(true);
                                    return FractionallySizedBox(
                                      heightFactor: 0.33,
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              ValueListenableBuilder<int>(
                                                valueListenable: currentPage,
                                                builder:
                                                    (context, value, child) {
                                                  return ListTile(
                                                    title: Text(
                                                        context.l10n.filterBy,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                        textAlign:
                                                            TextAlign.left),
                                                    trailing: TextButton(
                                                        child: Text(
                                                            context.l10n.clear,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall),
                                                        onPressed: () {
                                                          filterByPurchaseStatus =
                                                              [
                                                            true,
                                                            true,
                                                            true
                                                          ];
                                                          filterByActivePurchases =
                                                              [true, true];
                                                          brandPurchasesCubit.filterBy(
                                                              filterByPurchaseStatus,
                                                              filterByActivePurchases);
                                                          Navigator.pop(
                                                              context);
                                                        }),
                                                    dense: true,
                                                    onTap: value == 0
                                                        ? null
                                                        : () {
                                                            pageController
                                                                .previousPage(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                              curve:
                                                                  Curves.ease,
                                                            );
                                                          },
                                                  );
                                                },
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.21,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: PageView(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  controller: pageController,
                                                  onPageChanged: (int page) {
                                                    currentPage.value = page;
                                                  },
                                                  children: <Widget>[
                                                    Column(
                                                      children: [
                                                        ListTile(
                                                          onTap: () {
                                                            isTypePurchase
                                                                .value = true;
                                                            pageController
                                                                .nextPage(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                              curve:
                                                                  Curves.ease,
                                                            );
                                                          },
                                                          title: Text(
                                                              context
                                                                  .l10n.state,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                          subtitle: Text(
                                                              returnFilteredStatusString(
                                                                  filterByPurchaseStatus),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                          trailing: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.15,
                                                            child: Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .arrow_forward_ios,
                                                                    size: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.04,
                                                                    color: AppColors
                                                                        .grey)),
                                                          ),
                                                        ),
                                                        ListTile(
                                                          onTap: () {
                                                            isTypePurchase
                                                                .value = false;
                                                            pageController
                                                                .nextPage(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                              curve:
                                                                  Curves.ease,
                                                            );
                                                          },
                                                          title: Text(
                                                              context.l10n
                                                                  .activeRates,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                          subtitle: Text(
                                                              returnFilteredActiveBonosString(
                                                                  filterByActivePurchases),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left),
                                                          trailing: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.15,
                                                            child: Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .arrow_forward_ios,
                                                                    size: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.04,
                                                                    color: AppColors
                                                                        .grey)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    ValueListenableBuilder<
                                                        bool>(
                                                      valueListenable:
                                                          isTypePurchase,
                                                      builder: (context, value,
                                                          child) {
                                                        return value
                                                            ? Column(
                                                                children: [
                                                                  ListTile(
                                                                    onTap: () {
                                                                      // Check if the Only True
                                                                      var filterActive =
                                                                          List.from(
                                                                              filterByPurchaseStatus);
                                                                      filterActive.retainWhere((element) =>
                                                                          element ==
                                                                          true);
                                                                      if (!(filterActive.length ==
                                                                              1 &&
                                                                          filterByPurchaseStatus[
                                                                              0])) {
                                                                        filterByPurchaseStatus[0] =
                                                                            !filterByPurchaseStatus[0];
                                                                        brandPurchasesCubit.filterBy(
                                                                            filterByPurchaseStatus,
                                                                            filterByActivePurchases);
                                                                        Navigator.pop(
                                                                            context);
                                                                      }
                                                                    },
                                                                    title: Text(
                                                                        context
                                                                            .l10n
                                                                            .verfied,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge,
                                                                        textAlign:
                                                                            TextAlign.left),
                                                                    trailing: filterByPurchaseStatus[
                                                                            0]
                                                                        ? SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15,
                                                                            child:
                                                                                Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                          )
                                                                        : SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15),
                                                                  ),
                                                                  ListTile(
                                                                    onTap: () {
                                                                      // Check if the Only True
                                                                      var filterActive =
                                                                          List.from(
                                                                              filterByPurchaseStatus);
                                                                      filterActive.retainWhere((element) =>
                                                                          element ==
                                                                          true);
                                                                      if (!(filterActive.length ==
                                                                              1 &&
                                                                          filterByPurchaseStatus[
                                                                              1])) {
                                                                        filterByPurchaseStatus[1] =
                                                                            !filterByPurchaseStatus[1];
                                                                        brandPurchasesCubit.filterBy(
                                                                            filterByPurchaseStatus,
                                                                            filterByActivePurchases);
                                                                        Navigator.pop(
                                                                            context);
                                                                      }
                                                                    },
                                                                    title: Text(
                                                                        context
                                                                            .l10n
                                                                            .unverfied,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge,
                                                                        textAlign:
                                                                            TextAlign.left),
                                                                    trailing: filterByPurchaseStatus[
                                                                            1]
                                                                        ? SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15,
                                                                            child:
                                                                                Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                          )
                                                                        : SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15),
                                                                  ),
                                                                  ListTile(
                                                                    onTap: () {
                                                                      // Check if the Only True
                                                                      var filterActive =
                                                                          List.from(
                                                                              filterByPurchaseStatus);
                                                                      filterActive.retainWhere((element) =>
                                                                          element ==
                                                                          true);
                                                                      if (!(filterActive.length ==
                                                                              1 &&
                                                                          filterByPurchaseStatus[
                                                                              2])) {
                                                                        filterByPurchaseStatus[2] =
                                                                            !filterByPurchaseStatus[2];
                                                                        brandPurchasesCubit.filterBy(
                                                                            filterByPurchaseStatus,
                                                                            filterByActivePurchases);
                                                                        Navigator.pop(
                                                                            context);
                                                                      }
                                                                    },
                                                                    title: Text(
                                                                        context
                                                                            .l10n
                                                                            .toConfirm,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge,
                                                                        textAlign:
                                                                            TextAlign.left),
                                                                    trailing: filterByPurchaseStatus[
                                                                            2]
                                                                        ? SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15,
                                                                            child:
                                                                                Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                          )
                                                                        : SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15),
                                                                  ),
                                                                ],
                                                              )
                                                            : Column(
                                                                children: [
                                                                  ListTile(
                                                                    onTap: () {
                                                                      // Check if the Only True
                                                                      var filterActive =
                                                                          List.from(
                                                                              filterByActivePurchases);
                                                                      filterActive.retainWhere((element) =>
                                                                          element ==
                                                                          true);
                                                                      if (!(filterActive.length ==
                                                                              1 &&
                                                                          filterByActivePurchases[
                                                                              0])) {
                                                                        filterByActivePurchases[0] =
                                                                            !filterByActivePurchases[0];
                                                                        brandPurchasesCubit.filterBy(
                                                                            filterByPurchaseStatus,
                                                                            filterByActivePurchases);
                                                                        Navigator.pop(
                                                                            context);
                                                                      }
                                                                    },
                                                                    title: Text(
                                                                        context
                                                                            .l10n
                                                                            .yes,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge,
                                                                        textAlign:
                                                                            TextAlign.left),
                                                                    trailing: filterByActivePurchases[
                                                                            0]
                                                                        ? SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15,
                                                                            child:
                                                                                Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                          )
                                                                        : SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15),
                                                                  ),
                                                                  ListTile(
                                                                    onTap: () {
                                                                      // Check if the Only True
                                                                      var filterActive =
                                                                          List.from(
                                                                              filterByActivePurchases);
                                                                      filterActive.retainWhere((element) =>
                                                                          element ==
                                                                          true);
                                                                      if (!(filterActive.length ==
                                                                              1 &&
                                                                          filterByActivePurchases[
                                                                              1])) {
                                                                        filterByActivePurchases[1] =
                                                                            !filterByActivePurchases[1];
                                                                        brandPurchasesCubit.filterBy(
                                                                            filterByPurchaseStatus,
                                                                            filterByActivePurchases);
                                                                        Navigator.pop(
                                                                            context);
                                                                      }
                                                                    },
                                                                    title: Text(
                                                                        context
                                                                            .l10n
                                                                            .no,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge,
                                                                        textAlign:
                                                                            TextAlign.left),
                                                                    trailing: filterByActivePurchases[
                                                                            1]
                                                                        ? SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15,
                                                                            child:
                                                                                Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                          )
                                                                        : SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15),
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
                              width: iconSizeBig,
                              height: iconSizeBig,
                              child: Icon(
                                Icons.filter_list,
                                color: allFilters.contains(false)
                                    ? AppColors.darkGrey
                                    : AppColors.white,
                                size: iconSize,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandPurchasesCubit, BrandPurchasesState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case BrandPurchasesLoaded:
            // Handles Loaded State
            BrandPurchasesLoaded loadedState = state as BrandPurchasesLoaded;
            // Handle Dates for Filtering of Date
            DateTime startDate =
                DateTime.now().subtract(const Duration(days: 7));
            DateTime endDate = DateTime.now();
            DateTime dateJoinedBrand = DateTime(
                int.parse(currentBrand.dateJoined!.split("-")[2]),
                int.parse(currentBrand.dateJoined!.split("-")[1]),
                int.parse(currentBrand.dateJoined!.split("-")[0]),
                0,
                0);
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  ResponsiveSliverAppBar(
                    height: context.height * 0.14,
                    title: context.l10n.payments,
                    appBarExpanded: appBarExpanded,
                    flexibleSpace: returnFlexibleSpaceBar(
                      context.height * 0.14,
                      loadedState,
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegateSecond(
                      Container(
                        height: (context.height * 0.07) + 1,
                        color: AppColors.darkGrey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: iconSizeBig,
                                        height: iconSizeBig,
                                        margin: const EdgeInsets.only(
                                          right: 8,
                                        ),
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
                                            size: iconSizeSmall,
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
                                              left: 16.0, right: 16.0),
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
                                    style:
                                        context.textTheme.bodyMedium!.copyWith(
                                      color: AppColors.white,
                                    ),
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
                      (context.height * 0.07) + 1,
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
                                  child: Image.asset(Assets.emptyCalendar)),
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
                                        "${context.l10n.noData.split(" ")[0]} ${context.l10n.payments.toLowerCase()}",
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
            return Scaffold(
                backgroundColor: Colors.transparent,
                body: LoadingView(
                  isSmall: true,
                ));
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
