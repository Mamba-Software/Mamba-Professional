import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TitleHeadline1.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/ImageFullScreen.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Profile/ProfileScreens/Settings/Settings.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Profile/ProfileScreens/Feedback/FeedBack.dart';
import 'package:page_transition/page_transition.dart';

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
  var _userDataService = new UserDataService();
  var _eventDataService = new EventDataService();
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

  @override
  void initState() {
    super.initState();
    isLoading = true;
    initProfileHome();
  }

  // Init for Brand Home
  initProfileHome() async {
    getUser();
    await getUserEventsFinished();
    buildProfileCarousel = [buildShareAppContainer(), buildShareAppContainer()];
    if (mounted) {
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
  }

  // Navigate to Settings Screen
  void navigateToSettingsScreen() {
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
  }

  // Navigate to FullScreenImage Screen
  void navigateToFullScreenImage() {
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
  }

  // Build Share App Container.
  Widget buildShareAppContainer() {
    return Container(
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
            padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.05),
            child: Text(
              AppLocalizations.of(context)!.shareAppText,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center
            ),
          ),
          SizedBox(height: safeAreaHeight*0.015),
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
              fixedSize: Size(safeAreaWidth*0.35, safeAreaHeight*0.06),
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
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }
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
        right: false,
        left: false,
        child: Column(
          children: [
            Container(
              height: safeAreaHeight*0.07,
              width: double.infinity,
              child: Row(
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
            Container(
              height: safeAreaHeight*0.06,
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(child: TitleHeadline1(text: currentUser.name!,)),
                ],
              ),
            ),
            Container(
              height: safeAreaHeight*0.30,
              width: double.infinity,
              child: Center(
                child: GestureDetector(
                  onTap: navigateToFullScreenImage,
                  child: Container(
                    height: safeAreaHeight * 0.25,
                    child: Center(
                      child: CircularImage(size: safeAreaHeight * 0.25, image: currentUser.imageUrl, color: Theme.of(context).backgroundColor, borderWidth: 2,),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: safeAreaHeight * 0.15,
                    decoration: new BoxDecoration(
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
                      decoration: new BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.elliptical(safeAreaWidth, safeAreaHeight * 0.10)
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.1),
                            offset: Offset(0, 9),
                            blurRadius: 5.0,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material (
                            child: Container(
                              width: safeAreaWidth * 0.81,
                              height: safeAreaHeight * 0.10,
                              decoration: new BoxDecoration(
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
            Expanded(
              child: Container(
                color: Theme.of(context).backgroundColor,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
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
                        height: safeAreaHeight*0.04,
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

