// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Events/EventListTile.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/home/cubit/home_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mamba/commons/extensions/context.dart';

class BrandEventHistoryPage extends StatefulWidget {
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;
  BrandEventHistoryPage(
      {super.key,
      required this.brandId,
      required this.pinned,
      required this.pinnedChanged});

  @override
  _BrandEventHistoryPageState createState() => _BrandEventHistoryPageState();
}

class _BrandEventHistoryPageState extends State<BrandEventHistoryPage> {
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients &&
        _scrollController!.offset >
            (MediaQuery.of(context).size.height * 0.15 - kToolbarHeight);
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
      ..addListener(
        () => _isAppBarExpanded
            ? setState(() {
                appBarExpanded = true;
              })
            : setState(() {
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
    safeAreaHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print(
        "Device H and W: ${MediaQuery.of(context).size.height} ${MediaQuery.of(context).size.width}");
    print("SafeArea H and W: $safeAreaHeight $safeAreaWidth");
  }

  // Gets the Events Done by the Brand
  Future<void> getBrandDetails() async {
    brand = await _brandDataService.getBrandDetails(widget.brandId);
  }

  // Gets the Events Done by the Brand
  Future<void> getBrandFirstEvents() async {
    listEvents = await _eventDataService.getBrandFirstCompletedEventsLimit(
        widget.brandId, 10);
  }

  // Gets the Events Done by the Brand
  Future<void> getBrandMoreEvents(String lastEventId) async {
    var temp = listEvents;
    var moreEvents = await _eventDataService.getBrandMoreCompletedEventsLimit(
        widget.brandId, lastEventId, 10);
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
            surfaceTintColor: AppColors.darkGrey,
            backgroundColor: AppColors.darkGrey,
            expandedHeight: MediaQuery.of(context).size.height * 0.15,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 4,
            floating: false,
            pinned: true,
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.eventHistory,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  color: AppColors.white,
                                ),
                          ),
                          FittedBox(
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.08,
                              width: MediaQuery.of(context).size.width * 0.11,
                              child: TextButton(
                                onPressed: null,
                                child: Icon(
                                  Icons.filter_list,
                                  color: AppColors.darkGrey,
                                  size:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                              ),
                            ),
                          )
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
              titlePadding: EdgeInsets.zero,
              //centerTitle: true,
            ),
            title: appBarExpanded
                ? Text(
                    context.l10n.eventHistory,
                    style:
                        Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
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
                        navigationDrawerKey.currentState?.openDrawer()),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.01),
                child: IconButton(
                  icon: Icon(
                    widget.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: widget.pinned
                        ? AppColors.red
                        : AppColors.white.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  onPressed: () {
                    if (widget.pinned == true) {
                      mixpanel!.track('brand_event_history_pinned_off');
                    } else {
                      mixpanel!.track('brand_event_history_pinned_on');
                    }
                    setState(() {
                      widget.pinned = !widget.pinned;
                    });
                    widget.pinnedChanged(widget.pinned);
                  },
                ),
              ),
            ],
          ),
          isLoading
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Column(
                        children: [
                          index == 0
                              ? SizedBox(height: safeAreaWidth * 0.08)
                              : Container(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: safeAreaWidth * 0.08),
                            child: Shimmer.fromColors(
                              baseColor: AppColors.grey,
                              highlightColor: AppColors.grey.withOpacity(0.5),
                              child: SizedBox(
                                height: safeAreaHeight * 0.18,
                                width: safeAreaWidth * 0.9,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: (safeAreaWidth * 0.9) * 0.20,
                                      width: (safeAreaWidth * 0.9) * 0.20,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height:
                                                (safeAreaWidth * 0.9) * 0.20,
                                            width: (safeAreaWidth * 0.9) * 0.20,
                                            decoration: BoxDecoration(
                                              color: AppColors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: safeAreaHeight * 18,
                                          width: safeAreaWidth * 0.9 * 0.56,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: safeAreaHeight * 0.03,
                                                width: (safeAreaWidth * 0.9) *
                                                    0.20,
                                                decoration: BoxDecoration(
                                                  color: AppColors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                              SizedBox(
                                                height: safeAreaHeight * 0.02,
                                              ),
                                              Container(
                                                height: safeAreaHeight * 0.02,
                                                width: (safeAreaWidth * 0.9) *
                                                    0.35,
                                                decoration: BoxDecoration(
                                                  color: AppColors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                              SizedBox(
                                                height: safeAreaHeight * 0.015,
                                              ),
                                              Container(
                                                height: safeAreaHeight * 0.02,
                                                width:
                                                    (safeAreaWidth * 0.9) * 0.5,
                                                decoration: BoxDecoration(
                                                  color: AppColors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                              SizedBox(
                                                height: safeAreaHeight * 0.015,
                                              ),
                                              Container(
                                                height: safeAreaHeight * 0.02,
                                                width:
                                                    (safeAreaWidth * 0.9) * 0.5,
                                                decoration: BoxDecoration(
                                                  color: AppColors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                              SizedBox(
                                                height: safeAreaHeight * 0.015,
                                              ),
                                              Container(
                                                height: safeAreaHeight * 0.02,
                                                width:
                                                    (safeAreaWidth * 0.9) * 0.5,
                                                decoration: BoxDecoration(
                                                  color: AppColors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: safeAreaHeight * 15,
                                          width: (safeAreaWidth * 0.84) * 0.12,
                                          child: Center(
                                            child: Container(
                                              height: safeAreaHeight * 0.05,
                                              width: safeAreaHeight * 0.05,
                                              decoration: BoxDecoration(
                                                color: AppColors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: safeAreaHeight * 0.04,
                                horizontal: safeAreaWidth * 0.08),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 1,
                                  width: safeAreaWidth * 0.61,
                                  color: AppColors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    childCount: 6,
                  ),
                )
              : listEvents.isNotEmpty
                  ? LazyLoadScrollView(
                      onEndOfPage: () {
                        mixpanel!.track('brand_event_history_more_events');
                        getBrandMoreEvents(listEvents[lastIndex].id!);
                      },
                      scrollOffset: safeAreaHeight.toInt(),
                      child: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            Event event = listEvents[index];
                            return Column(
                              children: [
                                index == 0
                                    ? SizedBox(height: safeAreaWidth * 0.08)
                                    : Container(),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: safeAreaWidth * 0.08),
                                  child: EventListTile(
                                    userId: currentUser.id!,
                                    eventId: event.id!,
                                    showFeedback: false,
                                    showAverage: true,
                                    height: safeAreaHeight,
                                    width: safeAreaWidth * 0.9,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: safeAreaHeight * 0.04,
                                      horizontal: safeAreaWidth * 0.08),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: 1,
                                        width: safeAreaWidth * 0.61,
                                        color: AppColors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          childCount: listEvents.length,
                        ),
                      ),
                    )
                  : SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Image.asset(Assets.emptyCalendar)),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005),
                          Text(
                            context.l10n.noEvents,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.12),
                        ],
                      ))
        ],
      ),
    );
  }
}
