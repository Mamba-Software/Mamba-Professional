import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TitleHeadline1.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TitleHeadline3.dart';
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
import 'package:store_redirect/store_redirect.dart';

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

  // Carousel
  int _current = 0;
  final CarouselController _controller = CarouselController();
  List<Widget> buildProfileCarousel = [];


  @override
  void initState() {
    super.initState();
    isLoading = true;
    initProfileHome();
  }

  // Init for Brand Home
  initProfileHome() async {
    getUser();
    await getTrainerEventsDone();
    buildProfileCarousel = [buildShareAppContainer(), buildShareAppContainer()];
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

  // Gets the events passed by the trainer.
  Future<void> getTrainerEventsDone() async {
    List<int> res = await _eventDataService.getUserEventsFinished(currentUser.id!);
    totalEvents = res[0];
    thisMonthEvents = res[1];
  }

  // Build Share App Container.
  Widget buildShareAppContainer() {
    return Container(
      height: MediaQuery.of(context).size.height*0.15,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleHeadline1(
            text: AppLocalizations.of(context)!.shareAppTitle,
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.015),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
            child: Text(
              AppLocalizations.of(context)!.shareAppText,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.015),
          OutlinedButton(
            onPressed: () {

            },
            child: Text(
              AppLocalizations.of(context)!.shareApp,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            style: OutlinedButton.styleFrom(
              elevation: 4,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
              side: BorderSide(width: 1.0, color: Theme.of(context).scaffoldBackgroundColor),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
              ),
            ),
          ),
        ],

      ),
    );
  }

  Widget build(BuildContext context) {
    return isLoading ?
    Center(
        child: LoadingViewPurple()
    )
        :
    Scaffold (
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.40,
              width: double.infinity,
              color: Theme.of(context).backgroundColor,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height*0.30,
                      width: MediaQuery.of(context).size.width,
                      child: CarouselSlider(
                        items: buildProfileCarousel,
                        carouselController: _controller,
                        options: CarouselOptions(
                            autoPlay: false,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _current = index;
                              });
                            }
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height*0.04,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: buildProfileCarousel.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () => _controller.animateToPage(entry.key),
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(_current == entry.key ? 0.9 : 0.4)
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ]
              ),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height*0.05,
                    width: double.infinity,
                    child: Row(
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
                    height: MediaQuery.of(context).size.height*0.06,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(child: TitleHeadline1(text: currentUser.name!,)),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height*0.30,
                    width: double.infinity,
                    child: Center(
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
                            child: CircularImage(size: MediaQuery.of(context).size.height * 0.25, image: currentUser.imageUrl, color: Theme.of(context).backgroundColor, borderWidth: 2,),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.elliptical(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.10)
                        ),
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.13,
                        decoration: new BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.elliptical(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.10)
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                              offset: Offset(0, 6.0),
                              blurRadius: 5.0,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material (
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.81,
                                height: MediaQuery.of(context).size.height * 0.10,
                                decoration: new BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
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
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height*0.29,
                      width: double.infinity,
                      child: Center()
                  ),
                  // 57%
                ],
              ),
            ),
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

