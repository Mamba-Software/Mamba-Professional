import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/FeedbackDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TextHeadline1.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Calendars/CalendarWidgetTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Calendars/MyCalendarWidget.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Events/ViewEventTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/CancelRequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/ImageFullScreen.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/SinMarca/RegistrarMarca.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/Settings.dart';
import 'package:page_transition/page_transition.dart';

import 'PerfilModals/FeedBack.dart';

// Profile Page
class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  var _feedbackDataService = new FeedbackDataService();
  // Boolean Loading
  bool isLoading = true;
  // Event List
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
      await getTrainerEventsDone();
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
      Image? image = buildRandomImage(imagesEventsNum);
      imagesEvents.add(image);
    }
    if (!indexFound) {
      scrollIndex = todayEvents.length-1;
    }
    _scrollController = ScrollController(initialScrollOffset: MediaQuery.of(context).size.width * scrollIndex);
  }

  // Check If Answered
  Future<void> checkIfAnswered() async {
    this.groupOfQuestions = await _feedbackDataService.getActiveGroupOfQuestions();
    if (groupOfQuestions != null) {
      alreadyAnswered = await _feedbackDataService.checkIfAnswersExist(this.groupOfQuestions!.id);
    } else {
      alreadyAnswered = true;
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

  // Gets the events passed by the trainer.
  Future<void> getTrainerEventsDone() async {
    List<int> res = await _eventDataService.getUserEventsFinished(currentUser.id!);
    totalEvents = res[0];
    thisMonthEvents = res[1];
  }

  // Gets a double and returns a String Duration to be shown
  durationToString(double duration) {
    String temp = "";
    temp = duration.toStringAsFixed(2);
    var hour = temp.split(".")[0];
    var min = temp.split(".")[1];
    return "${hour}h ${min}m ";
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
          child: Icon(
              Icons.feedback,
              color: Theme.of(context).accentColor,
              size: MediaQuery.of(context).size.height*0.04),
        ),
      ],
    );
  }

  // Return bade on events Today
  Widget buildBadge(int index) {
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
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10), textAlign: TextAlign.left),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01,),
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
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10), textAlign: TextAlign.left),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01,),
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
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10), textAlign: TextAlign.left),
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

  Widget build(BuildContext context) {
    return isLoading ?
    Center(
        child: LoadingViewPurple()
    )
        :
    Scaffold (
      appBar: null,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.07,
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.04,),
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
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.4,),
                    IconButton(
                      icon: Icon(Icons.settings, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.04,),
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
                  ],
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height*0.1,
                  width: double.infinity,
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: TextHeadline1(text: currentUser.name!,)),
                      ],
                    ),
                  )
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.26,
                width: double.infinity,
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
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: Center(
                      child: CircularImage(size: MediaQuery.of(context).size.height * 0.25, image: currentUser.imageUrl, color: Theme.of(context).accentColor, borderWidth: 2,),
                    ),
                  ),
                ),
              ),
              Material(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.12)
                  ),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.14,
                  decoration: new BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.12)
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.81,
                          height: MediaQuery.of(context).size.height * 0.11,
                          decoration: new BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
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
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      AppLocalizations.of(context)!.allEvents,
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
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
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      AppLocalizations.of(context)!.monthEvents,
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}

