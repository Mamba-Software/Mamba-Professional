// ignore_for_file: avoid_print
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/SelectCalendar/SelectCalendarDate.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Stats/ClientsStats/GenderGroup.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Stats/PurchasesStats/BonosPurchased.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Stats/PurchasesStats/PaymentMethodStat.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Stats/PurchasesStats/TotalBenefit.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Stats/SessionsStats/DayOffer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Stats/SessionsStats/TimeToTimeOffer.dart';
import '../../../../../../../Data/Models/Event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../Globals/Widgets/GroupOfComponents/Stats/ClientsStats/AgeRange.dart';
import '../../../../../Globals/Widgets/GroupOfComponents/Stats/ClientsStats/ClientNumber.dart';
import '../../../../../Globals/Widgets/GroupOfComponents/Stats/SessionsStats/SessionsMade.dart';
import '../../../../../Globals/Widgets/GroupOfComponents/Stats/SessionsStats/TimeOffer.dart';

class Stats extends StatefulWidget {
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;
  int? initIndex;

  Stats(
      {Key? key,
      required this.brandId,
      required this.pinned,
      required this.pinnedChanged,
      this.initIndex})
      : super(key: key);

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> with SingleTickerProviderStateMixin {
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;

  bool get _isAppBarExpanded {
    return _scrollController!.hasClients &&
        _scrollController!.offset >
            (MediaQuery.of(context).size.height * 0.13 - kToolbarHeight);
  }

  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;

  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;

  //DateTime endDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime endDate = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day, 23, 59).subtract(const Duration(days: 1));

  DateTime startDate = DateTime.now().subtract(const Duration(days: 31));

  DateTime backEndDate = DateTime.now().subtract(const Duration(days: 32));
  DateTime backStartDate = DateTime.now().subtract(const Duration(days: 62));

  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false];

  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();

  // Brand
  Brand brand = Brand();
  DateTime dateJoinedBrand = DateTime.now();

  double addStatsValue = 0.25;

  List<Event> events = [], filteredEvents = [], filteredBackEvents = [];

  List<Usuario> users = [],
      filteredUsers = [],
      filteredBackUsers = [],
      activeUsers = [];

  List<Purchase> purchases = [],
      filteredPurchases = [],
      filteredBackPurchases = [];

  List<Bono> bonos = [];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    if (widget.initIndex != null) {
      _selectedIndex = widget.initIndex!;
    }
    getBrandDetails();
    getCollections();
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
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: " +
        MediaQuery.of(context).size.height.toString() +
        " " +
        MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: " +
        safeAreaHeight.toString() +
        " " +
        safeAreaWidth.toString());
  }

  // Gets the Events Done by the Brand
  Future<void> getBrandDetails() async {
    brand = await _brandDataService.getBrandDetails(widget.brandId);
    var dateJoinedSplit = brand.dateJoined!.split("-");
    dateJoinedBrand = DateTime(int.parse(dateJoinedSplit[2]), int.parse(dateJoinedSplit[1]), int.parse(dateJoinedSplit[0]), 0, 0);
  }

  Future<void> getCollections() async {
    events = await _brandDataService.getAllEventsFromBrandStats(widget.brandId);
    users = await _brandDataService
        .getBrandClients(widget.brandId);
    //purchases = await _brandDataService.getBrandPurchases(widget.brandId);
    //bonos = await _brandDataService.getAllBonosFromBrandList(widget.brandId);
    purchases = await _brandDataService
        .getBrandPurchases(widget.brandId);
    bonos = await _brandDataService
        .getAllBonosFromBrandStats(widget.brandId);
    setState(() {
      setActiveUsers();
      applyAllFilters();
      isLoading = false;
    });
  }

  void setActiveUsers() {
    List<Usuario> userActive = [];
    for (int i = 0; i < users.length; ++i) {
      if (users[i].lastEventAt != null) {
        userActive.add(users[i]);
      }
    }
    activeUsers = userActive
        .where((element) =>
            element.lastEventAt!.compareTo(Timestamp.fromDate(
                    DateTime.now().subtract(const Duration(days: 30)))) >=
                0 &&
            element.lastEventAt!
                    .compareTo(Timestamp.fromDate(DateTime.now())) <=
                0)
        .toList();
  }

  void applyAllFilters() {
    applyFilteredEvents();
    applyFilteredUsers();
    applyFilteredPurchases();
  }

  void applyFilteredEvents() {
    /*
    print(startDate.toString());
    print(endDate.toString());
     */
    filteredEvents = events
        .where((element) =>
            element.doneAt!.compareTo(Timestamp.fromDate(startDate)) >= 0 &&
            element.doneAt!.compareTo(Timestamp.fromDate(endDate)) <= 0)
        .toList();

    /*print(filteredEvents.length);*/
    int days = daysBetween(startDate, endDate);
    DateTime backEndDate = endDate.subtract(Duration(days: days));
    DateTime backStartDate = startDate.subtract(Duration(days: days));
    filteredBackEvents = events
        .where((element) =>
            element.doneAt!.compareTo(Timestamp.fromDate(backStartDate)) >= 0 &&
            element.doneAt!.compareTo(Timestamp.fromDate(backEndDate)) <= 0)
        .toList();
  }

  void applyFilteredPurchases() {
    filteredPurchases = purchases
        .where((element) =>
            element.purchasedAt!.compareTo(Timestamp.fromDate(startDate)) >=
                0 &&
            element.purchasedAt!.compareTo(Timestamp.fromDate(endDate)) <= 0)
        .toList();
    int days = daysBetween(startDate, endDate);
    DateTime backEndDate = endDate.subtract(Duration(days: days));
    DateTime backStartDate = startDate.subtract(Duration(days: days));
    filteredBackPurchases = purchases
        .where((element) =>
            element.purchasedAt!.compareTo(Timestamp.fromDate(backStartDate)) >=
                0 &&
            element.purchasedAt!.compareTo(Timestamp.fromDate(backEndDate)) <=
                0)
        .toList();
  }

  void applyFilteredUsers() {
    for(int j = 0; j < users.length; ++j)
      {
        if(users[j].dateJoined != null)
          {
            filteredUsers.add(users[j]);
          }
      }
    filteredUsers = filteredUsers
        .where((element) =>
            DateFormat('dd-MM-yy')
                    .parse(element.dateJoined!)
                    .compareTo(startDate) >=
                0 &&
            DateFormat('dd-MM-yy')
                    .parse(element.dateJoined!)
                    .compareTo(endDate) <=
                0)
        .toList();
    int days = daysBetween(startDate, endDate);
    DateTime backEndDate = endDate.subtract(Duration(days: days));
    DateTime backStartDate = startDate.subtract(Duration(days: days));
    filteredBackUsers = filteredUsers
        .where((element) =>
            DateFormat('dd-MM-yy')
                    .parse(element.dateJoined!)
                    .compareTo(backStartDate) >=
                0 &&
            DateFormat('dd-MM-yy')
                    .parse(element.dateJoined!)
                    .compareTo(backEndDate) <=
                0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }
    return Scaffold(
      body: currentUser.brandRole < 2 ? DefaultTabController(
        length: 3,
        initialIndex: _selectedIndex,
        child: ExtendedNestedScrollView(
          pinnedHeaderSliverHeightBuilder: () {
            return MediaQuery.of(context).size.height * 0.12;
          },
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: AppColors.darkGrey,
                expandedHeight: MediaQuery.of(context).size.height * 0.13,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                elevation: 0,
                floating: false,
                pinned: true,
                forceElevated: innerBoxIsScrolled,
                //snap: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.darkGrey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.05,
                              right: MediaQuery.of(context).size.width * 0.025),
                          child: Text(
                            AppLocalizations.of(context)!.stats,
                            style:
                                Theme.of(context).textTheme.headline1?.copyWith(
                                      color: AppColors.white,
                                    ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),
                      ],
                    ),
                  ),
                  titlePadding: EdgeInsets.zero,
                  //centerTitle: true,
                ),
                title: AnimatedOpacity(
                    opacity: appBarExpanded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                        AppLocalizations.of(context)!.stats,
                        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: AppColors.white,)
                    )
                ),
                centerTitle: true,
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
                  Padding(
                    padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.01),
                    child: IconButton(
                      icon: Icon(
                        widget.pinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        color: widget.pinned
                            ? AppColors.red
                            : AppColors.white.withOpacity(0.5),
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                      onPressed: () {
                        setState(() {
                          widget.pinned = !widget.pinned;
                        });
                        widget.pinnedChanged(widget.pinned);
                      },
                    ),
                  ),
                ],
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegateSecond(
                  Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04, right: MediaQuery.of(context).size.width * 0.04),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                returnCorrectText(),
                                style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.keyboard_arrow_down_outlined, color: AppColors.white)
                            ],
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.lightGrey.withOpacity(0.1),
                            shape: RoundedRectangleBorder(  // add this
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.only(left: 16.0, right: 10.0),
                          ),
                          onPressed: _show,
                        ),
                        Text(
                          '${DateFormat('d MMM, yy\'').format(startDate)}  - ${DateFormat('d MMM, yy\'').format(endDate)}',
                          style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  MediaQuery.of(context).size.height * 0.06,
                ),
                pinned: true,
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorWeight: 3,
                    indicatorColor: AppColors.grey,
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.white,
                    labelStyle: Theme.of(context).textTheme.bodyText2,
                    tabs: [
                      Tab(
                        text: AppLocalizations.of(context)!.events,
                      ),
                      Tab(
                        text: AppLocalizations.of(context)!.clients,
                      ),
                      Tab(
                        text: AppLocalizations.of(context)!.facturation,
                      ),
                    ],
                    onTap: (index) {
                      switch (index) {
                        case 0:
                          mixpanel!.track('brand_stats_view_events_tab');
                          break;
                        case 1:
                          mixpanel!.track('brand_stats_view_clients_tab');
                          break;
                        case 2:
                          mixpanel!.track('brand_stats_view_fact_tab');
                          break;
                      }
                    },
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              buildEventsStatsPage(),
              buildClientsStatsPage(),
              buildFactStatsPage(),
            ],
          ),
        ),
      ) : DefaultTabController(
        length: 2,
        initialIndex: _selectedIndex,
        child: ExtendedNestedScrollView(
          pinnedHeaderSliverHeightBuilder: () {
            return MediaQuery.of(context).size.height * 0.17;
          },
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: AppColors.darkGrey,
                expandedHeight: MediaQuery.of(context).size.height * 0.13,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                elevation: 0,
                floating: false,
                pinned: true,
                forceElevated: innerBoxIsScrolled,
                //snap: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.darkGrey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.05,
                              right: MediaQuery.of(context).size.width * 0.025),
                          child: Text(
                            AppLocalizations.of(context)!.stats,
                            style:
                            Theme.of(context).textTheme.headline1?.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),
                      ],
                    ),
                  ),
                  titlePadding: EdgeInsets.zero,
                  //centerTitle: true,
                ),
                title: appBarExpanded
                    ? Text(
                  AppLocalizations.of(context)!.stats,
                  style: Theme.of(context)
                      .appBarTheme
                      .titleTextStyle
                      ?.copyWith(
                    color: AppColors.white,
                  ),
                )
                    : Container(),
                centerTitle: true,
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
                  Padding(
                    padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.01),
                    child: IconButton(
                      icon: Icon(
                        widget.pinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        color: widget.pinned
                            ? AppColors.red
                            : AppColors.white.withOpacity(0.5),
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                      onPressed: () {
                        setState(() {
                          widget.pinned = !widget.pinned;
                        });
                        widget.pinnedChanged(widget.pinned);
                      },
                    ),
                  ),
                ],
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegateSecond(
                  Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04, right: MediaQuery.of(context).size.width * 0.04),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                returnCorrectText(),
                                style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.keyboard_arrow_down_outlined, color: AppColors.white)
                            ],
                          ),
                          style: TextButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            backgroundColor: AppColors.lightGrey.withOpacity(0.1),
                            shape: RoundedRectangleBorder(  // add this
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.only(left: 16.0, right: 10.0),
                          ),
                          onPressed: _show,
                        ),
                        Text(
                          '${DateFormat('d MMM, yy\'').format(startDate)}  - ${DateFormat('d MMM, yy\'').format(endDate)}',
                          style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  MediaQuery.of(context).size.height * 0.06,
                ),
                pinned: true,
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorWeight: 3,
                    indicatorColor: AppColors.grey,
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.white,
                    labelStyle: Theme.of(context).textTheme.bodyText2,
                    tabs: [
                      Tab(
                        text: AppLocalizations.of(context)!.events,
                      ),
                      Tab(
                        text: AppLocalizations.of(context)!.clients,
                      ),
                    ],
                    onTap: (index) {
                      switch (index) {
                        case 0:
                          mixpanel!.track('brand_stats_view_events_tab');
                          break;
                        case 1:
                          mixpanel!.track('brand_stats_view_clients_tab');
                          break;
                      }
                    },
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              buildEventsStatsPage(),
              buildClientsStatsPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEventsStatsPage() => SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder: (context) => CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: eventsStatsPage(),
              ),
            ],
          ),
        ),
      );

  Widget buildClientsStatsPage() => SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder: (context) => CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: clientsStatsPage(),
              ),
            ],
          ),
        ),
      );

  Widget buildFactStatsPage() => SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder: (context) => CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: factStatsPage(),
              ),
            ],
          ),
        ),
      );

  Widget selectedTab(String text, int index, double width) {
    return Tab(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(text,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            _selectedIndex == index
                ? Container(
                    width: MediaQuery.of(context).size.width * width,
                    height: 3,
                    //Theme.of(context).scaffoldBackgroundColor,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget statsTitle(String text) {
    return Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.03,
            left: MediaQuery.of(context).size.width * 0.05),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .headline1
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget dividerStats() {
    return Padding(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
      child: Divider(color: Theme.of(context).backgroundColor, thickness: 2),
    );
  }

  Widget eventsStatsPage() {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.25,
        ),
        child: LoadingView(),
      );
    }
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.05,
          right: MediaQuery.of(context).size.width * 0.06),
      child: Column(
        children: [
          statsTitle(AppLocalizations.of(context)!.eventsDone),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02),
            child: SessionsMade(
              events: filteredEvents,
              backEvents: filteredBackEvents,
            ),
          ),
          dividerStats(),
          statsTitle(AppLocalizations.of(context)!.daysDemand),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02),
            child: DayOffer(
              events: filteredEvents,
              context: context,
            ),
          ),
          dividerStats(),
          statsTitle(AppLocalizations.of(context)!.timeOffer),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02),
            child: TimeOffer(events: filteredEvents),
          ),
          dividerStats(),
          statsTitle(AppLocalizations.of(context)!.timeToTimeOffer),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02),
            child: TimeToTimeOffer(events: filteredEvents),
          ),
        ],
      ),
    );
  }

  Widget clientsStatsPage() {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.25,
        ),
        child: LoadingView(),
      );
    }
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.05,
          right: MediaQuery.of(context).size.width * 0.06),
      child: Column(
        children: [
          statsTitle(AppLocalizations.of(context)!.numberClients),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                bottom: MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.width * 0.05),
            child: ClientNumber(
                users: filteredUsers,
                activeUsers: activeUsers,
                allUsers: users),
          ),
          dividerStats(),
          statsTitle(AppLocalizations.of(context)!.ageRange),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02),
            child: AgeRange(users: filteredUsers),
          ),
          dividerStats(),
          statsTitle(AppLocalizations.of(context)!.gender),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GenderGroup(
                  users: filteredUsers,
                  resize: false,
                  context: context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget staffStatsPage() {
    return Column(
      children: [
        statsTitle('Entrenadores'),
        Divider(color: Theme.of(context).backgroundColor, thickness: 2),
      ],
    );
  }

  Widget factStatsPage() {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.25,
        ),
        child: LoadingView(),
      );
    }
    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.00),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.00,
                right: MediaQuery.of(context).size.width * 0.06),
            child: Column(
              children: [
                statsTitle(AppLocalizations.of(context)!.totalInvoice),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.02),
                  child: TotalBenefitPurchases(
                      purchases: filteredPurchases,
                      backPurchases: filteredBackPurchases),
                ),
                dividerStats(),
              ],
            ),
          ),
        ),
        statsTitle(AppLocalizations.of(context)!.paymentMethod),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.02),
          child: PaymentMethodStat(purchases: filteredPurchases, context: context,),
        ),
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.06),
          child: Column(
            children: [
              statsTitle(AppLocalizations.of(context)!.bonos),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
          child: BonosPurchased(
            purchases: filteredPurchases,
            bonos: bonos,
            brand: brand,
          ),
        ),
      ],
    );
  }

  void _show() async {
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
          ),
        );
      },
    );
    if (result != null) {
      mixpanel!.track('brand_stats_view_dates', properties: {
        'startDate': result.first,
        'endDate': result.last,
      });
      setState(() {
        startDate = result.first;
        endDate = result.last;
        applyAllFilters();
      });
    }
  }

  String returnCorrectText() {
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    int daysDifference = endDate.difference(startDate).inDays;
    switch (daysDifference) {
      case 7:
        if (yesterday.day == startDate.day && yesterday.month == startDate.month && yesterday.year == startDate.year) {
          return AppLocalizations.of(context)!.lastNDays(endDate.difference(startDate).inDays.toString());
        } else {
          return AppLocalizations.of(context)!.personlized;
        }
      case 14:
        if (yesterday.day == startDate.day && yesterday.month == startDate.month && yesterday.year == startDate.year) {
          return AppLocalizations.of(context)!.lastNDays(endDate.difference(startDate).inDays.toString());
        } else {
          return AppLocalizations.of(context)!.personlized;
        }
      case 30:
        if (yesterday.day == startDate.day && yesterday.month == startDate.month && yesterday.year == startDate.year) {
          return AppLocalizations.of(context)!.lastNDays(endDate.difference(startDate).inDays.toString());
        } else {
          return AppLocalizations.of(context)!.personlized;
        }
      case 90:
        if (yesterday.day == startDate.day && yesterday.month == startDate.month && yesterday.year == startDate.year) {
          return AppLocalizations.of(context)!.lastNDays(endDate.difference(startDate).inDays.toString());
        } else {
          return AppLocalizations.of(context)!.personlized;
        }
      default:
        return AppLocalizations.of(context)!.personlized;
    }

  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkGrey,
          border: Border(
            bottom: BorderSide(width: 1.0, color: AppColors.grey),
          ),
        ),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
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
    return Material(
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkGrey,
        ),
        child: _widget,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegateSecond oldDelegate) {
    return true;
  }
}
