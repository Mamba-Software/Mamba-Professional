// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Providers/AuthenticationProvider.dart';
import 'package:mamba_castelldefels/Providers/ClientProvider.dart';
import 'package:mamba_castelldefels/Providers/TrainerProvider.dart';
import 'package:mamba_castelldefels/Providers/UserProvider.dart';
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
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/Perfil.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable Models
  Client? _client;
  Trainer? _trainer;
  // Loading Screen Boolean
  bool loading = false;
  // Index of Bottom Navigation Bar
  int _currentIndex = 1;
  // Navigation Bar Tabs
  final navBarTabs= [
    CercaDeTi(),
    TuMarca(),
    Chat(),
    Perfil(),
  ];

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

