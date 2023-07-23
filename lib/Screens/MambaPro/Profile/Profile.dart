import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/SharePlus/SharePlusUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TitleHeadline1.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/ImageFullScreen.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Stats/SessionsMade.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/ProfileScreens/Feedback/FeedBack.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/ProfileScreens/Settings/Settings.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/ProfileScreens/Settings/SettingsYourData.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Profile Page
class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _eventDataService = EventDataService();
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  bool isYearly = false;
  // DateJoined
  DateTime dateJoined = DateTime.now();
  // User Event Stats
  List<Event> totalEvents = [];
  double averageTime = 0;
  double totalTime = 0;
  // Carousel
  int _current = 0;
  final CarouselController _controller = CarouselController();
  List<Widget> buildProfileCarousel = [];
  //Share Plus Utils
  final SharePlusUtils _sharePlusUtils = SharePlusUtils();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    initProfileHome();
    mixpanel!.track('user_profile_view');
  }

  // Init for Brand 000-Home
  initProfileHome() async {
    getUser();
    await getUserEventsFinished();
    buildProfileCarousel = [buildShareAppContainer(), buildAnswerFeedbackContainer(), buildContactUsContainer()];
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  // Gets the user info from firebase.
  void getUser() async {
    currentUser.setBasicData = await _userDataService.getUserDetails(currentUser.id!);
    dateJoined = DateFormat('dd-MM-yyyy').parse(currentUser.dateJoined!);
  }

  // Gets the events passed by the trainer.
  Future<void> getUserEventsFinished() async {
    List res = await _eventDataService.getUserEventsStats(currentUser.id!);
    totalEvents = res[0];
    totalTime = res[1];
    averageTime = res[2]*60;
  }


  // Navigate to Feedback Screen
  void navigateToFeedbackScreen() {
    Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.bottomToTop,
          child: const FeedBack(),
        )
    ).whenComplete(() {
      setState(() {
        isLoading = true;
        initProfileHome();
      });
    });
  }

  // Navigate to Settings Screen
  void navigateToSettingsScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<double?>(
          builder: (context) => const Settings(),
        )
    ).whenComplete(() {
      setState(() {
        initProfileHome();
      });
    });
  }

  // Navigate to Your Data Screen
  void navigateToYourDataScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<String>(
          builder: (context) => const SettingsYourData(),
        )
    ).whenComplete(() {
      setState(() {
        initProfileHome();
      });
    });
  }

  // Navigate to FullScreenImage Screen
  void navigateToFullScreenImage() {
    mixpanel!.timeEvent('user_profile_picture_click');
    Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => FullScreenPage(
          child:  Image.network(
            currentUser.imageUrl!,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
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
    mixpanel!.track('user_profile_picture_click');
  }

  // Build the Widget of the User Name
  Widget buildTopCurvedContainer() {
    return Stack(
      children: [
        ClipPath(
          clipper: CurveClipper(),
          child: Material(
            child: Container(
              color: AppColors.lightGrey,
              height: MediaQuery.of(context).size.height*0.13,
            ),
          ),
        ),
        ClipPath(
          clipper: CurveClipper(),
          child: Material(
            child: Container(
              color: AppColors.black.withOpacity(0.5),
              height: MediaQuery.of(context).size.height*0.04,
            ),
          ),
        ),
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            color: AppColors.black.withOpacity(0.4),
            height: MediaQuery.of(context).size.height*0.07,
          ),
        ),
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            color: AppColors.black.withOpacity(0.5),
            height: MediaQuery.of(context).size.height*0.10,
          ),
        ),
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            color: AppColors.black.withOpacity(0.7),
            height: MediaQuery.of(context).size.height*0.13+0.2,
          ),
        ),
      ],
    );
  }

  // Build the Widget of the User Name
  Widget buildUserTitle() {
    return !isLoading ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
            currentUser.name!,
            style: Theme.of(context).textTheme.headline1?.copyWith(fontSize: 25),
            textAlign: TextAlign.center
        ),
        const SizedBox(height: 6),
        Text(
            AppLocalizations.of(context)!.joinedIn(DateTimeUtils().formatDateTimeToStringMMYYYY(dateJoined, Localizations.localeOf(context).languageCode)),
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.center
        )
      ],
    ) : Shimmer.fromColors(
        baseColor: AppColors.grey.withOpacity(0.8),
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.04,
              width: MediaQuery.of(context).size.width*0.5,
              decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10)
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: MediaQuery.of(context).size.width*0.04,
              width: MediaQuery.of(context).size.width*0.15,
              decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(5)
              ),
            ),
          ],
        )
    );
  }

  // Build the Widget of the Image
  Widget buildUserPicture() {
    return !isLoading ? Center(
      child: GestureDetector(
        onTap: navigateToFullScreenImage,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.13,
          child: CircularImage(size: MediaQuery.of(context).size.height * 0.13, image: currentUser.imageUrl, color: AppColors.lightGrey, borderWidth: 1,),
        ),
      ),
    ) : Center(
      child: Shimmer.fromColors(
        baseColor: AppColors.grey.withOpacity(0.8),
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.13,
          decoration: const BoxDecoration(
            color: AppColors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // Build the Widget of the Image
  Widget buildUserStatsEvent() {
    return !isLoading ? Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.stats,
            style: Theme.of(context).textTheme.headline3,
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.01),
          SizedBox(
            height: MediaQuery.of(context).size.height*0.065,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                    FontAwesomeIcons.hourglassHalf,
                    size: MediaQuery.of(context).size.width*0.09,
                    color: Colors.blue
                ),
                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                SizedBox(
                  height: MediaQuery.of(context).size.width*0.15,
                  width: MediaQuery.of(context).size.width*0.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      averageTime < 90 ? Text(
                        averageTime.toStringAsFixed(0)+" "+AppLocalizations.of(context)!.minutesString.toLowerCase()+"/"+AppLocalizations.of(context)!.week.toLowerCase(),
                        style: Theme.of(context).textTheme.headline3,
                      ) : Text(
                        (averageTime/60).toStringAsFixed(1)+" "+AppLocalizations.of(context)!.hoursString.toLowerCase()+"/"+AppLocalizations.of(context)!.week.toLowerCase(),
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser.isTrainer! ? AppLocalizations.of(context)!.averageTimeWorked : AppLocalizations.of(context)!.averageTimeTrained,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height*0.065,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                    Icons.timer_outlined,
                    size: MediaQuery.of(context).size.width*0.09,
                    color: AppColors.red
                ),
                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                SizedBox(
                  height: MediaQuery.of(context).size.width*0.15,
                  width: MediaQuery.of(context).size.width*0.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        totalTime.toStringAsFixed(0)+" "+AppLocalizations.of(context)!.hoursString.toLowerCase(),
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser.isTrainer! ? AppLocalizations.of(context)!.totalTimeWorked : AppLocalizations.of(context)!.totalTimeTrained,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height*0.065,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                    FontAwesomeIcons.squareCheck,
                    size: MediaQuery.of(context).size.width*0.09,
                    color: Colors.green
                ),
                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                SizedBox(
                  height: MediaQuery.of(context).size.width*0.15,
                  width: MediaQuery.of(context).size.width*0.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        totalEvents.length.toString()+" "+AppLocalizations.of(context)!.sessions.toLowerCase(),
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.sesionsCompleted,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ) : Shimmer.fromColors(
        baseColor: AppColors.grey.withOpacity(0.8),
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.stats,
                style: Theme.of(context).textTheme.headline3,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.065,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                        FontAwesomeIcons.hourglassHalf,
                        size: MediaQuery.of(context).size.width*0.09,
                        color: Colors.blue
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.02),
                    SizedBox(
                      height: MediaQuery.of(context).size.width*0.15,
                      width: MediaQuery.of(context).size.width*0.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.width*0.04,
                            width: MediaQuery.of(context).size.width*0.25,
                            decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(5)
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.averageTimeTrained,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.065,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                        Icons.timer_outlined,
                        size: MediaQuery.of(context).size.width*0.09,
                        color: AppColors.red
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.02),
                    SizedBox(
                      height: MediaQuery.of(context).size.width*0.15,
                      width: MediaQuery.of(context).size.width*0.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.width*0.04,
                            width: MediaQuery.of(context).size.width*0.2,
                            decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(5)
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.totalTimeTrained,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.065,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                        FontAwesomeIcons.squareCheck,
                        size: MediaQuery.of(context).size.width*0.09,
                        color: Colors.green
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.02),
                    SizedBox(
                      height: MediaQuery.of(context).size.width*0.15,
                      width: MediaQuery.of(context).size.width*0.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.width*0.04,
                            width: MediaQuery.of(context).size.width*0.22,
                            decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(5)
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.sesionsCompleted,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }

  // Build the Widget of the Image
  Widget buildUserProgressWidget() {
    if (!isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentUser.isTrainer! ? AppLocalizations.of(context)!.sesionsCompleted : StringUtils().toCapitalized(AppLocalizations.of(context)!.myProgress.split(" ")[1]),
              style: Theme.of(context).textTheme.headline3,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.02),
            SizedBox(
                height: MediaQuery.of(context).size.height*0.05,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isYearly = false;
                        });
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(4),
                          backgroundColor: MaterialStateProperty.all(Theme.of(context).backgroundColor),
                          animationDuration: const Duration(milliseconds: 100),
                          overlayColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.1)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              )
                          )
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 10.0,
                            width: 10.0,
                            decoration: BoxDecoration(
                                color: isYearly ? Theme.of(context).primaryColor.withOpacity(0.2) : Theme.of(context).primaryColor,
                                shape: BoxShape.circle
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.lastNMonths(6.toString()),
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isYearly = true;
                        });
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(4),
                          backgroundColor: MaterialStateProperty.all(Theme.of(context).backgroundColor),
                          animationDuration: const Duration(milliseconds: 100),
                          overlayColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.1)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              )
                          )
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 10.0,
                            width: 10.0,
                            decoration: BoxDecoration(
                                color: isYearly == false ? Theme.of(context).primaryColor.withOpacity(0.2) : Theme.of(context).primaryColor,
                                shape: BoxShape.circle
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.lastYear,
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.03),
            SessionsMade(
              events: totalEvents.length > 5 ? totalEvents : [],
              backEvents: totalEvents,
              isYearly: isYearly,
            ),
          ],
        ),
      );
    } else {
      return Shimmer.fromColors(
        baseColor: AppColors.grey.withOpacity(0.8),
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.myProgress,
                style: Theme.of(context).textTheme.headline3,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.02),
              SizedBox(
                  height: MediaQuery.of(context).size.height*0.05,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isYearly = false;
                          });
                        },
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(4),
                            backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                            animationDuration: const Duration(milliseconds: 100),
                            overlayColor: MaterialStateProperty.all(Theme.of(context).backgroundColor.withOpacity(0.2)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )
                            )
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 10.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                  color: isYearly ? Theme.of(context).primaryColorDark.withOpacity(0.2) : Theme.of(context).primaryColorDark,
                                  shape: BoxShape.circle
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.lastNMonths(6.toString()),
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isYearly = true;
                          });
                        },
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(4),
                            backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                            animationDuration: const Duration(milliseconds: 100),
                            overlayColor: MaterialStateProperty.all(Theme.of(context).backgroundColor.withOpacity(0.2)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )
                            )
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 10.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                  color: isYearly == false ? Theme.of(context).primaryColorDark.withOpacity(0.2) : Theme.of(context).primaryColorDark,
                                  shape: BoxShape.circle
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.lastYear,
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height*0.25,
                    width: MediaQuery.of(context).size.width*0.85,
                    decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  // Build the Widget of the Image
  Widget buildContainersWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: navigateToYourDataScreen,
          child: Material(
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            child: Container(
              height: MediaQuery.of(context).size.height*0.07,
              width: MediaQuery.of(context).size.width*0.9,
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
              decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(30)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                      FontAwesomeIcons.person,
                      size: MediaQuery.of(context).size.width*0.06,
                      color: Theme.of(context).primaryColor
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.05),
                  Text(
                    AppLocalizations.of(context)!.myData,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build Share App Container.
  Widget buildShareAppContainer() {
    return SafeArea(
      left: false,
      right: false,
      child: Container(
        height: MediaQuery.of(context).size.height*0.06,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TitleHeadline1(
              text: AppLocalizations.of(context)!.shareAppTitle,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.015),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.0),
              child: Text(
                  AppLocalizations.of(context)!.shareAppText,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.015),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.4,
              child: OutlinedButton(
                onPressed: () {
                  mixpanel!.track('user_profile_share_app');
                  _sharePlusUtils.shareMambaLink(currentUser.firstName!);
                },
                child: Text(
                  AppLocalizations.of(context)!.shareApp,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                style: OutlinedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: Theme.of(context).backgroundColor,
                  fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                  side: BorderSide(width: 1.0, color: Theme.of(context).scaffoldBackgroundColor),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ],

        ),
      ),
    );
  }

  // Build Share App Container.
  Widget buildAnswerFeedbackContainer() {
    return SafeArea(
      left: false,
      right: false,
      child: Container(
        height: MediaQuery.of(context).size.height*0.06,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TitleHeadline1(
              text: AppLocalizations.of(context)!.giveFeedbackTitle,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.015),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.0),
              child: Text(
                  AppLocalizations.of(context)!.giveFeedbackText,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.015),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.4,
              child: OutlinedButton(
                onPressed: () {
                  mixpanel!.track('user_profile_feedback_open');
                  navigateToFeedbackScreen();
                },
                child: Text(
                  AppLocalizations.of(context)!.giveFeedback,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                style: OutlinedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: Theme.of(context).backgroundColor,
                  fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                  side: BorderSide(width: 1.0, color: Theme.of(context).scaffoldBackgroundColor),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ],

        ),
      ),
    );
  }

  // Build Share App Container.
  Widget buildContactUsContainer() {
    return SafeArea(
      left: false,
      right: false,
      child: Container(
        height: MediaQuery.of(context).size.height*0.06,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TitleHeadline1(
              text: AppLocalizations.of(context)!.getInTouchTitle,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.015),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.0),
              child: Text(
                  AppLocalizations.of(context)!.getInTouchText,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.015),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.4,
              child: OutlinedButton(
                onPressed: () => launchEmail(),
                child: Text(
                  AppLocalizations.of(context)!.getInTouch,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                style: OutlinedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: Theme.of(context).backgroundColor,
                  fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                  side: BorderSide(width: 1.0, color: Theme.of(context).scaffoldBackgroundColor),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ],

        ),
      ),
    );
  }

  Future<void> launchEmail() async {
    mixpanel!.track('user_profile_email_mamba');
    const url = 'mailto:mambastylecastelldefels@gmail.com';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: AppColors.black,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                buildTopCurvedContainer(),
                Container(
                  height: MediaQuery.of(context).size.height*0.08,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.width*0.12,
                        width: MediaQuery.of(context).size.width*0.12,
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          elevation: 4,
                          color: AppColors.white,
                          textColor: AppColors.black,
                          child: Icon(Icons.arrow_back, color: AppColors.black, size: MediaQuery.of(context).size.height*0.035,),
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder(),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width*0.12,
                        width: MediaQuery.of(context).size.width*0.12,
                        child: MaterialButton(
                          onPressed: navigateToSettingsScreen,
                          elevation: 4,
                          color: AppColors.white,
                          textColor: AppColors.black,
                          child: Icon(Icons.settings_outlined, color: AppColors.black, size: MediaQuery.of(context).size.height*0.035,),
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height*0.26,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      buildUserPicture(),
                      const SizedBox(height: 12),
                      buildUserTitle(),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.04),
            buildUserStatsEvent(),
            SizedBox(height: MediaQuery.of(context).size.height*0.03),
            buildUserProgressWidget(),
            SizedBox(height: MediaQuery.of(context).size.height*0.05),
            buildContainersWidget(),
            SizedBox(height: MediaQuery.of(context).size.height*0.008),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  items: buildProfileCarousel,
                  carouselController: _controller,
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height*0.3,
                    autoPlay: false,
                    initialPage: _current,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                ),
                Positioned(
                  bottom: Platform.isAndroid ? MediaQuery.of(context).size.height*0.02 : MediaQuery.of(context).size.height*0.06,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildProfileCarousel.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _controller.animateToPage(entry.key),
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(_current == entry.key ? 0.9 : 0.4)
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
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


class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    int curveHeight = 30;
    Offset controlPoint = Offset(size.width / 2, size.height + curveHeight);
    Offset endPoint = Offset(size.width, size.height - curveHeight);

    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

