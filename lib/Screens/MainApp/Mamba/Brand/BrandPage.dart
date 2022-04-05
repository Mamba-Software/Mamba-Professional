import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/FullScreenImageCarousel.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/LongTextContainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TitleHeadline1.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/ImageFullScreen.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Calendars/BrandEventsToday.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Calendars/CalendarWidgetTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/BrandCalendarWidget.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Location/LocationImageTile.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Users/UsersHorizontalScroll.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandScreens/BrandCalendarWeekWidget.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandScreens/BrandMembers/BrandMembersPage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandScreens/BrandSettings/MembershipRequests.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandScreens/BrandSettings/SettingsBrand.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class BrandPage extends StatefulWidget {
  const BrandPage({Key? key}) : super(key: key);

  @override
  _BrandPageState createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  bool isDark = false;
  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  var _locationDataService = new LocationDataService();
  // Images uploaded
  List<ImageObject> _imagesUploaded = [];
  List<Widget> imageSliders = [];
  // Brand Events Today
  List<Event> todayEvents = [];
  int numberEventsFinished = 0;
  int numberEventsToDo = 0;
  String startWorkShift = "";
  String endWorkShift = "";
  // List Trainers
  List<Usuario> brandTrainers = [];
  // List Locations
  List<Location> brandLocations = [];

  @override
  void initState() {
    isLoading = true;
    initBrandHome();
    super.initState();
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  // Init for Brand Home
  initBrandHome() async {
    await getBrand();
    await getNumberFinishedEvents();
    await getAllEventsTodayBrand();
    await getBrandContentImages();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Gets the user info from firebase.
  Future<void> getBrand() async {
    currentBrand.setBasicData = await _brandDataService.getBrandDetails(currentBrand.id!);
    currentBrand.setUserList = await _brandDataService.getBrandUsers(currentBrand.id!);
    // Images Uploaded
    _imagesUploaded = await _brandDataService.getBrandContentPictures(currentBrand.id!);
    // Brand Trainers
    brandTrainers = await _brandDataService.getBrandTrainers(currentBrand.id!);
    // Work Shift
    var startHourWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
    var startMinWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
    startWorkShift = DateFormat('HH:mm', Localizations.localeOf(context).languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startHourWS, startMinWS,));
    var endHourWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
    var endMinWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
    endWorkShift = DateFormat('HH:mm', Localizations.localeOf(context).languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endHourWS, endMinWS,));
    // Brand Locations
    brandLocations = await _locationDataService.getAllBrandLocations(currentBrand.id!);
    brandLocations.removeWhere((element) => element.isBaseLocation == true);
  }

  // Gets the user info from firebase.
  Future<void> getBrandContentImages() async {
    _imagesUploaded = await _brandDataService.getBrandContentPictures(currentBrand.id!);
    imageSliders = _imagesUploaded
        .map((item) => Container(
          child: Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute<Null>(
                                builder: (context) => FullscreenSliderDemo(
                                  initialImage: _imagesUploaded.indexOf(item),
                                  images: _imagesUploaded,
                                ),
                              )
                          );
                        },
                        child: Image.network(item.url!, fit: BoxFit.cover, width: MediaQuery.of(context).size.width,)
                    ),
                    Positioned(
                      bottom: -15,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(200, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('No. ${_imagesUploaded.indexOf(item) + 1} de ${_imagesUploaded.length.toString()}',
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ))
        .toList();
    setState(() {
      isLoading = false;
    });
  }

  // Gets number of finished events
  Future<void> getNumberFinishedEvents() async {
    numberEventsFinished = await _eventDataService.getBrandsEventsFinished(currentBrand.id!);
    numberEventsToDo = await _eventDataService.getBrandsEventsUpcoming(currentBrand.id!);
  }

  // Gets all events of today.
  Future<void> getAllEventsTodayBrand() async {
    todayEvents = await _eventDataService.getAllEventsTodayBrand(currentBrand.id!);
  }

  // Navigate to Membership Requests Screen
  void navigateToMembershipRequestsScreen() {
    Navigator.push(
      context,
      CupertinoPageRoute<Null>(
        builder: (context) => MembershipRequests(
          brandId: currentBrand.id!,
        ),
      )
    ).whenComplete(() {
      setState(() {
        isLoading = true;
        initBrandHome();
      });
    });
  }

  // Navigate to Settings Brand Screen
  void navigateToSettingsBrandScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => SettingsBrand(),
        )
    ).whenComplete(() {
      setState(() {
        isLoading = true;
        initBrandHome();
      });
    });

  }

  // Navigate to Brand Calendar Screen
  void navigateToBrandCalendarScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => BrandCalendarWidget(
            brandId: currentBrand.id!,
          )
        )
    ).whenComplete(() {
      setState(() {
        isLoading = true;
        initBrandHome();
      });
    });
  }

  // Navigate to Brand Calendar Screen
  void navigateToBrandMembersScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => BrandMembersPage(
              brandId: currentBrand.id!,
              brandAdmin: currentBrand.adminID!,
          ),
        )
    ).whenComplete(() {
      setState(() {
        isLoading = true;
        initBrandHome();
      });
    });
  }

  // Navigate to FullScreenImage Screen
  void navigateToFullScreenImage() {
    Navigator.push(
      context,
      CupertinoPageRoute<Null>(
        builder: (context) => FullScreenPage(
          child:  Image.network(
            currentBrand.logoUrl!,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).accentColor,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
          dark: false,
        )
      )
    );
  }

  void _onLaunchCoordinates(Location location) {
    MapsLauncher.launchCoordinates(location.latitude!, location.longitude!, location.description!);
  }

  // Build Share App Container.
  Widget buildBrandAppBarContainer() {
    return Center(
      child: Container(
        height: safeAreaHeight * 0.37,
        width: safeAreaWidth * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildBrandOptions(),
              buildBrandTitle(),
              SizedBox(height: safeAreaHeight*0.02,),
              buildBrandPicture(),
              SizedBox(height: safeAreaHeight*0.02,),
              buildBrandEventCount(),
            ],
          ),
        ),
      ),
    );
  }

  // Build the Widget of the Brand Name
  Widget buildBrandOptions() {
    return !isLoading ? Container(
      height: safeAreaHeight*0.06,
      width: safeAreaWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.group_add, color: Theme.of(context).primaryColor, size: safeAreaWidth*0.06),
            alignment: Alignment.center,
            onPressed: navigateToMembershipRequestsScreen,
          ),
          SizedBox(width: safeAreaWidth*0.5,),
          IconButton(
            icon: Icon(Icons.settings, color: Theme.of(context).primaryColor, size: safeAreaWidth*0.06,),
            onPressed: navigateToSettingsBrandScreen,
          ),
        ],
      ),
    ) : Container(
      height: safeAreaHeight*0.06,
      width: safeAreaWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.grey,
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Container(
              height: safeAreaHeight*0.04,
              width: safeAreaWidth*0.08,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(width: safeAreaWidth*0.5,),
          Shimmer.fromColors(
            baseColor: AppColors.grey,
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Container(
              height: safeAreaHeight*0.04,
              width: safeAreaWidth*0.08,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the Widget of the Brand Name
  Widget buildBrandTitle() {
    return !isLoading ? Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: TitleHeadline1(text: currentBrand.name!,)),
      ],
    ) : Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: safeAreaHeight*0.04,
              width: safeAreaWidth*0.5,
              decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10)
              ),
            ),
          ],
        )
    );
  }

  // Build the Widget of the Image
  Widget buildBrandPicture() {
    return !isLoading ? Container(
      height: safeAreaHeight*0.15,
      child: GestureDetector(
        onTap: navigateToFullScreenImage,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularImage(
              size: safeAreaHeight*0.15,
              image: currentBrand.logoUrl,
              color: Theme.of(context).backgroundColor,
              borderWidth: 2,
            ),
          ],
        ),
      ),
    )  : Center(
      child: Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Container(
          height: safeAreaHeight*0.15,
          decoration: BoxDecoration(
            color: AppColors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // Build the Widget of the Image
  Widget buildBrandEventCount() {
    return !isLoading ? Material(
      child: Container(
        width: safeAreaWidth * 0.86,
        height: safeAreaHeight * 0.07,
        decoration: new BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: navigateToBrandCalendarScreen,
              child: Row(
                children: [
                  Container(
                    height: safeAreaHeight * 0.09,
                    width: safeAreaWidth * 0.23,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          numberEventsFinished.toString(),
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                        ),
                        SizedBox(height: safeAreaHeight*0.01),
                        Container(
                          width: safeAreaWidth * 0.23,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              AppLocalizations.of(context)!.sessionsDone,
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: safeAreaWidth * 0.05,
                    height: safeAreaHeight * 0.03,
                    child: VerticalDivider(color: Theme.of(context).primaryColor,),
                  ),
                  Container(
                    height: safeAreaHeight * 0.09,
                    width: safeAreaWidth * 0.23,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          numberEventsToDo.toString(),
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                        ),
                        SizedBox(height: safeAreaHeight*0.01),
                        Container(
                          width: safeAreaWidth * 0.23,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              AppLocalizations.of(context)!.sessionsToDo,
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: safeAreaWidth * 0.05,
                    height: safeAreaHeight * 0.03,
                    child: VerticalDivider(color: Theme.of(context).primaryColor,),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: navigateToBrandMembersScreen,
              child: Row(
                children: [
                  Container(
                    height: safeAreaHeight * 0.09,
                    width: safeAreaWidth * 0.23,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          (currentBrand.numClients! + currentBrand.numTrainers! ).toString(),
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                        ),
                        SizedBox(height: safeAreaHeight*0.01),
                        Container(
                          width: safeAreaWidth * 0.23,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              AppLocalizations.of(context)!.membersTotal,
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ) : Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Container(
          width: safeAreaWidth * 0.70,
          height: safeAreaHeight * 0.06,
          decoration: new BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(10)
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }

    return DefaultTabController(
      length: 4,
      initialIndex: 1,
      child: Scaffold(
        appBar: null,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverSafeArea(
              top: false,
              sliver: SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  pinned: true,
                  floating: true,
                  title: buildBrandAppBarContainer(),
                  titleSpacing: 0,
                  toolbarHeight: safeAreaHeight*0.4,
                  centerTitle: true,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarBrightness: Brightness.light,
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                  ),
                  bottom: TabBar(
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorWeight: 5,
                    isScrollable: true,
                    tabs: [
                      Container(
                        width: safeAreaWidth*0.3,
                        child: Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.brandDetailsTab.toUpperCase(),
                                    style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).primaryColor),
                                    textAlign: TextAlign.center
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: safeAreaWidth*0.3,
                        child: Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.calendar.toUpperCase(),
                                  style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).primaryColor),
                                  textAlign: TextAlign.center
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: safeAreaWidth*0.3,
                        child: Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.locations.toUpperCase(),
                                    style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).primaryColor),
                                    textAlign: TextAlign.center
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: safeAreaWidth*0.3,
                        child: Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.photos.toUpperCase(),
                                    style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).primaryColor),
                                    textAlign: TextAlign.center
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    onTap: (index) {

                    },
                  ),
                ),
              ),
            )
          ],
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              buildDetailsTabPage(),
              buildCalendarTabPage(),
              buildLocationsTabPage(),
              buildPhotosTabPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailsTabPage() => SafeArea(
    top: false,
    bottom: false,
    child: Builder(
      builder: (context) => CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverToBoxAdapter(
              child: buildDescriptionContainer()
          ),
          SliverToBoxAdapter(
              child: buildBrandTrainersContainer()
          ),
          SliverToBoxAdapter(
              child: buildBrandClientsContainer()
          ),
        ],
      ),
    ),
  );

  Widget buildCalendarTabPage() => SafeArea(
    top: false,
    bottom: false,
    child: Builder(
      builder: (context) => CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: safeAreaHeight * 0.04,
                  ),
                  isLoading ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: safeAreaHeight*0.06,
                            width: safeAreaWidth*0.5,
                            decoration: BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) : Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton.extended(
                          heroTag: "87",
                          onPressed: navigateToBrandCalendarScreen,
                          backgroundColor: Theme.of(context).accentColor,
                          icon: Icon(
                            Icons.calendar_month,
                            color: AppColors.white,
                            size: safeAreaWidth*0.05,
                          ),
                          label: Text(
                              AppLocalizations.of(context)!.planSessions,
                              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white)
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: safeAreaHeight * 0.04,
                  ),
                ],
              )
          ),
          SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoading ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                    child: Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Container(
                        height: safeAreaHeight*0.04,
                        width: safeAreaWidth*0.25,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ) :
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                    child: Text(
                      AppLocalizations.of(context)!.calendarWeekBrandText(currentBrand.name!),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(
                    height: safeAreaHeight * 0.01,
                  ),
                  isLoading ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08, vertical: safeAreaWidth*0.04 ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: safeAreaHeight*0.30,
                            width: safeAreaWidth*0.7,
                            decoration: BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) :
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BrandCalendarWeekWidget(
                          brandId: currentBrand.id!,
                          height: safeAreaHeight*0.68,
                          width: safeAreaWidth*0.88,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    ),
  );

  Widget buildLocationsTabPage() => SafeArea(
    top: false,
    bottom: false,
    child: Builder(
      builder: (context) => CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: safeAreaHeight * 0.04,
                  ),
                  isLoading ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                    child: Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Container(
                        height: safeAreaHeight*0.04,
                        width: safeAreaWidth*0.25,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ) : Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                    child: Text(
                      AppLocalizations.of(context)!.baseLocation,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: safeAreaHeight * 0.04,
                  ),
                  isLoading ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                    child: Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Container(
                        height: safeAreaHeight*0.2,
                        width: safeAreaWidth*0.84,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ) : Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                    child: LocationImageTile(
                        locationId: currentBrand.baseLocation!,
                        height: safeAreaHeight*0.2,
                        width: safeAreaWidth*0.84
                    ),
                  ),
                  SizedBox(
                    height: safeAreaHeight * 0.06,
                  ),
                  isLoading ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                    child: Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Container(
                        height: safeAreaHeight*0.04,
                        width: safeAreaWidth*0.5,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ) : Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                    child: Text(
                      AppLocalizations.of(context)!.locationsBrandText,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: safeAreaHeight * 0.02,
                  ),
                ],
              )
          ),
          SliverPadding(
            padding: EdgeInsets.all(12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final childCount = brandLocations.length;
                final hasSeparator = index != childCount - 1;
                final double bottom = hasSeparator ? safeAreaHeight*0.02 : 0;
                final location = brandLocations[index];
                final child = isLoading ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: AppColors.grey,
                        highlightColor: AppColors.grey.withOpacity(0.5),
                        child: Container(
                          height: safeAreaHeight*0.05,
                          width: safeAreaWidth*0.10,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: safeAreaWidth * 0.04,
                      ),
                      Shimmer.fromColors(
                        baseColor: AppColors.grey,
                        highlightColor: AppColors.grey.withOpacity(0.5),
                        child: Container(
                          height: safeAreaHeight*0.05,
                          width: safeAreaWidth*0.68,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ) : ListTile(
                  leading: Icon(Icons.location_on_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.06,),
                  title: Text(
                    location.description!,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  onTap: () => _onLaunchCoordinates(location),
                );
                return Container(
                  margin: EdgeInsets.only(bottom: bottom),
                  child: child,
                );
              },
              childCount: brandLocations.length
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget buildPhotosTabPage() => SafeArea(
    top: false,
    bottom: false,
    child: Builder(
      builder: (context) => CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: safeAreaHeight * 0.06,
                  ),
                  buildBrandImagesContainer(),
                  SizedBox(
                    height: safeAreaHeight * 0.04,
                  ),
                ],
              )
          ),
        ],
      ),
    ),
  );

  Widget buildDescriptionContainer() {
    return isLoading ? Padding(
      padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: safeAreaHeight * 0.05,
          ),
          Shimmer.fromColors(
            baseColor: AppColors.grey,
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Container(
              height: safeAreaHeight*0.08,
              width: safeAreaWidth*0.84,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(
            height: safeAreaHeight * 0.02,
          ),
          Shimmer.fromColors(
            baseColor: AppColors.grey,
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Container(
              height: safeAreaHeight*0.04,
              width: safeAreaWidth*0.3,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(
            height: safeAreaHeight * 0.02,
          ),
          Shimmer.fromColors(
            baseColor: AppColors.grey,
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Container(
              height: safeAreaHeight*0.04,
              width: safeAreaWidth*0.25,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(
            height: safeAreaHeight * 0.03,
          ),
        ],
      ),
    ) : Padding(
      padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: safeAreaHeight * 0.05,
          ),
          LongTextContainer(
            text: currentBrand.description!,
          ),
          /*
          Text(
            AppLocalizations.of(context)!.workingHours,
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: safeAreaHeight * 0.02,
          ),
          Text(
            startWorkShift + " - " + endWorkShift,
            style: Theme.of(context).textTheme.caption,
          ),
           */
          SizedBox(
            height: safeAreaHeight * 0.00,
          ),
        ],
      ),
    );
  }

  Widget buildBrandTodayContainer() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.bottomToTop,
                child: BrandEventsToday(
                    brandId: currentBrand.id!
                )
            )
        ).whenComplete(() {
          setState(() {
            isLoading = true;
            initBrandHome();
          });
        });
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: safeAreaWidth * 0.86,
                height: safeAreaHeight * 0.08,
                decoration: new BoxDecoration(
                  color: Theme.of(context).accentColor.withOpacity(0.4),
                  borderRadius: new BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
                child: Material(
                  elevation: 4,
                  color: Theme.of(context).accentColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          child: Icon(Icons.calendar_today_outlined, color: AppColors.white, size: MediaQuery.of(context).size.height * 0.03,)
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.69,
                        child: Center(child: Text(AppLocalizations.of(context)!.today(StringUtils().toCapitalized(DateFormat('EEEE d/M/yy', Localizations.localeOf(context).languageCode).format(DateTime.now()))), style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.white,fontWeight: FontWeight.w400)),),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: safeAreaHeight * 0.05,
          ),
        ],
      ),
    );
  }

  Widget buildBrandTrainersContainer() {
    return isLoading ? Padding(
      padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: safeAreaHeight * 0.02,
          ),
          Shimmer.fromColors(
            baseColor: AppColors.grey,
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Container(
              height: safeAreaHeight*0.04,
              width: safeAreaWidth*0.3,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(
            height: safeAreaHeight * 0.02,
          ),
          Shimmer.fromColors(
            baseColor: AppColors.grey,
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Container(
              height: safeAreaHeight*0.15,
              width: safeAreaWidth*0.84,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    ) : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: safeAreaHeight * 0.02,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
          child: Text(
            AppLocalizations.of(context)!.trainers,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(
          height: safeAreaHeight * 0.02,
        ),
        UsersHorizontalScroll(
          usuarios: brandTrainers,
          height: safeAreaHeight * 0.15,
          width: safeAreaWidth,
        ),

      ],
    );
  }

  Widget buildBrandClientsContainer() {
    return isLoading ? Padding(
      padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: safeAreaHeight * 0.05,
          ),
          Shimmer.fromColors(
            baseColor: AppColors.grey,
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Container(
              height: safeAreaHeight*0.04,
              width: safeAreaWidth*0.3,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(
            height: safeAreaHeight * 0.05,
          ),
          Shimmer.fromColors(
            baseColor: AppColors.grey,
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Container(
              height: safeAreaHeight*0.04,
              width: safeAreaWidth*0.3,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    ) :  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: safeAreaHeight * 0.05,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
          child: Text(
            AppLocalizations.of(context)!.numberClients+" "+currentBrand.numClients.toString(),
            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).accentColor),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(
          height: safeAreaHeight * 0.05,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
          child: Text(
            AppLocalizations.of(context)!.memberSince(currentBrand.dateJoined!),
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
          ),
        ),

      ],
    );
  }

  Widget buildBrandImagesContainer() {
    return isLoading ? Padding(
      padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.grey,
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Container(
              height: safeAreaHeight*0.3,
              width: safeAreaWidth*0.75,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    ) :  imageSliders.isNotEmpty ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: CarouselSlider(
            options: CarouselOptions(
                autoPlay: false,
                aspectRatio: 2.0,
                enlargeCenterPage: true,
                enableInfiniteScroll: false
            ),
            items: imageSliders,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height*0.03),
      ],
    ) : Container(
      width: safeAreaWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: MediaQuery.of(context).size.width*0.30,
              child: Image.asset(Constants.emptyCalendar)
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.005),
          Text(AppLocalizations.of(context)!.noImagesFound, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
          SizedBox(height: MediaQuery.of(context).size.height*0.12),
        ],
      ),
    );
  }

}