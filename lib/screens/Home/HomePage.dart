import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/data/AuthService.dart';
import 'package:mamba_castelldefels/data/Database.dart';
import 'package:mamba_castelldefels/models/Client.dart';
import 'package:mamba_castelldefels/models/Trainer.dart';
import 'package:mamba_castelldefels/screens/Home/ClientList.dart';
import 'package:mamba_castelldefels/screens/Home/TrainerList.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final AuthenticationService _authenticationService = AuthenticationService();
  static const backgroundColor = Color(0xFFF4AD1F);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<Client>>.value(value: DatabaseService(uid:'').clients),
        StreamProvider<List<Trainer>>.value(value: DatabaseService(uid:'').trainers),
      ],
        child: Scaffold(
          appBar: AppBar(
            title: Text('MAMBA'),
            backgroundColor: Color(0xFFF4AD1F),
            elevation: 0.0,
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.person, color: Colors.white),
                label: Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
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
                  style: TextStyle(color: Color(0xFF200758), fontSize: 17.0, fontWeight: FontWeight.bold),
                ),
              ),
              TrainerList(),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Clientes',
                  style: TextStyle(color: Color(0xFF200758), fontSize: 17.0, fontWeight: FontWeight.bold),
                ),
              ),
              ClientList()
            ],
          ),
        )
    );
  }
}

/*
body: Center(
            child: Column(
              children: [
                Text(
                  'Entrenadores',
                  style: TextStyle(color: Color(0xFF200758), fontSize: 17.0, fontWeight: FontWeight.bold),
                ),
                TrainerList(),
                Text(
                  'Clientes',
                  style: TextStyle(color: Color(0xFF200758), fontSize: 17.0),
                ),
                ClientList(),

              ],
            ),
          ),
* */