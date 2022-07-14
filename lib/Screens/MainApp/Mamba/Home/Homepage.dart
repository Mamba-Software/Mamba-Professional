import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/FeedbackDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/Notifications.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/BrandCalendarWidget.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/CancelRequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/ChatCore.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/NoBrandScreens/RegistrarMarca.dart';
import 'package:shimmer/shimmer.dart';
import '../Brand/NoBrandScreens/BrandIntroScreen.dart';

// Profile page for a trainer user.
class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  var _feedbackDataService = new FeedbackDataService();
  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  // Today Events
  List<Event> todayEvents = [];
  var todayEventsLabels = [];
  List<Widget> eventSliders = [];
  int _current = 0;
  // Images Of Events
  List<Image?> imagesEvents = [];
  var imagesEventsNum = [];
  // Codigo
  var _codigo;
  bool codigoError = false;
  bool codigoClicked = false;
  bool isLoadingCodigo = false;
  var _codigoController = TextEditingController();
  // Request To Brand
  RequestToBrand request = RequestToBrand();
  Brand? brandRequested = Brand();
  // See if Answered
  GroupOfQuestions? groupOfQuestions = new GroupOfQuestions();
  bool alreadyAnswered = false;

  @override
  void initState() {
    isLoading = true;
    initProfileHome();
    super.initState();
  }

  // Init for Brand Home
  initProfileHome() async {
    await getUser();
    unreadNotifications = await _userDataService.getUnreadNotifications(currentUser.id!);
    unreadChats = await _userDataService.getUnreadConversations(currentUser.id!);
    await getUserEventsToday();
    if (hasBrand == false) {
      await getUserPendingRequests();
    }
    if (mounted) {
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        isLoading = false;
      });
    }
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  // Gets the user info from firebase.
  Future<void> getUser() async {
    currentUser.setBasicData = await _userDataService.getUserDetails(currentUser.id!);
  }

  // Gets user events today.
  Future<void> getUserEventsToday() async {
    bool indexFound = false;
    DateTime now = DateTime.now();
    todayEvents = await _eventDataService.getUserEventsToday(currentUser.id!);
    todayEventsLabels = [];
    for (var i=0; i < todayEvents.length; i++) {
      Event event = todayEvents[i];
      // Event Time
      var startDate =  DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      var hour = event.duration.toString().split(".")[0];
      var min = event.duration!.toStringAsFixed(2).split(".")[1];
      var endDate =  startDate.add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
      if (startDate.isBefore(now) && endDate.isBefore(now)) {
        // Done
        todayEventsLabels.add(2);
      }
      if (startDate.isBefore(now) && endDate.isAfter(now)) {
        // Doing
        todayEventsLabels.add(1);
        _current = i;
        indexFound = true;
      }
      if (startDate.isAfter(now) && endDate.isAfter(now)) {
        // To Do
        todayEventsLabels.add(0);
      }
      // Define Scroll Position
      if (!indexFound && startDate.isAfter(now)) {
        _current = i;
        indexFound = true;
      }
      // Load Images
      Image? image = buildRandomImage(imagesEventsNum);
      imagesEvents.add(image);
    }
    if (!indexFound) {
      _current = todayEvents.length-1;
    }
    eventSliders = todayEvents
        .map((item) => Container(
          child: buildEventContainer(item, safeAreaHeight*0.20, safeAreaWidth, buildRandomImage(imagesEventsNum)!, buildBadge(todayEvents.indexOf(item)))
        ))
        .toList();
    setState(() {
      todayEvents = todayEvents;
      todayEventsLabels = todayEventsLabels;
      _current = _current;
      imagesEvents = imagesEvents;
      eventSliders = eventSliders;
    });
  }

  // Get user pending requests
  Future<void> getUserPendingRequests() async {
    List<RequestToBrand> req = await _userDataService.getUserRequests(currentUser.id!);
    if (req.isNotEmpty) {
      // At this moment, only 1 requests possible
      var brandReq = await _brandDataService.getBrandCoverDetails(req[0].brandId!);
      setState(() {
        request = req[0];
        brandRequested = brandReq;
      });
    } else {
      setState(() {
        request = RequestToBrand();
      });
    }
  }

  // Navigate to Notifications Screen
  void navigateToNotificationsScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => Notifications(),
        )
    ).whenComplete(() async {
      var temp = await _userDataService.getUnreadNotifications(currentUser.id!);
      setState(() {
        unreadNotifications = temp;
      });
    });
  }

  // Navigate to Notifications Screen
  void navigateToChatScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => ChatCore(),
        )
    ).whenComplete(() async {
      var temp = await _userDataService.getUnreadConversations(currentUser.id!);
      setState(() {
        unreadChats = temp;
      });
    });
  }

  // Navigate to Event Screen on Tap
  void navigateToEventScreen(String eventId) {
    // Navigate to Event Screen
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => EventPage(
            eventId: eventId,
          ),
        )
    ).whenComplete(() async {
      print("hola");
      await getUserEventsToday();
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
    ).whenComplete(() async {
      await getUserEventsToday();
    });
  }

  // Build Greeting Widget
  Widget buildGreetingWidget() {
    return Container(
      height: safeAreaHeight*0.1,
      width: safeAreaHeight*0.84,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildUserPicture(),
          SizedBox(width: safeAreaWidth*0.02,),
          Expanded(
            child: Container(
              child: isLoading ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: AppColors.grey,
                    highlightColor: AppColors.grey.withOpacity(0.5),
                    child: Container(
                      height: safeAreaHeight * 0.02,
                      width: safeAreaWidth * 0.2,
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: AppColors.grey,
                    highlightColor: AppColors.grey.withOpacity(0.5),
                    child: Container(
                      height: safeAreaHeight * 0.03,
                      width: safeAreaWidth * 0.3,
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ],
              ) : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringUtils().greetingMessage(context),
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.grey),
                    textAlign: TextAlign.center
                  ),
                  Text(
                    currentUser.firstName!,
                    style: Theme.of(context).textTheme.headline1,
                    textAlign: TextAlign.center
                  ),
                ],
              ),
            ),
          ),
          isLoading ? Container(
            width: safeAreaWidth*0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: AppColors.grey,
                  highlightColor: AppColors.grey.withOpacity(0.5),
                  child: Container(
                    height: safeAreaHeight * 0.04,
                    width: safeAreaHeight * 0.04,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(width: safeAreaWidth*0.02,),
                Shimmer.fromColors(
                  baseColor: AppColors.grey,
                  highlightColor: AppColors.grey.withOpacity(0.5),
                  child: Container(
                    height: safeAreaHeight * 0.04,
                    width: safeAreaHeight * 0.04,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),

              ],
            ),
          ) : Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CounterBadgeIcon(
                  counter: unreadNotifications,
                  child: IconButton(
                    icon: Icon(Icons.notifications, color: Theme.of(context).primaryColor, size: safeAreaWidth*0.06),
                    alignment: Alignment.centerRight,
                    onPressed: navigateToNotificationsScreen,
                  ),
                ),
                CounterBadgeIcon(
                  counter: unreadChats,
                  child: IconButton(
                    icon: Icon(Icons.chat, color: Theme.of(context).primaryColor, size: safeAreaWidth*0.06),
                    alignment: Alignment.centerRight,
                    onPressed: navigateToChatScreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the Widget of the Image
  Widget buildUserPicture() {
    return !isLoading ? Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            currentIndex = 3;
          });
          pageController.jumpToPage(currentIndex);
        },
        child: Container(
          height: safeAreaHeight * 0.1,
          child: Center(
            child: CircularImage(size: safeAreaHeight * 0.08, image: currentUser.imageUrl, color: Theme.of(context).backgroundColor, borderWidth: 2,),
          ),
        ),
      ),
    ) : Center(
      child: Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Container(
          height: safeAreaHeight * 0.08,
          width: safeAreaHeight * 0.08,
          decoration: BoxDecoration(
            color: AppColors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // Build Greeting Widget
  Widget buildTodayEventsWidget() {
    return isLoading ?
    Shimmer.fromColors(
      baseColor: AppColors.grey,
      highlightColor: AppColors.grey.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal:safeAreaWidth*0.08),
            child: Container(
              height: safeAreaHeight*0.03,
              width: safeAreaWidth*0.4,
              decoration: new BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: safeAreaHeight*0.02,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal:safeAreaWidth*0.08),
            child: Container(
              height: safeAreaHeight*0.20,
              width: safeAreaWidth,
              decoration: new BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    )
        :
    todayEvents.length != 0 ? Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: safeAreaHeight*0.05,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal:safeAreaWidth*0.08),
              child: Text(AppLocalizations.of(context)!.todaysBrandEvents, style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.w400), textAlign: TextAlign.start),
            ),
          ),
          Container(
            height: safeAreaHeight*0.20,
            width: safeAreaWidth,
            child: CarouselSlider(
              options: CarouselOptions(
                  autoPlay: false,
                  aspectRatio: 2.0,
                  viewportFraction: 0.84,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  initialPage: _current,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }
              ),
              items: eventSliders,
            ),
          ),
          todayEvents.length > 1 ? Container(
            height: safeAreaHeight*0.05,
            width: safeAreaWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: eventSliders.asMap().entries.map((entry) {
                return Container(
                  width: safeAreaHeight*0.01,
                  height: safeAreaHeight*0.01,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                );
              }).toList(),
            ),
          ) : Container(),
        ],
      ),
    ) : Container(
      height: safeAreaHeight*0.10,
      width: safeAreaWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal:safeAreaWidth*0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.noEventsToday, style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.w400), textAlign: TextAlign.start),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build Event Container
  Widget buildEventContainer(Event event, var height, var width, var image, var badge) {
    return GestureDetector(
      onTap: () => navigateToEventScreen(event.id!),
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
              height: height,
              width: width,
              decoration: new BoxDecoration(
                color: Colors.transparent,
                borderRadius: new BorderRadius.all(
                  const Radius.circular(10.0),
                ),
                image: new DecorationImage(
                  fit: BoxFit.cover,
                  //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
                  image: image.image,
                ),
              ),
              child: Center(),
            ),
            Container(
              height: height,
              width: width,
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
                border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                borderRadius: new BorderRadius.all(
                  const Radius.circular(10.0),
                ),
              ),
              child: Center(),
            ),
            Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: width*0.8,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(event.title!,
                              style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.left),
                        ),
                        SizedBox(width: width*0.05),
                        badge,
                      ],
                    ),
                  ),
                  SizedBox(height: height*0.05),
                  Container(
                    width: width*0.7,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.white,
                            size: width*0.04,
                          ),
                          SizedBox(width: width*0.02),
                          Text(
                            event.hour.toString(),
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          Text(
                            ":",
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          Text(
                            event.minute=="0" ? "00" : event.minute.toString(),
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          Container(
                              height: 16,
                              width: 32,
                              child: VerticalDivider(color: Colors.white, width: 10, thickness: 2,)
                          ),
                          Icon(
                            Icons.timer,
                            color: Colors.white,
                            size: width*0.04,
                          ),
                          SizedBox(width: width*0.02),
                          Text(
                            StringUtils().durationToString(event.duration!),
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          Container(
                              height: 16,
                              width: 32,
                              child: VerticalDivider(color: Colors.white, width: 10, thickness: 2,)
                          ),
                          Icon(
                            Icons.record_voice_over,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: width*0.02),
                          Text(
                            event.numTrainers.toString(),
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          Container(
                              height: 16,
                              width: 32,
                              child: VerticalDivider(color: Colors.white, width: 10, thickness: 2,)
                          ),
                          Icon(
                            Icons.directions_run,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: width*0.02),
                          Text(
                            event.numClients.toString(),
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Return bade on events Today
  Widget buildBadge(int index) {
    int label = todayEventsLabels[index];
    var badgeHeight = safeAreaHeight*0.03;
    switch (label) {
    // To Do
      case 0:
        return Material(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
          child: Container(
            height: badgeHeight,
            constraints: BoxConstraints(
              maxWidth: safeAreaWidth*0.25,
            ),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(AppLocalizations.of(context)!.toDo,
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10), textAlign: TextAlign.left),
                  ),
                  SizedBox(width: safeAreaWidth*0.01,),
                  Icon(
                    Icons.update_outlined,
                    color: Colors.white,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        );
    // Doing
      case 1:
        return Material(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
          child: Container(
            height: badgeHeight,
            constraints: BoxConstraints(
              maxWidth: safeAreaWidth*0.25,
            ),
            decoration: BoxDecoration(
                color: Theme.of(context).accentColor, borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.02),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Text(AppLocalizations.of(context)!.doing,
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10), textAlign: TextAlign.left),
                  ),
                  SizedBox(width: safeAreaWidth*0.01,),
                  Icon(
                    Icons.hourglass_top_outlined,
                    color: Colors.white,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        );
    // Done
      case 2:
        return Material(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
          child: Container(
            height: badgeHeight,
            constraints: BoxConstraints(
              maxWidth: safeAreaWidth*0.25,
            ),
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.finished,
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10), textAlign: TextAlign.left),
                  SizedBox(width: safeAreaWidth*0.01,),
                  Icon(
                    Icons.done_outline_outlined,
                    color: Colors.white,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        );

      default:
        return Container();
    }
  }

  // Gets Random Image for each Event.
  Image? buildRandomImage(var prohibited) {
    Random random = new Random();
    bool isOkay = false;
    int randomNumber = 0;
    do {
      randomNumber = random.nextInt(15);
      if (!prohibited.contains(randomNumber)) {
        isOkay = true;
        imagesEventsNum.add(randomNumber);
      }
    } while(!isOkay);

    switch(randomNumber) {
      case 0: {
        return Image.asset(Constants.eventBackground, gaplessPlayback: true,);
      }
      case 1: {
        return Image.asset(Constants.eventBackground1, gaplessPlayback: true,);
      }
      case 2: {
        return Image.asset(Constants.eventBackground2, gaplessPlayback: true,);
      }
      case 3: {
        return Image.asset(Constants.eventBackground3, gaplessPlayback: true,);
      }
      case 4: {
        return Image.asset(Constants.eventBackground4, gaplessPlayback: true,);
      }
      case 5: {
        return Image.asset(Constants.eventBackground5, gaplessPlayback: true,);
      }
      case 6: {
        return Image.asset(Constants.eventBackground6, gaplessPlayback: true,);
      }
      case 7: {
        return Image.asset(Constants.eventBackground7, gaplessPlayback: true,);
      }
      case 8: {
        return Image.asset(Constants.eventBackground8, gaplessPlayback: true,);
      }
      case 9: {
        return Image.asset(Constants.eventBackground9, gaplessPlayback: true,);
      }
      case 10: {
        return Image.asset(Constants.eventBackground10, gaplessPlayback: true,);
      }
      case 11: {
        return Image.asset(Constants.eventBackground11, gaplessPlayback: true,);
      }
      case 12: {
        return Image.asset(Constants.eventBackground12, gaplessPlayback: true,);
      }
      case 13: {
        return Image.asset(Constants.eventBackground13, gaplessPlayback: true,);
      }
      case 14: {
        return Image.asset(Constants.eventBackground14, gaplessPlayback: true,);
      }
      case 15: {
        return Image.asset(Constants.eventBackground15, gaplessPlayback: true,);
      }
      default: {
        return Image.asset(Constants.eventBackground, gaplessPlayback: true,);
      }
    }
  }

  // Build Plan/Book sesion or join Brand, depending on if User has Brand
  Widget buildUserPlanBookorJoinBrandSessions() {
    return isLoading ? Padding(
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
    ) :
        hasBrand ?
          buildUserPlanBookSessions()
            :
          buildSendRequestToBrand();
  }

  // Builds the Widget for Planing/Booking Sessions
  Widget buildUserPlanBookSessions() {
      return isLoading ? Padding(
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
          currentUser.isTrainer! ? FloatingActionButton.extended(
            heroTag: "88",
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
          ) :
          FloatingActionButton.extended(
            heroTag: "89",
            onPressed: navigateToBrandCalendarScreen,
            backgroundColor: Theme.of(context).accentColor,
            icon: Icon(
              Icons.calendar_month,
              color: AppColors.white,
              size: safeAreaWidth*0.05,
            ),
            label: Text(
                AppLocalizations.of(context)!.planNewEvent,
                style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white)
            ),
          ),
        ],
      ),
    );
  }

  // Build send request to Brand
  Widget buildSendRequestToBrand() {
    return request.id == null ?
    Column(
      children: [
        currentUser.isTrainer! ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
              child: FloatingActionButton.extended(
                heroTag: "46",
                onPressed: () async {
                  bool? result = await Navigator.push(
                      context,
                      CupertinoPageRoute<bool>(
                        builder: (context) => BrandIntroScreen(),
                      )
                  );
                  if (result != null && result) {
                    Navigator.push(
                        context,
                        CupertinoPageRoute<Null>(
                          builder: (context) => RegistrarMarca(
                            locale: Localizations.localeOf(context),
                          ),
                          settings: RouteSettings(name: 'RegistrarMarca'),
                        )
                    );
                  }
                },
                icon: Icon(Icons.add_circle_outline, size: MediaQuery.of(context).size.height*0.04, color: Colors.white,),
                label: Text(AppLocalizations.of(context)!.createBrand, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),),
              ),
            ),
          ],
        ) : Container(),
        currentUser.isTrainer! ? SizedBox(height: MediaQuery.of(context).size.height*0.08) : Container(),
        currentUser.isTrainer! ? Padding(
          padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
          child: ListTile(
            leading: Icon(Icons.groups, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.04,),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.findBrandTrainerText,
                    style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.03,),
            onTap: () async {
              setState(() {
                currentIndex = 1;
              });
              pageController.animateToPage(currentIndex, duration: Duration(milliseconds: 500), curve: Curves.ease);
            },
          ),
        ) : Padding(
          padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
          child: ListTile(
            leading: Icon(Icons.groups, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.04,),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.findBrandClientText,
                    style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.03,),
            onTap: () async {
              setState(() {
                currentIndex = 1;
              });
              pageController.animateToPage(currentIndex, duration: Duration(milliseconds: 500), curve: Curves.ease);
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height*0.04),
      ],
    ) :
    Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.05),
          child: ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width*0.15,
              image: brandRequested!.logoUrl!,
              color: Theme.of(context).accentColor,
              borderWidth: 1,
            ),
            title: Container(
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyText2,
                  children: [
                    TextSpan(text: AppLocalizations.of(context)!.waitingRequestConfirmation),
                    TextSpan(text: brandRequested!.name!, style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  AppLocalizations.of(context)!.requestSent(request.dateSent!),
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            trailing: Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: 30,),
            onTap: () async {
              var result = await showDialog(
                  context: context,
                  builder: (_) {
                    return CancelRequestConfirmationDialog(
                      text: AppLocalizations.of(context)!.cancelRequestConfirmation,
                      brand: brandRequested!,
                    );
                  }
              );
              if (result) {
                NotificationService().userCancelRequestToBrand(currentUser.id!, request.brandId!);
                await _userDataService.deleteRequestToBrand(request);
                getUserPendingRequests();
              }
            },
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height*0.04),
      ],
    );
  }

  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }

    return Scaffold (
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
        ),
        body: SafeArea(
          left: false,
          right: false,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: safeAreaHeight*0.06,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                  child: buildGreetingWidget(),
                ),
                SizedBox(height: safeAreaHeight*0.06,),
                buildTodayEventsWidget(),
                SizedBox(height: safeAreaHeight*0.06,),
                buildUserPlanBookorJoinBrandSessions(),
                SizedBox(height: safeAreaHeight*0.06,),
                FloatingActionButton.extended(
                  heroTag: "99",
                  onPressed: () async {
                    // Get the Dates
                    DateTime before = DateTime.now().add(Duration(seconds: 3600));
                    String eventTimeTime = StringUtils().hourMinutesToString(before.hour, before.minute);
                    // Notification one hour before
                    ReceivedNotification notification = ReceivedNotification(
                      id: DateTime.now().millisecondsSinceEpoch ~/1000,
                      title: AppLocalizations.of(context)!.beforeEventTitleNotification("Wod", eventTimeTime),
                      body: AppLocalizations.of(context)!.beforeEventBodyNotification,
                      payload: "15b96830-01ee-11ed-821f-03a4f0c30c58",
                      createdAt: Timestamp.now(),
                      firesAt: before,
                    );
                    LocalNotificationService().addLocalNotification(notification);
                    await Future.delayed(Duration(seconds: 5));
                    ReceivedNotification notification2 = ReceivedNotification(
                      id: DateTime.now().millisecondsSinceEpoch ~/1000,
                      title: AppLocalizations.of(context)!.afterEventTitleNotification,
                      body: AppLocalizations.of(context)!.afterEventBodyNotification,
                      payload: "F-15b96830-01ee-11ed-821f-03a4f0c30c58",
                      createdAt: Timestamp.now(),
                      firesAt: before,
                    );
                    LocalNotificationService().addLocalNotification(notification2);
                  },
                  backgroundColor: Theme.of(context).accentColor,
                  icon: Icon(
                    Icons.calendar_month,
                    color: AppColors.white,
                    size: safeAreaWidth*0.05,
                  ),
                  label: Text(
                      "scheduleNotif",
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white)
                  ),
                ),
                SizedBox(height: safeAreaHeight*0.06,),
                FloatingActionButton.extended(
                  heroTag: "100",
                  onPressed: () async {
                    LocalNotificationService().cancellAllLocalNotification();
                  },
                  backgroundColor: Theme.of(context).accentColor,
                  icon: Icon(
                    Icons.calendar_month,
                    color: AppColors.white,
                    size: safeAreaWidth*0.05,
                  ),
                  label: Text(
                      "Cancell All",
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white)
                  ),
                ),
                SizedBox(height: safeAreaHeight*0.06,),
              ],
            ),
          ),
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}

