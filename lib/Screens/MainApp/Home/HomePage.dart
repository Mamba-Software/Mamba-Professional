import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'ChildWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    Widget returnTitle (int currentIndex) {
      if (_currentIndex == 0) {
        return Text(AppLocalizations.of(context)!.profileBottomNav, style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor , fontWeight: FontWeight.bold));
      } else if (_currentIndex == 2) {
        return Text(AppLocalizations.of(context)!.chatBottomNav, style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor , fontWeight: FontWeight.bold));
      } else {
        return Image.asset(
          Constants.logoSimplePurple,
          fit: BoxFit.contain,
          height: 30,
        );
      }
    }

    final items = <Widget>[
      Icon(Icons.person, color: Styles.white, size: 33,),
      Icon(Icons.fitness_center_rounded, color: Styles.white, size: 33,),
      Icon(Icons.chat, color: Styles.white, size: 33,),
    ];
    return Scaffold(
      appBar: null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        iconSize: 30,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppLocalizations.of(context)!.profileBottomNav,
            //backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: AppLocalizations.of(context)!.brandBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: AppLocalizations.of(context)!.chatBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
        onTap: (index) {
          _currentIndex = index;
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.linear,
          );
          setState(() {});
        },
        selectedItemColor: Theme.of(context).accentColor,
        selectedLabelStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color:Theme.of(context).accentColor),
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).accentColor
        ),
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.grey),
        unselectedIconTheme: IconThemeData(
            color: Colors.grey
        ),
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
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/*
AppBar(
        title: returnTitle(_currentIndex),
        centerTitle: true,
        shadowColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
      ),


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

