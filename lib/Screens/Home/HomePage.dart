// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// // Authentication Service
import 'package:mamba_castelldefels/data/AuthService.dart';
// Database Service
import 'package:mamba_castelldefels/data/Database.dart';
// Internal App Tools
import 'package:mamba_castelldefels/models/Client.dart';
import 'package:mamba_castelldefels/models/Trainer.dart';
import 'package:mamba_castelldefels/screens/Home/ClientList.dart';
import 'package:mamba_castelldefels/screens/Home/TrainerList.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Authentication Service
  final AuthenticationService _authenticationService = AuthenticationService();
  // Loading Screen Boolean
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() :MultiProvider(
        providers: [
          StreamProvider<List<Client>>.value(value: DatabaseService(uid:'').clients),
          StreamProvider<List<Trainer>>.value(value: DatabaseService(uid:'').trainers),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text('MAMBA'),
            backgroundColor: yellowColor,
            elevation: 0.0,
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.person, color: whiteColor),
                label: Text(
                  'Cerrar Sesión',
                  style: whiteTextStyle.copyWith(fontSize: 17.0),
                ),
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  await _authenticationService.signOut();
                },
              ),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Entrenadores',
                  style: purpleTextStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              TrainerList(),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Clientes',
                  style: purpleTextStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ClientList()
            ],
          ),
        )
    );
  }
}
