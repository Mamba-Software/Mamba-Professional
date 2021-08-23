// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// // Authentication Service
//import 'package:mamba_castelldefels/data/AuthService.dart';
// Database Service
import 'package:mamba_castelldefels/data/Database.dart';
// Internal App Tools
import 'package:mamba_castelldefels/Models/Client.dart';
import 'package:mamba_castelldefels/Models/Trainer.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Chat/Chat.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Trainers/Home.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/Perfil.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Authentication Service
  //final AuthenticationService _authenticationService = AuthenticationService();
  // Loading Screen Boolean
  bool loading = false;
  // Index of Bottom Navigation Bar
  int _currentIndex = 1;
  // Navigation Bar Tabs
  final navBarTabs= [
    Perfil(),
    Home(),
    Chat(),
  ];

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() :MultiProvider(
        providers: [
          StreamProvider<List<Client>>.value(value: DatabaseService().clients, initialData: [],),
          StreamProvider<List<Trainer>>.value(value: DatabaseService().trainers, initialData: [],),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Container(
                height: 30,
                alignment: Alignment.center,
                child: Image.asset(logoExtended)),
            backgroundColor: yellowColor,
            elevation: 0.0,
            actions: <Widget>[
            ],
          ),
          body: navBarTabs[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.shifting,
            iconSize: 32,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.person, color: whiteColor,),
                label: 'Perfil',
                backgroundColor: yellowColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: whiteColor,),
                label: 'Home',
                backgroundColor: yellowColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat, color: whiteColor,),
                label: 'Chat',
                backgroundColor: yellowColor,
              ),
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: whiteColor,
            selectedLabelStyle: whiteTextStyle.copyWith(fontSize: 15),
            unselectedItemColor: whiteColor,
            unselectedLabelStyle: whiteTextStyle.copyWith(fontSize: 15),
          ),
        )
    );
  }
}

