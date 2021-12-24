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
  // Page Controller
  final PageController _pageController = PageController(initialPage: currentIndex);

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
        currentIndex: currentIndex,
        iconSize: MediaQuery.of(context).size.height*0.04,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppLocalizations.of(context)!.profileBottomNav,
            //backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: AppLocalizations.of(context)!.brandBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: unreadNotifications > 0 ? buildCustomBadge(
              counter: unreadNotifications,
              child: Icon(Icons.notifications_rounded),
            ) : Icon(Icons.notifications_rounded),
            label: AppLocalizations.of(context)!.notificationsBottomNav,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: unreadChats > 0 ? buildCustomBadge(
              counter: unreadChats,
              child: Icon(Icons.chat),
            ) : Icon(Icons.chat),
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
        showUnselectedLabels: true,
      ),
      body: PageView(
        //physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        //allowImplicitScrolling: true,
        children: <Widget>[
          Perfil(),
          Marca(),
          Notifications(),
          UserChat(),
        ],
        onPageChanged: (page) async {
          unreadNotifications = await _accessDatabase.numberUnreadNotifications(currentUser.id!);
          unreadChats = await _accessDatabase.numberUnreadConversations(currentUser.id!);
          setState(() {
            currentIndex = page;
          });
        },
      ),
    );
  }

  Future<void> _onTappedBar(int value) async {
    setState(() {
      currentIndex = value;
    });
    _pageController.jumpToPage(value);
  }

  Widget buildCustomBadge({required int counter, required Widget child}) {

    final text = counter.toString();
    final deltaFontSize = (text.length - 1) * 3.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -2,
          right: -15,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).accentColor,
            radius: 10,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12 - deltaFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }



  @override
  void dispose() {
    super.dispose();
  }
}

