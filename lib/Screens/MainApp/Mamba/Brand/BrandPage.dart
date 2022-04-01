import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TitleHeadline1.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Calendars/CalendarWidgetTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/ImageFullScreen.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Calendars/BrandEventsToday.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/TodosMiembrosTrainer.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

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
  Widget buildBrandPhotosContainer() {
    // Build Event Image Widget
    imageSliders = _imagesUploaded
        .map((item) => Container(
          child: Container(
            height: safeAreaHeight * 0.25,
            width: double.infinity,
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: CachedNetworkImageProvider(item.url!),
                  )
              )
          ),
        ))
        .toList();
    return Container(
      height: safeAreaHeight * 0.30,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: safeAreaHeight * 0.25,
            width: double.infinity,
            child: CarouselSlider(
              options: CarouselOptions(
                  autoPlay: true,
                  scrollPhysics: NeverScrollableScrollPhysics(),
                  autoPlayInterval: Duration(seconds: 10),
                  autoPlayAnimationDuration: Duration(seconds: 3),
                  reverse: true,
                  aspectRatio: 2.0,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false
              ),
              items: imageSliders,
            ),
          ),
          Positioned(
            top: safeAreaHeight*0.23,
            child: Container(
              height: safeAreaHeight*0.02,
              width: safeAreaWidth,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
              ),
            ),
          ),
          Positioned(
            top: safeAreaHeight*0.10,
            child: GestureDetector(
              onTap: navigateToFullScreenImage,
              child: Container(
                height: safeAreaHeight*0.2,
                child: Center(
                  child: CircularImage(size: MediaQuery.of(context).size.width * 0.30, image: currentBrand.logoUrl, color: Theme.of(context).accentColor, borderWidth: 2,),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Share App Container.
  Widget buildTitleBarContainer() {
    return Container(child: TitleHeadline1(text: currentBrand.name!,));
  }

  // Build Share App Container.
  Widget buildBrandOptionsContainer() {
    return Container(
      height: 80.0,
      width: double.infinity,
      child: ListView(
        children: <Widget>[
          new Container(
            height: 80.0,
            child: new ListView(
              scrollDirection: Axis.horizontal,
              children: new List.generate(10, (int index) {
                return new Card(
                  color: Colors.blue[index * 100],
                  child: new Container(
                    width: 50.0,
                    height: 50.0,
                    child: new Text("$index"),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }

    return Scaffold(
        appBar: null,
        body: CustomScrollView(
          slivers: [
            // Add the app bar to the CustomScrollView.
            const SliverAppBar(
              // Provide a standard title.
              title: Text("Hola"),
              // Allows the user to reveal the app bar if they begin scrolling
              // back up the list of items.
              floating: true,
              // Display a placeholder widget to visualize the shrinking size.
              flexibleSpace: Placeholder(),
              // Make the initial height of the SliverAppBar larger than normal.
              expandedHeight: 200,
            ),
            // Next, create a SliverList
            SliverList(
              // Use a delegate to build items as they're scrolled on screen.
              delegate: SliverChildBuilderDelegate(
                // The builder function returns a ListTile with a title that
                // displays the index of the current item.
                    (context, index) => ListTile(title: Text('Item #$index')),
                // Builds 1000 ListTiles
                childCount: 1000,
              ),
            ),
          ],
        ),
    );

    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildBrandPhotosContainer(),
            buildTitleBarContainer(),
            buildBrandOptionsContainer(),


            SizedBox(height: MediaQuery.of(context).size.height*0.2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: Text(
                      "${currentBrand.name!}",
                      style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left
                  ),
                ),//
                Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child:  MembershipRequests(
                                  brandId: currentBrand.id!,
                                ),
                              )
                          ).whenComplete(() {
                            setState(() {
                              isLoading = true;
                              initBrandHome();
                            });
                          });
                        },
                        icon: Icon(
                          Icons.group_add,
                          size: MediaQuery.of(context).size.width*0.06,
                        )
                    ),
                    IconButton(
                      icon: Icon(Icons.menu_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.06,),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: SettingsBrand(),
                            )
                        ).whenComplete(() {
                          setState(() {
                            isLoading = true;
                            initBrandHome();
                          });
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.02),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
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
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height*0.15,
                    child: Center(
                      child: CircularImage(size: MediaQuery.of(context).size.width * 0.33, image: currentBrand.logoUrl, color: Theme.of(context).accentColor, borderWidth: 2,),
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width*0.05),
                Container(
                  height: MediaQuery.of(context).size.height*0.15,
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.directions_run, color: Theme.of(context).accentColor, size: MediaQuery.of(context).size.width * 0.04,),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                Text(
                                  currentBrand.numClients.toString(),
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                Flexible(child: Text(AppLocalizations.of(context)!.clients.toLowerCase(),
                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).accentColor),
                                  textAlign: TextAlign.center,))
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.record_voice_over, color: Theme.of(context).accentColor, size: MediaQuery.of(context).size.width * 0.04,),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                Text(
                                  currentBrand.numTrainers.toString(),
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                Flexible(child: Text(AppLocalizations.of(context)!.trainers.toLowerCase(),
                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).accentColor),
                                  textAlign: TextAlign.center,))
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.event_available_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width * 0.04,),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                Text(
                                  numberEventsFinished.toString(),
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                Flexible(child: Text(AppLocalizations.of(context)!.sessionsDone.toLowerCase(),
                                  style: Theme.of(context).textTheme.bodyText2,
                                  textAlign: TextAlign.center,))
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.event, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width * 0.04,),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                Text(
                                  numberEventsToDo.toString(),
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                Flexible(child: Text(AppLocalizations.of(context)!.sessionsToDo.toLowerCase(),
                                  style: Theme.of(context).textTheme.bodyText2,
                                  textAlign: TextAlign.center,))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.04),
            todayEvents.length > 0 ? Column(
              children: [
                Platform.isAndroid ? SizedBox(height: MediaQuery.of(context).size.height*0.01) : Container(),
                GestureDetector(
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
                  child: Material(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.08,
                      decoration: new BoxDecoration(
                        color: Theme.of(context).accentColor,
                        border: Border.all(color: Theme.of(context).accentColor, width: 1),
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
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04),
              ],
            ) : Container(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: CalendarWidgetTrainer(
                          brandID: currentBrand.id!,
                          canEdit: true,
                        )
                    )
                ).whenComplete(() {
                  setState(() {
                    isLoading = true;
                    initBrandHome();
                  });
                });
              },
              child: Material(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.20,
                      decoration: new BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Theme.of(context).accentColor, width: 1),
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                        image: new DecorationImage(
                          fit: BoxFit.cover,
                          //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(1), BlendMode.dstATop),
                          image: Image.asset(Constants.mySessionsImage).image,
                        ),
                      ),
                      child: Center(),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.20,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                              Colors.grey.withOpacity(0.0),
                              Colors.black,
                            ],
                            stops: [
                              0.0,
                              0.75
                            ]
                        ),
                        border: Border.all(color: Theme.of(context).accentColor, width: 1),
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      child: Center(),
                    ),
                    Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.calendar, style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Text(AppLocalizations.of(context)!.calendarBrandText(currentBrand.name!), style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.04),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: TodosMiembrosTrainer()
                    )
                ).whenComplete(() {
                  setState(() {
                    isLoading = true;
                    initBrandHome();
                  });
                });
              },
              child: Material(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.20,
                      decoration: new BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Theme.of(context).accentColor, width: 1),
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                        image: new DecorationImage(
                          fit: BoxFit.cover,
                          //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(1), BlendMode.dstATop),
                          image: Image.asset(Constants.teamImage).image,
                        ),
                      ),
                      child: Center(),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.20,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                              Colors.grey.withOpacity(0.0),
                              Colors.black,
                            ],
                            stops: [
                              0.0,
                              0.75
                            ]
                        ),
                        border: Border.all(color: Theme.of(context).accentColor, width: 1),
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      child: Center(),
                    ),
                    Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.members, style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Text(AppLocalizations.of(context)!.membersBrandText, style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.04),
            GestureDetector(
              onTap: () {

              },
              child: Material(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.20,
                      decoration: new BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Theme.of(context).accentColor, width: 1),
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                        image: new DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
                          image: Image.asset(Constants.statisticsImage).image,
                        ),
                      ),
                      child: Center(),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.20,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                              Colors.grey.withOpacity(0.0),
                              Colors.black,
                            ],
                            stops: [
                              0.0,
                              0.75
                            ]
                        ),
                        border: Border.all(color: Theme.of(context).accentColor, width: 1),
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      child: Center(),
                    ),
                    Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.stats, style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Text(AppLocalizations.of(context)!.statsBrandText, style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.70, bottom: MediaQuery.of(context).size.height * 0.07),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.5), size: MediaQuery.of(context).size.height * 0.05,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.04),
          ],
        ),
      ),
    );
  }
}