// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/SelectCalendar/SelectCalendarDate.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/CalendarPopUpView.dart';
import '../../../../../../../Data/Models/Event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../../../../../Globals/Widgets/GroupOfComponents/Stats/SessionsStats/SessionsMade.dart';

class Stats extends StatefulWidget {
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;
  int? initIndex;
  Stats({Key? key, required this.brandId, required this.pinned, required this.pinnedChanged, this.initIndex}) : super(key: key);

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats>  with SingleTickerProviderStateMixin {

  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.15 - kToolbarHeight);
  }

  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;

  DateTime  endDate = DateTime.now().subtract(Duration(days: 30));
  DateTime startDate = DateTime.now().subtract(Duration(days: 60));

  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false, false, false];

  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  // Brand
  Brand brand = Brand();

  double addStatsValue = 0.25;

  List<Event> events = [], filteredEvents = [];

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    if(widget.initIndex != null)
      {
        _selectedIndex = widget.initIndex!;
      }
    getCollections();
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() => _isAppBarExpanded ?
      setState(() {
        appBarExpanded = true;
      }) :
      setState(() {
        appBarExpanded = false;
      }),
      );
  }
  
  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  // Gets the Events Done by the Brand
  Future<void> getBrandDetails() async {
    brand = await _brandDataService.getBrandDetails(widget.brandId);
  }

  Future<void> getCollections() async {

    if(_selectedIndex == 0)
      {
        events = await _brandDataService.getAllEventsFromBrandList(widget.brandId);
        setState(() {
          filteredEvents = events.where((element) => element.doneAt!.compareTo(Timestamp.fromDate(startDate)) > 0 && element.doneAt!.compareTo(Timestamp.fromDate(endDate)) < 0).toList();
          isLoading = false;
        });
      }

  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.darkGrey,
            expandedHeight: MediaQuery.of(context).size.height*0.2,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 4,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.darkGrey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.025),
                      child: Text(
                        AppLocalizations.of(context)!.stats,
                        style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white,),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.08,),
                  ],
                ),
              ),
              titlePadding: EdgeInsets.zero,
              //centerTitle: true,
            ),
            title: appBarExpanded ? Text(AppLocalizations.of(context)!.stats, style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: AppColors.white,),) : Container(),
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: MediaQuery.of(context).size.height*0.04,
                    ),
                    onPressed: () => mambaProScaffoldKey.currentState?.openDrawer()
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
                child: IconButton(
                  icon: Icon(
                    widget.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: widget.pinned ? AppColors.red :  AppColors.white.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width*0.06,
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    onTap: (index) {
                      _selectedIndex = index;
                      if(_selectedIndex == 0)
                      {
                        addStatsValue = 0.25;
                        tabs[0] = true;
                      }
                      else if(_selectedIndex == 1)
                      {
                        addStatsValue = 0.50;
                        tabs[1] = true;
                      }
                      else if(_selectedIndex == 2)
                      {
                        addStatsValue = 0.75;
                        tabs[3] = true;
                      }
                      else if(_selectedIndex == 3)
                      {
                        addStatsValue = 1;
                        tabs[4] = true;
                      }
                      setState(() {

                      });
                    },
                    tabs: [
                      selectedTab(AppLocalizations.of(context)!.events, 0, 0.20),
                      selectedTab(AppLocalizations.of(context)!.clients, 1, 0.20),
                      selectedTab(AppLocalizations.of(context)!.staff, 2, 0.15),
                      selectedTab('Facturación', 3, 0.25),

                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.0, horizontal:  MediaQuery.of(context).size.width*0.08,),
              child: Column(
                children: [
                  _selectedIndex == 0? eventsStatsPage() :
                  _selectedIndex == 1? clientsStatsPage() :
                  _selectedIndex == 2? staffStatsPage() :
                  _selectedIndex == 3? factStatsPage() : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: GestureDetector(
        onTap: _show, //TODO CALENDAR
        child: Container(
          height: MediaQuery.of(context).size.height*0.12,
          width: double.infinity,
         // color: Theme.of(context).backgroundColor,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            border: Border(
              top: BorderSide(width: 1, color: Theme.of(context).primaryColor),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: FractionalOffset.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.02, horizontal: MediaQuery.of(context).size.height*0.06),
                  child: Column(
                    children: [ Text(
                        formatter.format(startDate).toString(),
                        style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).primaryColor)
                    ),
                      Text(
                          ' a ',
                          style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).primaryColor)
                      ),
                      Text(
                        formatter.format(endDate).toString(),
                          style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).primaryColor)
                      ),
                  ],
                  ),
                ),
              ),
              new Spacer(),
          Container(
            height: MediaQuery.of(context).size.height*0.12,
            width: MediaQuery.of(context).size.width*0.27,
            color: Styles.mainColorTrans,
            child:  Icon(
                Icons.event,
                color: Styles.mainColor,
                size: MediaQuery.of(context).size.width*0.07,
              ),
        ),
            ],
          ),
        ),
      ) ,
    );
  }
  Widget selectedTab(String text, int index, double width)
  {
    return Tab(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
                text,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01,),
            _selectedIndex == index? Container(
              width: MediaQuery.of(context).size.width*width,
              height: 3,
              //Theme.of(context).scaffoldBackgroundColor,
              color: Theme.of(context).colorScheme.secondary,
            ) : Container(),
          ],
        ),
      ),
    );
  }

  Widget statsTitle(String text)
  {
    return Padding(
        padding:
        EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
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
                        ?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),

                ],
              ),
            ),
          ],
        ));
  }
  Widget eventsStatsPage()
  {
    if(isLoading)
      {
        return  Padding(
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.25),
          child:  LoadingView(),
        );
      }
    return Column(
      children: [
        statsTitle('Entrenos realizados'),
        Padding(
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
          child: SessionsMade(events: filteredEvents),
        ),
        Divider(color: Theme.of(context).backgroundColor, thickness: 2),
        statsTitle('Demanda de días'),
        Divider(color: Theme.of(context).backgroundColor, thickness: 2),
        statsTitle('Hora más demandada'),
        Divider(color: Theme.of(context).backgroundColor, thickness: 2),
        statsTitle('Franja más demandada'),
        Divider(color: Theme.of(context).backgroundColor, thickness: 2),
        statsTitle('Historico de franjas'),
      ],
    );
  }
  Widget clientsStatsPage()
  {
    return Column(
      children: [
        statsTitle('Numero clientes'),
        Divider(color: Theme.of(context).backgroundColor, thickness: 2),
      ],
    );
  }
  Widget staffStatsPage()
  {
    return Column(
      children: [
        statsTitle('Entrenadores'),
        Divider(color: Theme.of(context).backgroundColor, thickness: 2),
      ],
    );
  }
  Widget factStatsPage()
  {
    return Column(
      children: [
        statsTitle('Facturación total'),
        Divider(color: Theme.of(context).backgroundColor, thickness: 2),
      ],
    );
  }

  void _show() async {
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
        return FractionallySizedBox(
          heightFactor: 0.95,
          child: SelectCalendarDate(
            brandId: currentBrand.id!,
          ),
        );
      },
    );
    /*
    await showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) => CalendarPopupView(
        barrierDismissible: true,
        minimumDate: DateTime.now(),
        initialEndDate: endDate,
        initialStartDate: startDate,
        onApplyClick: (DateTime startData, DateTime endData) {
             setState(() {
            startDate = startData;
            endDate = endData;
            filteredEvents = events.where((element) => element.doneAt!.compareTo(Timestamp.fromDate(startDate)) > 0 && element.doneAt!.compareTo(Timestamp.fromDate(endDate)) < 0).toList();

             });
        },
      ),
    );
     */
  }
}


