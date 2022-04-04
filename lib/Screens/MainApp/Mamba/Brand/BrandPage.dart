import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/LongTextContainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TitleHeadline1.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/ImageFullScreen.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Calendars/BrandEventsToday.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Users/UsersHorizontalScroll.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandScreens/BrandCalendarWeekWidget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../Home/Marca/Trainer/TieneMarca/TieneMarcaModals/MembershipRequests.dart';
import '../../Home/Marca/Trainer/TieneMarca/TieneMarcaModals/SettingsBrand.dart';

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
  // Images uploaded
  List<ImageObject> _imagesUploaded = [];
  List<Widget> imageSliders = [];
  // Brand Events Today
  List<Event> todayEvents = [];
  int numberEventsFinished = 0;
  int numberEventsToDo = 0;
  // Scroll Controller
  List<Usuario> brandTrainers = [];

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
    _imagesUploaded = await _brandDataService.getBrandContentPictures(currentBrand.id!);
    brandTrainers = await _brandDataService.getBrandTrainers(currentBrand.id!);
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

  // Build Share App Container.
  Widget buildBrandAppBarContainer() {
    return Container(
      height: safeAreaHeight * 0.48,
      width: safeAreaWidth * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildBrandOptions(),
          SizedBox(height: safeAreaHeight*0.02,),
          buildBrandTitle(),
          SizedBox(height: safeAreaHeight*0.03,),
          buildBrandPicture(),
          SizedBox(height: safeAreaHeight*0.025,),
          buildBrandEventCount(),
        ],
      ),
    );
  }

  // Build the Widget of the Brand Name
  Widget buildBrandOptions() {
    return !isLoading ? Container(
      height: safeAreaHeight*0.08,
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
            icon: Icon(Icons.menu_outlined, color: Theme.of(context).primaryColor, size: safeAreaWidth*0.06,),
            onPressed: navigateToSettingsBrandScreen,
          ),
        ],
      ),
    ) : Container(
      height: safeAreaHeight*0.08,
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
      width: safeAreaWidth,
      child: GestureDetector(
        onTap: navigateToFullScreenImage,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularImage(
              size: safeAreaWidth * 0.35,
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
          height: safeAreaWidth * 0.35,
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
        width: safeAreaWidth * 0.9,
        height: safeAreaHeight * 0.09,
        decoration: new BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    ) : Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Container(
          width: safeAreaWidth * 0.70,
          height: safeAreaHeight * 0.08,
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
                  toolbarHeight: safeAreaHeight*0.48,
                  centerTitle: true,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarBrightness: Brightness.light,
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                  ),
                  bottom: TabBar(
                    indicatorColor: Colors.white,
                    indicatorWeight: 5,
                    isScrollable: true,
                    tabs: [
                      Container(
                        width: safeAreaWidth*0.25,
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
                        width: safeAreaWidth*0.25,
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
                        width: safeAreaWidth*0.25,
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
                        width: safeAreaWidth*0.25,
                        child: Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.brandContentTab.toUpperCase(),
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
              buildTabPage(),
              buildTabPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabPage() => SafeArea(
    top: false,
    bottom: false,
    child: Builder(
      builder: (context) => CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverPadding(
            padding: EdgeInsets.all(12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final childCount = 25;
                    final hasSeparator = index != childCount - 1;
                    final double bottom = hasSeparator ? 12 : 0;
                    final child = ListTile(title: Text('Item #$index'));

                    return Container(
                      margin: EdgeInsets.only(bottom: bottom),
                      child: child,
                    );
                  },
                  childCount: 25
              ),
            ),
          ),
        ],
      ),
    ),
  );

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
              child: buildBrandTodayContainer()
          ),
          SliverToBoxAdapter(
              child: buildBrandTrainersContainer()
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
              child: Container(
                height: safeAreaHeight*0.6,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: safeAreaHeight * 0.05,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                      child: Text(
                        AppLocalizations.of(context)!.calendarWeekBrandText,
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: safeAreaHeight * 0.04,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                      child: BrandCalendarWeekWidget(
                        brandId: currentBrand.id!,
                        height: safeAreaHeight*0.5,
                        width: safeAreaWidth*0.9,
                      ),
                    ),
                  ],
                ),
              ),
          ),
        ],
      ),
    ),
  );

  Widget buildDescriptionContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
      child: Column(
        children: [
          SizedBox(
            height: safeAreaHeight * 0.05,
          ),
          LongTextContainer(
            text: currentBrand.description!,
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
          SizedBox(
            height: safeAreaHeight * 0.02,
          ),
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
        ],
      ),
    );
  }

  Widget buildBrandTrainersContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: safeAreaHeight * 0.05,
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
          height: safeAreaHeight * 0.04,
        ),
        UsersHorizontalScroll(
          usuarios: brandTrainers,
          height: safeAreaHeight * 0.15,
          width: safeAreaWidth,
        ),

      ],
    );
  }

}