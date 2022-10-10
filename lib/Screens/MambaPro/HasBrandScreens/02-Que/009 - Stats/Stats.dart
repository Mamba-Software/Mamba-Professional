// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import '../../../../../../../Data/Models/Event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Stats extends StatefulWidget {
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;
  Stats({Key? key, required this.brandId, required this.pinned, required this.pinnedChanged}) : super(key: key);

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {

  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.15 - kToolbarHeight);
  }
  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();
  // Brand
  Brand brand = Brand();
  // AlL Events From Brand
  List<Event> listEvents = [];
  // Index for Lazy Scroll
  int lastIndex = 9;

  @override
  void initState() {
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
    initEventHistory();
  }

  Future<void> initEventHistory() async {
    await getBrandDetails();
    await getBrandFirstEvents();
    //await Future.delayed(const Duration(milliseconds: 2000));
    setState(() {
      isLoading = false;
    });
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

  // Gets the Events Done by the Brand
  Future<void> getBrandFirstEvents() async {
    listEvents = await _eventDataService.getBrandFirstCompletedEventsLimit(widget.brandId, 10);
  }

  // Gets the Events Done by the Brand
  Future<void> getBrandMoreEvents(String lastEventId) async {
    var temp = listEvents;
    var moreEvents = await _eventDataService.getBrandMoreCompletedEventsLimit(widget.brandId, lastEventId, 10);
    temp.addAll(moreEvents);
    if (mounted) {
      setState(() {
        listEvents = temp;
        lastIndex += 10;
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
            expandedHeight: MediaQuery.of(context).size.height*0.15,
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.stats,
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white,),
                          ),
                          FittedBox(
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height*0.08,
                              width: MediaQuery.of(context).size.width*0.11,
                              child: TextButton(
                                onPressed: null,
                                child: Icon(
                                  Icons.filter_list,
                                  color: AppColors.darkGrey,
                                  size: MediaQuery.of(context).size.width*0.07,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                    Container(
                      color: AppColors.grey,
                      height: 1.0,
                    ),
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
          ),
        ],
      ),
      bottomSheet: GestureDetector(
        onTap: () {
          //TODO CALENDAR
        },
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
            children: [
              Align(
                alignment: FractionalOffset.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.04, horizontal: MediaQuery.of(context).size.height*0.06),
                  child: Text(
                      '01-07 Agosto 2022',
                      style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).primaryColor)
                  ),
                ),
              ),
              Align(
                alignment: FractionalOffset.centerRight,
                child: Padding(
                  padding:  EdgeInsets.only( left: MediaQuery.of(context).size.height*0.06),
                  child: Container(
                    height: MediaQuery.of(context).size.height*0.12,
                    width: MediaQuery.of(context).size.width*0.265,
                    color: Styles.mainColorTrans,
                    child:  Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.event,
                        color: Styles.mainColor,
                        size: MediaQuery.of(context).size.width*0.07,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ) ,
    );
  }
}
