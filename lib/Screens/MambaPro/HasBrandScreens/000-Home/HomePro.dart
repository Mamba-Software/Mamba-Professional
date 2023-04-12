import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/000-Home/HomeWidgets/BrandBonoRequestsWidget.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/000-Home/HomeWidgets/BrandCalendarMonthWidget.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/000-Home/HomeWidgets/BrandRequestsWidget.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/000-Home/HomeWidgets/BrandSessionStatsWidget.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/000-Home/HomeWidgets/CountDownSubscription.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/000-Home/HomeWidgets/EndDateSubscription.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/000-Home/HomeWidgets/PlanEventWidget.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/000-Home/HomeWidgets/UserTodayWidget.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/MembershipRequestsPro.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/ShareBrandLink.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/BonosRequests.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../Globals/Providers/ThemeProvider.dart';
import 'HomeWidgets/BrandBestBonoWidget.dart';

// Step 1: Define a Callback.
typedef DateCallBack = void Function(int pageIndex, [DateTime? dateTime, CalendarView? calendarView]);

class HomePro extends StatefulWidget {
  String brandId;
  int numClients;
  int numTrainers;
  final DateCallBack navigateToPage;

  HomePro({Key? key, required this.brandId, required this.numTrainers, required this.numClients, required this.navigateToPage}) : super(key: key);

  @override
  _HomePro createState() => _HomePro();
}

class _HomePro extends State<HomePro> {

  // Brand Data Service
  final _brandDataService = BrandDataService();
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.18 - kToolbarHeight);
  }
  // Brand Image
  String imageUrl = currentBrand.logoUrl!;

  @override
  initState() {
    setBrandActive();
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
    getBrandImage();
  }

  Future<void> getBrandImage() async {
    var temp = await _brandDataService.getRandomBrandPhoto(currentBrand.id!);
    setState(() {
      imageUrl = temp;
    });
  }

  // Build Places Left Event
  SystemUiOverlayStyle returnSystemBarColor() {
    if (Platform.isAndroid) {
      return SystemUiOverlayStyle.light;
    } else {
      bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
      if (isDark) {
        return SystemUiOverlayStyle.light;
      } else {
        return !appBarExpanded ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
      }
    }
  }

  // Navigate to Bonos Request Screen
  void navigateToBonosRequestScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => BonosRequests(
            brandId: widget.brandId,
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height*0.18,
            elevation: 2,
            systemOverlayStyle: returnSystemBarColor(),
            floating: true,
            pinned: true,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  RectangularImage(
                    height: MediaQuery.of(context).size.height*0.3,
                    width: MediaQuery.of(context).size.width,
                    image: imageUrl,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width*0.07,
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width*0.9,
                      minWidth: MediaQuery.of(context).size.width*0.9,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15.0),
                        topLeft: Radius.circular(15.0),
                      ),// BorderRadius

                    ),// BoxDecoration
                    child: Container(
                      margin: const EdgeInsetsDirectional.only(start: 1, end: 1, top: 1),
                      height: MediaQuery.of(context).size.width*0.05,
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width*0.9,
                        minWidth: MediaQuery.of(context).size.width*0.9,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15.0),
                          topLeft: Radius.circular(15.0),
                        ),// BorderRadius
                      ),
                    ),                    // Container
                  ),
                ],
              ),
              titlePadding: EdgeInsets.zero,
            ),
            title: appBarExpanded ? Text(currentBrand.name!, style: Theme.of(context).appBarTheme.titleTextStyle) : Container(),
            leadingWidth: MediaQuery.of(context).size.width*0.18,
            leading: Padding(
              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06),
              child: Container(
                height: MediaQuery.of(context).size.width*0.06,
                width: MediaQuery.of(context).size.width*0.12,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Theme.of(context).primaryColor,
                    size: MediaQuery.of(context).size.height*0.035
                  ),
                  onPressed: () => mambaProScaffoldKey.currentState?.openDrawer(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.06),
                child: Container(
                  height: MediaQuery.of(context).size.width*0.06,
                  width: MediaQuery.of(context).size.width*0.12,
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.qr_code,
                      color: Theme.of(context).primaryColor,
                      size: MediaQuery.of(context).size.height*0.035,
                    ),
                    onPressed: () {
                      mixpanel!.track('brand_homepage_share_link');
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
                            heightFactor: 0.75,
                            child: ShareBrandLink(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.0, horizontal:  MediaQuery.of(context).size.width*0.05,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserTodayWidget(
                    onClicked: (boolean) {
                        if(brandIsActive) {
                          mixpanel!.track('brand_homepage_user_this_week');
                          widget.navigateToPage(10, DateTime.now(), CalendarView.week);
                        }
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  currentUser.brandRole < 2 ? EndDateSubscription() : Container(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  currentUser.brandRole < 3 ? BrandRequestsWidget(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.9,
                    brandId: currentBrand.id!,
                    onClicked: (bool? value) {
                          if(brandIsActive) {
                            mixpanel!.track('brand_homepage_membership_requests');
                            navigateToRequestsScreen();
                          }
                    },
                  ) : Container(),
                  currentUser.brandRole < 3 ? BrandBonoRequestsWidget(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.9,
                    brandId: currentBrand.id!,
                    onClicked: (bool? value) {
                        if(brandIsActive) {
                          mixpanel!.track('brand_homepage_bono_confirmation_requests');
                          navigateToBonosRequestScreen();
                        }
                    }, //
                  ) : Container(),
                  Column(
                    children: [
                      currentUser.brandRole < 3 ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PlanEventWidget(
                                height: MediaQuery.of(context).size.height * 0.07,
                                width: MediaQuery.of(context).size.width * 0.43,
                                isPrivate: false,
                                onClicked: (bool? value) {
                                  if(brandIsActive) {
                                    mixpanel!.track(
                                        'brand_homepage_plan_event', properties: {'isPrivate': false});
                                    widget.navigateToPage(10, null, CalendarView.month);
                                  }
                                },
                              ),
                              PlanEventWidget(
                                height: MediaQuery.of(context).size.height * 0.07,
                                width: MediaQuery.of(context).size.width * 0.43,
                                isPrivate: true,
                                onClicked: (bool? value) {
                                  if(brandIsActive) {
                                    mixpanel!.track(
                                        'brand_homepage_plan_event', properties: {'isPrivate': true});
                                    widget.navigateToPage(10, null, CalendarView.month);
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                        ],
                      ) : Container(),
                      BrandCalendarMonthWidget(
                        brandId: currentBrand.id!,
                        height: MediaQuery.of(context).size.height * 0.41,
                        width: MediaQuery.of(context).size.width * 0.9,
                        navigateToPage: (int page, DateTime? dateTime, CalendarView? calendarView) {
                          widget.navigateToPage(10, dateTime, calendarView);
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ],
                  ),
                  BrandSessionStatsWidget(
                    brandId: currentBrand.id!,
                    navigateToPage: (int page) {
                      widget.navigateToPage(9);
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  BrandBestBonoWidget(
                    brandId: currentBrand.id!,
                    navigateToPage: (int page) {
                      widget.navigateToPage(5);
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> navigateToRequestsScreen() async {
    mixpanel!.track('brand_membership_requests_view');
    await Navigator.push(
        context,
        CupertinoPageRoute<bool?>(
          builder: (context) => MembershipRequestsPro(
            brandId: widget.brandId,
          ),
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}