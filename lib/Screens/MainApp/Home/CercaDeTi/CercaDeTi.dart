// Flutter Libs
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
// Internal App Tools
import 'package:mamba_castelldefels/Screens/MainApp/Home/CercaDeTi/TrainerList.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/CercaDeTi/ClientList.dart';

class CercaDeTi extends StatefulWidget {
  const CercaDeTi({Key? key}) : super(key: key);

  @override
  _CercaDeTiState createState() => _CercaDeTiState();
}

class _CercaDeTiState extends State<CercaDeTi> {
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