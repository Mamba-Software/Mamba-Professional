import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/AuthService.dart';
import 'package:mamba_castelldefels/Data/Database.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';

class FirstClient extends StatefulWidget {
  const FirstClient({Key? key}) : super(key: key);

  @override
  _FirstClientState createState() => _FirstClientState();
}

class _FirstClientState extends State<FirstClient> {
  // Authentication Service
  final AuthenticationService _authenticationService = AuthenticationService();
  final DatabaseService _databaseService = DatabaseService(uid: userUID);
  // Loading Screen Boolean
  late bool loading = false;
  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: yellowColor,
      body: Center(
        child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                    width: 200,
                    height: 100,
                    child: Image.asset(logoExtended)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("FIRST TIME CLIENT", style: purpleTextStyle.copyWith(fontSize: 20, fontWeight:FontWeight.bold )),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    await _authenticationService.signOut();
                  },
                  child: Text(
                    'Cerrar Sesión',
                    style: whiteTextStyle.copyWith(fontSize: 17.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      await _databaseService.updateUsersData(userUID, userIsTrainer, false);
                    },
                    child: Text(
                      'Entendido',
                      style: whiteTextStyle.copyWith(fontSize: 17.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
