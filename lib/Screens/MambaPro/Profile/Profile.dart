import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/SharePlus/SharePlusUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TitleHeadline1.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/ImageFullScreen.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/ProfileScreens/Feedback/FeedBack.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/ProfileScreens/Settings/Settings.dart';
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
  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
  // Acceso a Base de Datos
  var _userDataService = UserDataService();
  var _eventDataService = EventDataService();
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  // Event List
  int totalEvents = 0;
  int thisMonthEvents  = 0;
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

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  // Gets the user info from firebase.
  void getUser() async {
    currentUser.setBasicData = await _userDataService.getUserDetails(currentUser.id!);
  }

  // Gets the events passed by the trainer.
  Future<void> getUserEventsFinished() async {
    List<int> res = await _eventDataService.getUserEventsFinished(currentUser.id!);
    totalEvents = res[0];
    thisMonthEvents = res[1];
  }

  // Navigate to Feedback Screen
  void navigateToFeedbackScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => const FeedBack(),
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
        CupertinoPageRoute<Null>(
            builder: (context) => const Settings(),
        )
    ).whenComplete(() {
      setState(() {
        isLoading = true;
        initProfileHome();
      });
    });
  }

  // Navigate to FullScreenImage Screen
  void navigateToFullScreenImage() {
    mixpanel!.timeEvent('user_profile_picture_click');
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
  Widget buildUserTitle() {
    return !isLoading ? Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: TitleHeadline1(text: currentUser.name!,)),
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
  Widget buildUserPicture() {
    return !isLoading ? Center(
      child: GestureDetector(
        onTap: navigateToFullScreenImage,
        child: Container(
          height: safeAreaHeight * 0.25,
          child: Center(
            child: CircularImage(size: safeAreaHeight * 0.25, image: currentUser.imageUrl, color: Theme.of(context).backgroundColor, borderWidth: 2,),
          ),
        ),
      ),
    ) : Center(
      child: Shimmer.fromColors(
          baseColor: AppColors.grey,
          highlightColor: AppColors.grey.withOpacity(0.5),
          child: Container(
            height: safeAreaHeight * 0.25,
            decoration: const BoxDecoration(
              color: AppColors.grey,
              shape: BoxShape.circle,
            ),
          ),
      ),
    );
  }

  // Build the Widget of the Image
  Widget buildUserEventCount() {
    return !isLoading ? Material(
      child: GestureDetector(
        onTap: () {
          /*
          setState(() {
            currentIndex = 2;
          });
          pageController.jumpToPage(currentIndex);
           */
        },
        child: Container(
          width: safeAreaWidth * 0.81,
          height: safeAreaHeight * 0.10,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: safeAreaHeight * 0.10,
                width: safeAreaWidth * 0.38,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      totalEvents.toString(),
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)!.allEvents,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                      textAlign: TextAlign.center,
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
                height: safeAreaHeight * 0.10,
                width: safeAreaWidth * 0.38,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      thisMonthEvents.toString(),
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 2),
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
    ) : Shimmer.fromColors(
      baseColor: AppColors.grey,
      highlightColor: AppColors.grey.withOpacity(0.5),
      child: Container(
        width: safeAreaWidth * 0.70,
        height: safeAreaHeight * 0.08,
        decoration: BoxDecoration(
          color: AppColors.grey,
          borderRadius: BorderRadius.circular(10)
        ),
      )
    );
  }

  // Build Share App Container.
  Widget buildShareAppContainer() {
    return SafeArea(
      left: false,
      right: false,
      child: Container(
        height: safeAreaHeight*0.15,
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
            SizedBox(height: safeAreaHeight*0.015),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.0),
              child: Text(
                  AppLocalizations.of(context)!.shareAppText,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center
              ),
            ),
            SizedBox(height: safeAreaHeight*0.015),
            Container(
              width: safeAreaWidth*0.4,
              child: OutlinedButton(
                onPressed: () {
                  mixpanel!.track('user_profile_share_app');
                  _sharePlusUtils.shareMambaLink(currentUser.firstName!);
                },
                child: Text(
                  AppLocalizations.of(context)!.shareApp,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                style: OutlinedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  fixedSize: Size(safeAreaWidth*0.35, safeAreaHeight*0.06),
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
        height: safeAreaHeight*0.15,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TitleHeadline1(
              text: AppLocalizations.of(context)!.giveFeedbackTitle,
            ),
            SizedBox(height: safeAreaHeight*0.015),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.0),
              child: Text(
                  AppLocalizations.of(context)!.giveFeedbackText,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center
              ),
            ),
            SizedBox(height: safeAreaHeight*0.015),
            Container(
              width: safeAreaWidth*0.4,
              child: OutlinedButton(
                onPressed: () {
                  mixpanel!.track('user_profile_feedback_open');
                  navigateToFeedbackScreen();
                },
                child: Text(
                  AppLocalizations.of(context)!.giveFeedback,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                style: OutlinedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  fixedSize: Size(safeAreaWidth*0.35, safeAreaHeight*0.06),
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
        height: safeAreaHeight*0.15,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TitleHeadline1(
              text: AppLocalizations.of(context)!.getInTouchTitle,
            ),
            SizedBox(height: safeAreaHeight*0.015),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.0),
              child: Text(
                  AppLocalizations.of(context)!.getInTouchText,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center
              ),
            ),
            SizedBox(height: safeAreaHeight*0.015),
            Container(
              width: safeAreaWidth*0.4,
              child: OutlinedButton(
                onPressed: () => launchEmail(),
                child: Text(
                  AppLocalizations.of(context)!.getInTouch,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                style: OutlinedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  fixedSize: Size(safeAreaWidth*0.35, safeAreaHeight*0.06),
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
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }
    return Scaffold (
      appBar: AppBar(
        title: Text(currentUser.name!, style: Theme.of(context).appBarTheme.titleTextStyle,),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        right: false,
        left: false,
        bottom: false,
        child: Column(
          children: [
            Container(
              height: safeAreaHeight*0.08,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: safeAreaHeight*0.04,),
                    alignment: Alignment.center,
                    onPressed: navigateToFeedbackScreen,
                  ),
                  SizedBox(width: safeAreaWidth*0.4,),
                  IconButton(
                    icon: Icon(Icons.settings, color: Theme.of(context).primaryColor, size: safeAreaHeight*0.04,),
                    onPressed: navigateToSettingsScreen,
                  ),
                ],
              ),
            ),
            /*
            Container(
              height: safeAreaHeight*0.06,
              width: double.infinity,
              child: buildUserTitle(),
            ),

             */
            Container(
              height: safeAreaHeight*0.30,
              width: double.infinity,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: buildUserPicture(),
            ),
            Container(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: safeAreaHeight * 0.15,
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                  Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(safeAreaWidth, safeAreaHeight * 0.10)
                      ),
                    ),
                    child: Container(
                      height: safeAreaHeight * 0.13,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.elliptical(safeAreaWidth, safeAreaHeight * 0.10)
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.1),
                            offset: const Offset(0, 9),
                            blurRadius: 5.0,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildUserEventCount(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: safeAreaWidth,
                color: Theme.of(context).backgroundColor,
                child: !isLoading ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: CarouselSlider(
                          items: buildProfileCarousel,
                          carouselController: _controller,
                          options: CarouselOptions(
                            autoPlay: false,
                            initialPage: _current,
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
                        height: safeAreaHeight*0.06,
                        padding: EdgeInsets.only(bottom: 16),
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
                    ]
                ) : Column(
                  children: [
                    Expanded(
                      child: Container(
                        height: safeAreaHeight*0.15,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor
                        ),
                        child: Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: safeAreaHeight*0.04,
                                width: safeAreaWidth*0.3,
                                decoration: BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                              ),
                              SizedBox(height: safeAreaHeight*0.015),
                              Container(
                                height: safeAreaHeight*0.03,
                                width: safeAreaWidth*0.5,
                                decoration: BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                              ),
                              SizedBox(height: safeAreaHeight*0.015),
                              OutlinedButton(
                                onPressed: null,
                                child: Container(),
                                style: OutlinedButton.styleFrom(
                                  elevation: 4,
                                  backgroundColor: AppColors.grey,
                                  fixedSize: Size(safeAreaWidth*0.35, safeAreaHeight*0.06),
                                  side: const BorderSide(width: 1.0, color: AppColors.grey),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: safeAreaHeight*0.04,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(_current == 0 ? 0.9 : 0.4)
                            ),
                          ),
                          Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(_current == 1 ? 0.9 : 0.4)
                            ),
                          ),
                          Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(_current == 1 ? 0.9 : 0.4)
                            ),
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
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}

