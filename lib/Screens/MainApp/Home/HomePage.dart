// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';

import 'ChildWidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Index of Bottom Navigation Bar
  int _currentIndex = 0;
  // Page Controller
  PageController _pageController = PageController(
    initialPage: 0,
  );
  Widget childWidget = ChildWidget(
    number: AvailableNumber.First,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.shifting,
        iconSize: 40,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined, color: Styles.white,),
            label: 'Cerca de ti',
            backgroundColor: Styles.mainColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded, color: Styles.white,),
            label: 'Tu Marca',
            backgroundColor: Styles.mainColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Styles.white,),
            label: 'Chat',
            backgroundColor: Styles.mainColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, color: Styles.white,),
            label: 'Perfil',
            backgroundColor: Styles.mainColor,
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
        selectedItemColor: Styles.white,
        selectedLabelStyle: Styles.whiteTextStyle.copyWith(fontSize: 15),
        unselectedItemColor: Styles.white,
        unselectedLabelStyle: Styles.whiteTextStyle.copyWith(fontSize: 15),
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
          ChildWidget(number: AvailableNumber.Fourth)
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


