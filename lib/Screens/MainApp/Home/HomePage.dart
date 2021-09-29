import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'ChildWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

// HomePage for the App. Here the user can change between the diferent pages.
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // Index of Bottom Navigation Bar
  int _currentIndex = 1;
  // Page Controller
  PageController _pageController = PageController(
    initialPage: 1,
  );
  // Child widget for the Page controller.
  Widget childWidget = ChildWidget(
    number: AvailableNumber.Second,
  );

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getUserAndBrand();
    // Faltaria ficar aqui totes les altres inicialitzacions...
  }
  // Gets the user info from firebase.
  void getUserAndBrand() async {
    currentUser = await _accessDatabase.getCurrentUserDetails();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Icon(Icons.person, color: Styles.white, size: 33,),
      Icon(Icons.fitness_center_rounded, color: Styles.white, size: 33,),
      Icon(Icons.chat, color: Styles.white, size: 33,),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value:SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, //i like transaparent :-)
          systemNavigationBarColor: Colors.black, // navigation bar color
          statusBarIconBrightness: Brightness.light, // status bar icons' color
          systemNavigationBarIconBrightness:Brightness.light, //navigation bar icons' color
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Image.asset(
              Constants.logoExtended,
              fit: BoxFit.contain,
              height: 32,
            ),
            centerTitle: true,
            elevation: 10,
            automaticallyImplyLeading: false,
          ),
          backgroundColor: Styles.white,
          extendBody: true,
          bottomNavigationBar: CurvedNavigationBar(
            index: _currentIndex,
            color: Styles.mainColor,
            backgroundColor: Colors.transparent,
            animationCurve: Curves.easeInOut,
            animationDuration: Duration(milliseconds: 200),
            height: 60,
            items: items,
            onTap: (index) {
              _currentIndex = index;
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 200),
                curve: Curves.linear,
              );
              setState(() {});
            },
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentIndex = page;
              });
            },
            children: <Widget>[
              ChildWidget(number: AvailableNumber.First),
              ChildWidget(number: AvailableNumber.Second),
              ChildWidget(number: AvailableNumber.Third),
            ],
          ),
        )
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/*
items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Styles.white,),
                label: AppLocalizations.of(context)!.profileBottomNav,
                backgroundColor: Styles.mainColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_rounded, color: Styles.white,),
                label: AppLocalizations.of(context)!.brandBottomNav,
                backgroundColor: Styles.mainColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat, color: Styles.white,),
                label: AppLocalizations.of(context)!.chatBottomNav,
                backgroundColor: Styles.mainColor,
              ),
            ],

            selectedItemColor: Styles.white,
            selectedLabelStyle: Styles.whiteTextStyle.copyWith(fontSize: 15),
            unselectedItemColor: Styles.white,
            unselectedLabelStyle: Styles.whiteTextStyle.copyWith(fontSize: 15),
 */

