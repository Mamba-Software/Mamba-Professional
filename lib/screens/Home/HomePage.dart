import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/data/AuthService.dart';
import 'package:mamba_castelldefels/data/Database.dart';
import 'package:mamba_castelldefels/models/Client.dart';
import 'package:mamba_castelldefels/screens/Home/ClientList.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final AuthenticationService _authenticationService = AuthenticationService();
  static const backgroundColor = Color(0xFFF4AD1F);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Client>>.value(
        value: DatabaseService(uid: '').clients,
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text('MAMBA'),
            backgroundColor: Color(0x66200758),
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("HOME"),
                  TextButton(
                    onPressed: () async {
                      await _authenticationService.signOut();
                    },
                    child: Text("Sign out"),
                  ),
                  Container(
                    child: ClientList(),
                  ),
                ],
              ),
          ),),
      )
    );
  }
}
