// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Providers/AuthenticationProvider.dart';
import 'package:mamba_castelldefels/Providers/ClientProvider.dart';
import 'package:mamba_castelldefels/Providers/TrainerProvider.dart';
import 'package:mamba_castelldefels/Providers/UserProvider.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/Perfil.dart';
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
import 'package:mamba_castelldefels/Screens/MainApp/Home/CercaDeTi/CercaDeTi.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/TuMarca/TuMarca.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Chat/Chat.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilClient.dart';

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userUID = Provider.of<UserProvider>(context).usuario.uid;
    userIsTrainer = Provider.of<UserProvider>(context).usuario.isTrainer!;
    if(userIsTrainer) {
      Provider.of<TrainerProvider>(context).getTrainerFirebase(userUID);
      currentUser = Provider.of<TrainerProvider>(context).trainer;
    } else {
      Provider.of<ClientProvider>(context).getClientFirebase(userUID);
      currentUser = Provider.of<ClientProvider>(context).client;
    }
    return (currentUser.name == null) ? Loading() :MultiProvider(
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
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.shifting,
            iconSize: 40,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined, color: whiteColor,),
                label: 'Cerca de ti',
                backgroundColor: yellowColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_rounded, color: whiteColor,),
                label: 'Tu Marca',
                backgroundColor: yellowColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat, color: whiteColor,),
                label: 'Chat',
                backgroundColor: yellowColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined, color: whiteColor,),
                label: 'Perfil',
                backgroundColor: yellowColor,
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
            selectedItemColor: whiteColor,
            selectedLabelStyle: whiteTextStyle.copyWith(fontSize: 15),
            unselectedItemColor: whiteColor,
            unselectedLabelStyle: whiteTextStyle.copyWith(fontSize: 15),
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
        )
    );
  }
}


