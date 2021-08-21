// Flutter Libs
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
// Internal App Tools
import 'ClientList.dart';
import 'TrainerList.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
        Expanded(
            child: ClientList()
        ),
      ],
    );
  }
}