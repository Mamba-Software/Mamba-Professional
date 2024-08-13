import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/app/router/custom_transitions.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba/commons/utils/SharePlus/SharePlusUtils.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/Components/Images/ImageFullScreen.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Stats/SessionsMade.dart';
import 'package:mamba/home/widgets/responsive_menu.dart';
import 'package:mamba/user/mixin/user.dart';
import 'package:mamba/user/profile/views/Feedback/Help.dart';
import 'package:mamba/user/profile/views/settings/Settings.dart';
import 'package:mamba/user/profile/views/settings/SettingsYourData.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Profile Page
class ProfileWidget extends StatefulWidget {
  static String routeName = 'profile';
  final Usuario user;

  const ProfileWidget({super.key, required this.user});

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget>
    with PlatformMixin, UserBlocMixin {
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

  Usuario user = Usuario();

  @override
  void initState() {
    user = widget.user;
    dateJoined = DateFormat('dd-MM-yyyy').parse(user.dateJoined!);
    super.initState();
    //isLoading = true;
    initProfileHome();
    mixpanel!.track('user_profile_view');
  }

  // Init for Brand 000-Home
  initProfileHome() async {
    //getUser();
    getUserEventsFinished();
    buildProfileCarousel = [
      buildShareAppContainer(),
      buildAnswerFeedbackContainer(),
      buildContactUsContainer()
    ];
    /*
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          isLoading = false;
        });
      });
    }*/
  }

  // Gets the user info from firebase.
  void getUser() async {
    myUser(context).setBasicData =
        await _userDataService.getUserDetails(myUser(context).id!);
    dateJoined = DateFormat('dd-MM-yyyy').parse(myUser(context).dateJoined!);
  }

  // Gets the events passed by the trainer.
  void getUserEventsFinished() {
    //List res = await _eventDataService.getUserEventsStats(myUser(context).id!);
    totalEvents = user.eventStats[0];
    totalTime = user.eventStats[1];
    averageTime = user.eventStats[2] * 60;
  }

  // Navigate to Feedback Screen
  void navigateToFeedbackScreen() {
    Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.bottomToTop,
          child: const FeedBack(),
        )).whenComplete(() {
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
        )).whenComplete(() {
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
          builder: (context) => SettingsYourData(),
        )).whenComplete(() {
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
                  dark: false,
                  child: Image.network(
                    myUser(context).imageUrl!,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: context.colorScheme.secondary,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                )));
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
              height: MediaQuery.of(context).size.height * 0.13,
            ),
          ),
        ),
        ClipPath(
          clipper: CurveClipper(),
          child: Material(
            child: Container(
              color: AppColors.black.withOpacity(0.5),
              height: MediaQuery.of(context).size.height * 0.04,
            ),
          ),
        ),
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            color: AppColors.black.withOpacity(0.4),
            height: MediaQuery.of(context).size.height * 0.07,
          ),
        ),
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            color: AppColors.black.withOpacity(0.5),
            height: MediaQuery.of(context).size.height * 0.10,
          ),
        ),
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            color: AppColors.black.withOpacity(0.7),
            height: MediaQuery.of(context).size.height * 0.13 + 0.2,
          ),
        ),
      ],
    );
  }

  // Build the Widget of the User Name
  Widget buildUserTitle() {
    return !isLoading
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(myUser(context).name!,
                  style: context.textTheme.headlineLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                  context.l10n.joinedIn(DateTimeUtils()
                      .formatDateTimeToStringMMYYYY(dateJoined,
                          Localizations.localeOf(context).languageCode)),
                  style: context.textTheme.bodyMedium,
                  textAlign: TextAlign.center)
            ],
          )
        : Shimmer.fromColors(
            baseColor: AppColors.grey.withOpacity(0.8),
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.04,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 6),
                Container(
                  height: MediaQuery.of(context).size.width * 0.04,
                  width: MediaQuery.of(context).size.width * 0.15,
                  decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(5)),
                ),
              ],
            ));
  }

  // Build the Widget of the Image
  Widget buildUserPicture() {
    return !isLoading
        ? Center(
            child: GestureDetector(
              onTap: navigateToFullScreenImage,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.13,
                child: CircularImage(
                  size: MediaQuery.of(context).size.height * 0.13,
                  image: myUser(context).imageUrl,
                  color: AppColors.lightGrey,
                  borderWidth: 1,
                ),
              ),
            ),
          )
        : Center(
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
    return !isLoading
        ? Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.stats,
                  style: context.textTheme.headlineMedium,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.065,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.hourglassHalf,
                          size: MediaQuery.of(context).size.width * 0.09,
                          color: Colors.blue),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.15,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            averageTime < 90
                                ? Text(
                                    "${averageTime.toStringAsFixed(0)} ${context.l10n.minutesString.toLowerCase()}/${context.l10n.week.toLowerCase()}",
                                    style: context.textTheme.titleLarge,
                                  )
                                : Text(
                                    "${(averageTime / 60).toStringAsFixed(1)} ${context.l10n.hoursString.toLowerCase()}/${context.l10n.week.toLowerCase()}",
                                    style: context.textTheme.titleLarge,
                                  ),
                            const SizedBox(height: 4),
                            Text(
                              myUser(context).isTrainer!
                                  ? context.l10n.averageTimeWorked
                                  : context.l10n.averageTimeTrained,
                              style: context.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.065,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_outlined,
                          size: MediaQuery.of(context).size.width * 0.09,
                          color: AppColors.red),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.15,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${totalTime.toStringAsFixed(0)} ${context.l10n.hoursString.toLowerCase()}",
                              style: context.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              myUser(context).isTrainer!
                                  ? context.l10n.totalTimeWorked
                                  : context.l10n.totalTimeTrained,
                              style: context.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.065,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.squareCheck,
                          size: MediaQuery.of(context).size.width * 0.09,
                          color: Colors.green),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.15,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${totalEvents.length} ${context.l10n.sessions.toLowerCase()}",
                              style: context.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.sesionsCompleted,
                              style: context.textTheme.bodyMedium,
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
        : Shimmer.fromColors(
            baseColor: AppColors.grey.withOpacity(0.8),
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.stats,
                    style: context.textTheme.headlineMedium,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.065,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.hourglassHalf,
                            size: MediaQuery.of(context).size.width * 0.09,
                            color: Colors.blue),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.15,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.04,
                                width: MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                    color: AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.l10n.averageTimeTrained,
                                style: context.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.065,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.timer_outlined,
                            size: MediaQuery.of(context).size.width * 0.09,
                            color: AppColors.red),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.15,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.04,
                                width: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(
                                    color: AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.l10n.totalTimeTrained,
                                style: context.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.065,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.squareCheck,
                            size: MediaQuery.of(context).size.width * 0.09,
                            color: Colors.green),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.15,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.04,
                                width: MediaQuery.of(context).size.width * 0.22,
                                decoration: BoxDecoration(
                                    color: AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.l10n.sesionsCompleted,
                                style: context.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
  }

  // Build the Widget of the Image
  Widget buildUserProgressWidget() {
    if (!isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              myUser(context).isTrainer!
                  ? context.l10n.sesionsCompleted
                  : StringUtils()
                      .toCapitalized(context.l10n.myProgress.split(" ")[1]),
              style: context.textTheme.headlineMedium,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
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
                          surfaceTintColor: MaterialStateProperty.all(
                              context.colorScheme.background),
                          backgroundColor: MaterialStateProperty.all(
                              context.colorScheme.background),
                          animationDuration: const Duration(milliseconds: 100),
                          overlayColor: MaterialStateProperty.all(
                              context.theme.primaryColor.withOpacity(0.1)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ))),
                      child: Row(
                        children: [
                          Container(
                            height: 10.0,
                            width: 10.0,
                            decoration: BoxDecoration(
                                color: isYearly
                                    ? context.theme.primaryColor
                                        .withOpacity(0.2)
                                    : context.theme.primaryColor,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.lastNMonths(6.toString()),
                            style: context.textTheme.bodyMedium
                                ?.copyWith(color: context.theme.primaryColor),
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
                          surfaceTintColor: MaterialStateProperty.all(
                              context.colorScheme.background),
                          backgroundColor: MaterialStateProperty.all(
                              context.colorScheme.background),
                          animationDuration: const Duration(milliseconds: 100),
                          overlayColor: MaterialStateProperty.all(
                              context.theme.primaryColor.withOpacity(0.1)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ))),
                      child: Row(
                        children: [
                          Container(
                            height: 10.0,
                            width: 10.0,
                            decoration: BoxDecoration(
                                color: isYearly == false
                                    ? context.theme.primaryColor
                                        .withOpacity(0.2)
                                    : context.theme.primaryColor,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.lastYear,
                            style: context.textTheme.bodyMedium
                                ?.copyWith(color: context.theme.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.myProgress,
                style: context.textTheme.headlineMedium,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
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
                            surfaceTintColor: MaterialStateProperty.all(
                                context.theme.primaryColor),
                            backgroundColor: MaterialStateProperty.all(
                                context.theme.primaryColor),
                            animationDuration:
                                const Duration(milliseconds: 100),
                            overlayColor: MaterialStateProperty.all(context
                                .colorScheme.background
                                .withOpacity(0.2)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ))),
                        child: Row(
                          children: [
                            Container(
                              height: 10.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                  color: isYearly
                                      ? context.theme.primaryColorDark
                                          .withOpacity(0.2)
                                      : context.theme.primaryColorDark,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.lastNMonths(6.toString()),
                              style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.theme.primaryColorDark),
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
                            surfaceTintColor: MaterialStateProperty.all(
                                context.theme.primaryColor),
                            backgroundColor: MaterialStateProperty.all(
                                context.theme.primaryColor),
                            animationDuration:
                                const Duration(milliseconds: 100),
                            overlayColor: MaterialStateProperty.all(context
                                .colorScheme.background
                                .withOpacity(0.2)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ))),
                        child: Row(
                          children: [
                            Container(
                              height: 10.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                  color: isYearly == false
                                      ? context.theme.primaryColorDark
                                          .withOpacity(0.2)
                                      : context.theme.primaryColorDark,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.lastYear,
                              style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.theme.primaryColorDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(10)),
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
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              decoration: BoxDecoration(
                  color: context.colorScheme.background,
                  borderRadius: BorderRadius.circular(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.person,
                      size: MediaQuery.of(context).size.width * 0.06,
                      color: context.theme.primaryColor),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  Text(
                    context.l10n.myData,
                    style: context.textTheme.headlineSmall,
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
        height: MediaQuery.of(context).size.height * 0.06,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.shareAppTitle,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.0),
              child: Text(context.l10n.shareAppText,
                  style: context.textTheme.bodyLarge!
                      .copyWith(color: context.theme.primaryColor),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: ElevatedButton(
                onPressed: () {
                  mixpanel!.track('user_profile_share_app');
                  _sharePlusUtils.shareMambaLink(myUser(context).firstName!);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: context.colorScheme.background,
                  surfaceTintColor: context.colorScheme.background,
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.35,
                      MediaQuery.of(context).size.height * 0.06),
                  side: BorderSide(
                      width: 1.0,
                      color: context.colorScheme
                          .background), // This might need adjustment
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                child: Text(
                  context.l10n.shareApp,
                  style: context.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
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
        height: MediaQuery.of(context).size.height * 0.06,
        width: double.infinity,
        decoration: BoxDecoration(color: context.theme.scaffoldBackgroundColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.giveFeedbackTitle,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.0),
              child: Text(context.l10n.giveFeedbackText,
                  style: context.textTheme.bodyLarge!
                      .copyWith(color: context.theme.primaryColor),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: ElevatedButton(
                onPressed: () {
                  mixpanel!.track('user_profile_feedback_open');
                  navigateToFeedbackScreen();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: context.colorScheme.background,
                  surfaceTintColor: context.colorScheme.background,
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.35,
                      MediaQuery.of(context).size.height * 0.06),
                  side: BorderSide(
                      width: 1.0,
                      color: context.colorScheme
                          .background), // This might need adjustment
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                child: Text(
                  context.l10n.giveFeedback,
                  style: context.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
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
        height: MediaQuery.of(context).size.height * 0.06,
        width: double.infinity,
        decoration: BoxDecoration(color: context.theme.scaffoldBackgroundColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.getInTouchTitle,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.0),
              child: Text(context.l10n.getInTouchTextDesc,
                  style: context.textTheme.bodyLarge!
                      .copyWith(color: context.theme.primaryColor),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: ElevatedButton(
                onPressed: () => launchEmail(),
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: context.colorScheme.background,
                  surfaceTintColor: context.colorScheme.background,
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.35,
                      MediaQuery.of(context).size.height * 0.06),
                  side: BorderSide(
                      width: 1.0,
                      color: context.colorScheme
                          .background), // This might need adjustment
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                child: Text(
                  context.l10n.getInTouch,
                  style: context.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
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
    String url = 'mailto:$contactEmail';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveMenu(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: AppColors.black,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              Stack(
                children: [
                  buildTopCurvedContainer(),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.12,
                          width: MediaQuery.of(context).size.width * 0.12,
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            elevation: 4,
                            color: AppColors.white,
                            textColor: AppColors.black,
                            padding: EdgeInsets.zero,
                            shape: const CircleBorder(),
                            child: Icon(
                              Icons.arrow_back,
                              color: AppColors.black,
                              size: MediaQuery.of(context).size.height * 0.035,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.12,
                          width: MediaQuery.of(context).size.width * 0.12,
                          child: MaterialButton(
                            onPressed: navigateToSettingsScreen,
                            elevation: 4,
                            color: AppColors.white,
                            textColor: AppColors.black,
                            padding: EdgeInsets.zero,
                            shape: const CircleBorder(),
                            child: Icon(
                              Icons.settings_outlined,
                              color: AppColors.black,
                              size: MediaQuery.of(context).size.height * 0.035,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.26,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Material(
                            elevation: 4,
                            shape: const CircleBorder(),
                            child: buildUserPicture()),
                        const SizedBox(height: 12),
                        buildUserTitle(),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              buildUserStatsEvent(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              buildUserProgressWidget(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              buildContainersWidget(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.008),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CarouselSlider(
                    items: buildProfileCarousel,
                    carouselController: _controller,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.3,
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
                    bottom: isAndroid
                        ? MediaQuery.of(context).size.height * 0.03
                        : MediaQuery.of(context).size.height * 0.06,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          buildProfileCarousel.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _controller.animateToPage(entry.key),
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    (context.theme.brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black)
                                        .withOpacity(
                                            _current == entry.key ? 0.9 : 0.4)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
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

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    int curveHeight = 30;
    Offset controlPoint = Offset(size.width / 2, size.height + curveHeight);
    Offset endPoint = Offset(size.width, size.height - curveHeight);

    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
