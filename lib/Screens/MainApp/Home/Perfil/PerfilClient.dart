import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DatabaseAccess.dart';
import 'package:mamba_castelldefels/Data/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/MyCalendarWidget.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/CancelRequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Images/ImageFullScreen.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/Settings.dart';
import 'package:page_transition/page_transition.dart';

import 'PerfilModals/FeedBack.dart';

class PerfilClient extends StatefulWidget {
  const PerfilClient({Key? key}) : super(key: key);

  @override
  _PerfilClientState createState() => _PerfilClientState();
}

class _PerfilClientState extends State<PerfilClient> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  // Events
  int totalEvents = 0;
  int thisMonthEvents  = 0;
  List<Event> todayEvents = [];
  var todayEventsLabels = [];
  int scrollIndex = 0;
  ScrollController? _scrollController;
  // Codigo
  var _codigo;
  bool codigoError = false;
  bool codigoClicked = false;
  bool isLoadingCodigo = false;
  var _codigoController = TextEditingController();
  // Request To Brand
  RequestToBrand request = RequestToBrand();
  Brand? brandRequested = Brand();
  // Images Of Events
  List<Image?> imagesEvents = [];
  var imagesEventsNum = [];
  Image? mySessions = Image.asset(Constants.calendarImage);
  Image? myProgress = Image.asset(Constants.myProgressImage);
  // See if Answered
  GroupOfQuestions? groupOfQuestions = new GroupOfQuestions();
  bool alreadyAnswered = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    initProfileHome();
  }

  // Did Change Dependencies
  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(mySessions!.image, context);
    precacheImage(myProgress!.image, context);
    for (var i=0; i<imagesEvents.length; i++) {
      precacheImage(imagesEvents[i]!.image, context);
    }
  }

  // Init for Brand Home
  initProfileHome() async {
    getUser();
    if (hasBrand == false) {
      await getUserPendingRequests();
    } else {
      await getClientEventsDone();
    }
    await getUserEventsToday();
    await checkIfAnswered();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Gets the user info from firebase.
  void getUser() async {
    currentUser = await _accessDatabase.getUserDetails(currentUser.id!);
  }

  // Gets user events today.
  Future<void> getUserEventsToday() async {
    bool indexFound = false;
    DateTime now = DateTime.now();
    todayEvents = await _accessDatabase.getAllEventsTodayUser(currentUser.id!, currentUser.isTrainer!);
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
        scrollIndex = i;
        indexFound = true;
      }
      if (startDate.isAfter(now) && endDate.isAfter(now)) {
        // To Do
        todayEventsLabels.add(0);
      }
      // Define Scroll Position
      if (!indexFound && startDate.isAfter(now)) {
        scrollIndex = i;
        indexFound = true;
      }
      // Load Images
      Image? image = returnRandomImage(imagesEventsNum);
      imagesEvents.add(image);
    }
    if (!indexFound) {
      scrollIndex = todayEvents.length-1;
    }
    _scrollController = ScrollController(initialScrollOffset: MediaQuery.of(context).size.width * scrollIndex);
  }

  // Check If Answered
  Future<void> checkIfAnswered() async {
    this.groupOfQuestions = await this._accessDatabase.getActiveGroupOfQuestions();
    if (groupOfQuestions != null) {
      alreadyAnswered = await this ._accessDatabase.checkIfAnswersExist(this.groupOfQuestions!.id);
    } else {
      alreadyAnswered = true;
    }
  }

  // Build Custom Badge
  Widget buildCustomBadge({required Widget child}) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          bottom: 0,
          child: child,
        ),
        Positioned(
          top: -MediaQuery.of(context).size.height*0.05,
          right: -MediaQuery.of(context).size.width*0.17,
          left: 0,
          bottom: 0,
          child: Icon(Icons.feedback, color: Theme.of(context).accentColor, size: MediaQuery.of(context).size.height*0.04),
        ),
      ],
    );
  }

  // Return bade on events Today
  Widget returnBadge(int index) {
    int label = todayEventsLabels[index];
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
            height: MediaQuery.of(context).size.height*0.03,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width*0.30,
            ),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(AppLocalizations.of(context)!.toDo,
                        style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12, fontFamily: "Helvetica"), textAlign: TextAlign.left),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                  Icon(
                    Icons.update_outlined,
                    color: Colors.white,
                    size: 20,
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
            height: MediaQuery.of(context).size.height*0.03,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width*0.30,
            ),
            decoration: BoxDecoration(
                color: Theme.of(context).accentColor, borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Text(AppLocalizations.of(context)!.doing,
                        style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12, fontFamily: "Helvetica"), textAlign: TextAlign.left),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                  Icon(
                    Icons.hourglass_top_outlined,
                    color: Colors.white,
                    size: 20,
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
            height: MediaQuery.of(context).size.height*0.03,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width*0.30,
            ),
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.finished,
                      style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12, fontFamily: "Helvetica"), textAlign: TextAlign.left),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01,),
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
  Image? returnRandomImage(var prohibited) {
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

  Future<void> getClientEventsDone() async {
    List<int> res = await _accessDatabase.getAllClientEventsFinished(currentUser.id!, currentBrand.id!);
    totalEvents = res[0];
    thisMonthEvents = res[1];
  }

  durationToString(double duration) {
    String temp = "";
    temp = duration.toStringAsFixed(2);
    var hour = temp.split(".")[0];
    var min = temp.split(".")[1];
    return "${hour}h ${min}m ";
  }

  Widget build(BuildContext context) {

    return isLoading ?
    Center(
        child: LoadingViewPurple()
    )
        :
    Scaffold(
      appBar: null,
      body: currentBrand.id != null ? SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.3,
              child: Stack(
                  alignment: Alignment.topCenter,
                  fit: StackFit.expand,
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      bottom: MediaQuery.of(context).size.height*0.13,
                      left: 0,
                      right: MediaQuery.of(context).size.width*0.70,
                      child: alreadyAnswered ?
                      IconButton(
                        icon: Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.05,),
                        alignment: Alignment.center,
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: FeedBack(),
                              )
                          ).whenComplete(() {
                            setState(() {
                              isLoading = true;
                              initProfileHome();
                            });
                          });
                        },
                      )
                          :
                      buildCustomBadge(
                          child: IconButton(
                            icon: Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.05,),
                            alignment: Alignment.center,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: FeedBack(),
                                  )
                              ).whenComplete(() {
                                setState(() {
                                  isLoading = true;
                                  initProfileHome();
                                });
                              });
                            },
                          )
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height*0.12,
                      bottom: 0,
                      left: 0,
                      right: MediaQuery.of(context).size.width*0.70,
                      child: Text(
                        AppLocalizations.of(context)!.feedback,
                        style: Styles.purpleTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: MediaQuery.of(context).size.height*0.13,
                      left: MediaQuery.of(context).size.width*0.70,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.settings, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.05,),
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: Settings(),
                              )
                          ).whenComplete(() {
                            setState(() {
                              isLoading = true;
                              initProfileHome();
                            });
                          });
                        },
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height*0.12,
                      bottom: 0,
                      left: MediaQuery.of(context).size.width*0.70,
                      right: 0,
                      child: Text(
                        AppLocalizations.of(context)!.settings,
                        style: Styles.purpleTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height*0.09,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute<Null>(
                                  builder: (context) => FullScreenPage(
                                    child:  Image.network(
                                      currentUser.imageUrl!,
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
                          height: MediaQuery.of(context).size.height * 0.23,
                          child: Center(
                            child: CircularImage(size: MediaQuery.of(context).size.height * 0.23, image: currentUser.imageUrl, color: Theme.of(context).accentColor, borderWidth: 2,),
                          ),
                        ),
                      ),
                    ),
                  ]
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.03),
            Container(
              padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Text(
                          "${currentUser.name!}",
                          style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 24, fontFamily: "Helvetica"),
                          textAlign: TextAlign.center
                      )
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  //elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.81,
                    height: MediaQuery.of(context).size.height * 0.10,
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      //border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                      borderRadius: new BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.10,
                          width: MediaQuery.of(context).size.width * 0.38,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                totalEvents.toString(),
                                style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 2),
                              Text(
                                AppLocalizations.of(context)!.allEvents,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.05,
                          height: MediaQuery.of(context).size.height * 0.03,
                          child: VerticalDivider(color: Theme.of(context).primaryColor,),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.10,
                          width: MediaQuery.of(context).size.width * 0.38,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                thisMonthEvents.toString(),
                                style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 2),
                              Text(
                                AppLocalizations.of(context)!.monthEvents,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.02),
            todayEvents.length != 0 ? Container(
              height: MediaQuery.of(context).size.height*0.31,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.todaysBrandEvents, style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w400, fontSize: 20,), textAlign: TextAlign.start),
                        todayEvents.length > 1 ? Row(
                          children: [
                            Text(todayEvents.length.toString(), style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontSize: 16, fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                            SizedBox(width: MediaQuery.of(context).size.width*0.01),
                            Text(AppLocalizations.of(context)!.events, style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontSize: 16, fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                            SizedBox(width: MediaQuery.of(context).size.width*0.01),
                            Icon(
                              Icons.swipe,
                              color: Colors.black,
                              size: 20,
                            ),
                          ],
                        ) : Container(),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Container(
                    height: MediaQuery.of(context).size.height*0.23,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: todayEvents.length,
                        itemBuilder: (context, int index) {
                          var event = todayEvents[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.05),
                            child: GestureDetector(
                              onTap: () {
                                bool canEdit = true;
                                DateTime startDate = DateTime(
                                  int.parse(event.year!),
                                  int.parse(event.month!),
                                  int.parse(event.day!),
                                  int.parse(event.hour!),
                                  int.parse(event.minute!),
                                );
                                if (startDate.isBefore(DateTime.now())) {
                                  canEdit = false;
                                }
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.bottomToTop,
                                        child: ViewEventClient(
                                          eventId: event.id!,
                                          canJoin: canEdit,
                                          locale: Localizations.localeOf(context),
                                        )
                                    )
                                ).whenComplete(() {
                                  setState(() {
                                    isLoading = true;
                                    initProfileHome();
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
                                      height: MediaQuery.of(context).size.height * 0.28,
                                      width: MediaQuery.of(context).size.width * 0.90,
                                      decoration: new BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: new BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                        image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
                                          image: imagesEvents[index]!.image,
                                        ),
                                      ),
                                      child: Center(),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.90,
                                      height: MediaQuery.of(context).size.height * 0.28,
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
                                      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width*0.8,
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Text(event.title!,
                                                      style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20, fontFamily: "Helvetica"), textAlign: TextAlign.left),
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width*0.05),
                                                returnBadge(index),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.schedule,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                              Text(
                                                event.hour.toString(),
                                                style: TextStyle(color: Colors.white, fontSize: 14),
                                              ),
                                              Text(
                                                ":",
                                                style: TextStyle(color: Colors.white, fontSize: 14),
                                              ),
                                              Text(
                                                event.minute=="0" ? "00" : event.minute.toString(),
                                                style: TextStyle(color: Colors.white, fontSize: 14),
                                              ),
                                              Container(
                                                  height: 16,
                                                  width: 32,
                                                  child: VerticalDivider(color: Colors.white, width: 10, thickness: 2,)
                                              ),
                                              Icon(
                                                Icons.timer,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                              Text(
                                                durationToString(event.duration!),
                                                style: TextStyle(color: Colors.white, fontSize: 14),
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
                                              SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                              Text(
                                                event.selectedTrainers.length.toString(),
                                                style: TextStyle(color: Colors.white, fontSize: 14),
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
                                              SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                              Text(
                                                event.joinedMembers.length.toString(),
                                                style: TextStyle(color: Colors.white, fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.03),
                ],
              ),
            ) : Container(
              height: MediaQuery.of(context).size.height*0.07,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.noEventsToday, style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w400, fontSize: 23,), textAlign: TextAlign.start),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.03),
                ],
              ),
            ),
            Platform.isAndroid ? SizedBox(height: MediaQuery.of(context).size.height*0.01) : Container(),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.bottomToTop,
                            child: CalendarWidgetClient(
                              brandID: currentBrand.id!,
                              onlyView: false,
                            )
                        )
                    ).whenComplete(() {
                      setState(() {
                        isLoading = true;
                        initProfileHome();
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
                              child: Icon(Icons.add, color: Colors.white, size: 30,)
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.69,
                            child: Center(child: Text(AppLocalizations.of(context)!.planNewEvent, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.w400))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: MyCalendarWidget(
                          brandID: currentBrand.id!,
                        )
                    )
                ).whenComplete(() {
                  setState(() {
                    isLoading = true;
                    initProfileHome();
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
                          image: mySessions!.image,
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
                          Text(AppLocalizations.of(context)!.mySessions, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Text(AppLocalizations.of(context)!.myScheduleText, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 14, color: Colors.grey[200])),
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
                          image: myProgress!.image,
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
                          Text(AppLocalizations.of(context)!.myProgress, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 23, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Text(AppLocalizations.of(context)!.myProgressText, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 14, color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.70, bottom: MediaQuery.of(context).size.height * 0.07),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.5), size: 50,)
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
      ) : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.3,
              child: Stack(
                  alignment: Alignment.topCenter,
                  fit: StackFit.expand,
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      bottom: MediaQuery.of(context).size.height*0.13,
                      left: 0,
                      right: MediaQuery.of(context).size.width*0.70,
                      child: alreadyAnswered ?
                      IconButton(
                        icon: Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.05,),
                        alignment: Alignment.center,
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: FeedBack(),
                              )
                          ).whenComplete(() {
                            setState(() {
                              isLoading = true;
                              initProfileHome();
                            });
                          });
                        },
                      )
                          :
                      buildCustomBadge(
                          child: IconButton(
                            icon: Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.05,),
                            alignment: Alignment.center,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: FeedBack(),
                                  )
                              ).whenComplete(() {
                                setState(() {
                                  isLoading = true;
                                  initProfileHome();
                                });
                              });
                            },
                          )
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height*0.12,
                      bottom: 0,
                      left: 0,
                      right: MediaQuery.of(context).size.width*0.70,
                      child: Text(
                        AppLocalizations.of(context)!.feedback,
                        style: Styles.purpleTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: MediaQuery.of(context).size.height*0.13,
                      left: MediaQuery.of(context).size.width*0.70,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.settings, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.05,),
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: Settings(),
                              )
                          ).whenComplete(() {
                            setState(() {
                              isLoading = true;
                              initProfileHome();
                            });
                          });
                        },
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height*0.12,
                      bottom: 0,
                      left: MediaQuery.of(context).size.width*0.70,
                      right: 0,
                      child: Text(
                        AppLocalizations.of(context)!.settings,
                        style: Styles.purpleTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height*0.09,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute<Null>(
                                  builder: (context) => FullScreenPage(
                                    child:  Image.network(
                                      currentUser.imageUrl!,
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
                          height: MediaQuery.of(context).size.height * 0.23,
                          child: Center(
                            child: CircularImage(size: MediaQuery.of(context).size.height * 0.23, image: currentUser.imageUrl, color: Theme.of(context).accentColor, borderWidth: 2,),
                          ),
                        ),
                      ),
                    ),
                  ]
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.03),
            Container(
              padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Text(
                          "${currentUser.name!}",
                          style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 24, fontFamily: "Helvetica"),
                          textAlign: TextAlign.center
                      )
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  //elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.81,
                    height: MediaQuery.of(context).size.height * 0.10,
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      //border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                      borderRadius: new BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.10,
                          width: MediaQuery.of(context).size.width * 0.38,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                totalEvents.toString(),
                                style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 2),
                              Text(
                                AppLocalizations.of(context)!.allEvents,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.05,
                          height: MediaQuery.of(context).size.height * 0.03,
                          child: VerticalDivider(color: Theme.of(context).primaryColor,),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.10,
                          width: MediaQuery.of(context).size.width * 0.38,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                thisMonthEvents.toString(),
                                style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 2),
                              Text(
                                AppLocalizations.of(context)!.monthEvents,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.02),
            request.id == null ?
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height*0.07,
                  child: !codigoClicked ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: FloatingActionButton.extended(
                          heroTag: "34",
                          onPressed: () {
                            setState(() {
                              codigoClicked = !codigoClicked;
                            });
                          },
                          backgroundColor: Colors.green,
                          icon: Icon(Icons.qr_code_outlined, size: 35,color: Colors.white,),
                          label: Text(AppLocalizations.of(context)!.addCode,
                            style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ) : Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            child: Material(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13)
                              ),
                              elevation: 5,
                              child: new TextFormField(
                                controller: _codigoController,
                                onChanged: (val) {
                                  setState(() {
                                    codigoError = false;
                                    _codigo = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.codigo,
                                  hintStyle: Styles.whiteTextStyle.copyWith(fontSize: 14, color: codigoError ? Colors.red: Colors.green),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: codigoError ? Colors.red: Colors.green, width: 1.0),
                                    borderRadius: BorderRadius.circular(13.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: codigoError ? Colors.red: Colors.green, width: 1.0),
                                    borderRadius: BorderRadius.circular(13.0),
                                  ),
                                ),
                                style: Styles.whiteTextStyle.copyWith(fontSize: 14, color: codigoError ? Colors.red: Colors.green),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          !isLoadingCodigo ?
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: FloatingActionButton(
                                  heroTag: "35",
                                  child: Icon(Icons.login),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Styles.white,
                                  onPressed: () async {
                                    if(_codigo == null || _codigo=="") {
                                      setState(() {
                                        codigoError = true;
                                      });
                                    } else {
                                      setState(() {
                                        isLoadingCodigo = true;
                                      });
                                      var result = await _accessDatabase.checkIfBrandExists(_codigo);
                                      if (!result) {
                                        Future.delayed(const Duration(milliseconds: 500), () {
                                          setState(() {
                                            isLoadingCodigo = false;
                                            codigoError = true;
                                          });
                                        });
                                      } else {
                                        await _accessDatabase.updateCurrentUserBrand(_codigo);
                                        await _accessDatabase.updateConversationNewUser(_codigo, currentUser.id);
                                        NotificationService().userJoinsBrand(currentUser.id!, _codigo);
                                        // New DataBase
                                        int role = 0;
                                        await _accessDatabase.addUserToBrand(currentUser.id!, _codigo, role);
                                        // Push To Splash Screen
                                        setState(() {
                                          currentIndex = 1;
                                        });
                                        await Future.delayed(const Duration(seconds: 3)); // Ensure listener fires
                                        Navigator.pushReplacement(
                                            context,
                                            CupertinoPageRoute<Null>(
                                              builder: (context) =>
                                                  SplashScreen(),
                                              settings: RouteSettings(
                                                  name: 'SplashScreen'),
                                            )
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: FloatingActionButton(
                                  heroTag: "36",
                                  child: Icon(Icons.close),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Styles.white,
                                  onPressed: () async {
                                    setState(() {
                                      codigoClicked = !codigoClicked;
                                      codigoError = false;
                                      _codigoController.text = "";
                                    });
                                  },
                                ),
                              ),
                            ],
                          ) :
                          SizedBox(
                            width: 130,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FloatingActionButton(
                                    heroTag: "37",
                                    child: SizedBox(
                                      width: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    backgroundColor: Colors.orangeAccent,
                                    foregroundColor: Styles.white,
                                    onPressed: false ? () {} : null
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                  child: ListTile(
                    leading: Icon(Icons.groups, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.04,),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.findBrandClientText,
                            style: Styles.purpleTextStyle.copyWith(fontSize: 14, color: Theme.of(context).primaryColor), textAlign: TextAlign.left,
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
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                Platform.isAndroid ? SizedBox(height: MediaQuery.of(context).size.height*0.02) : Container(),
              ],
            ) :
            Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.01),
                  child: ListTile(
                    leading: CircularImage(
                      size: MediaQuery.of(context).size.width*0.15,
                      image: brandRequested!.logoUrl!,
                      color: Theme.of(context).accentColor,
                      borderWidth: 1,
                    ),
                    title: Container(
                      child: RichText(
                        text: TextSpan(
                          style: Styles.purpleTextStyle.copyWith(fontSize: 16),
                          children: [
                            TextSpan(text: AppLocalizations.of(context)!.waitingRequestConfirmation),
                            TextSpan(text: brandRequested!.name!, style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),),
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
                          style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
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
            ),
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
                          image: Image.asset(Constants.calendarImage).image,
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
                          Text(AppLocalizations.of(context)!.mySessions, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 23, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Text(AppLocalizations.of(context)!.myScheduleText, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 14, color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.70, bottom: MediaQuery.of(context).size.height * 0.07),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.5), size: 50,)
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
                          image: Image.asset(Constants.myProgressImage).image,
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
                          Text(AppLocalizations.of(context)!.myProgress, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 23, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Text(AppLocalizations.of(context)!.myProgressText, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 14, color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.70, bottom: MediaQuery.of(context).size.height * 0.07),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.5), size: 50,)
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

  @override
  void dispose() {
    super.dispose();
  }

}

