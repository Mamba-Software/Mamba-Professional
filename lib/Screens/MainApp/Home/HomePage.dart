import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Notifications/Notifications.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'Chat/Chat.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'Marca/Marca.dart';
import 'Perfil/Perfil.dart';

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
  int _currentIndex = 0;
  // Page Controller
  final PreloadPageController _pageController = PreloadPageController(initialPage: 0);

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
    return Scaffold(
      appBar: null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        iconSize: 32,
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
            icon: Icon(Icons.notifications_rounded),
            label: AppLocalizations.of(context)!.notificationsBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: AppLocalizations.of(context)!.chatBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
        onTap: (index) {
          _onTappedBar(index);
        },
        selectedItemColor: Theme.of(context).accentColor,
        selectedLabelStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color:Theme.of(context).accentColor, fontSize: 13),
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).accentColor
        ),
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.grey, fontSize: 13),
        unselectedIconTheme: IconThemeData(
            color: Colors.grey
        ),
      ),
      body: PreloadPageView.builder(
        physics: NeverScrollableScrollPhysics(),
        preloadPagesCount: 4,
        itemBuilder: (BuildContext context, int position) {
          if (position == 1) {
            return Marca();
          } else if (position == 2) {
            return Notifications();
          } else if (position == 3) {
            return UserChat();
          } else {
            return Perfil();
          }
        },
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentIndex = page;
          });
        },
      ),
      /*
      PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        allowImplicitScrolling: true,
        children: <Widget>[
          Perfil(),
          Marca(),
          Notifications(),
          Chat(),
        ],
        onPageChanged: (page) {
          setState(() {
            _currentIndex = page;
          });
        },
      ),
       */
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _currentIndex = value;
    });
    _pageController.jumpToPage(value);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

