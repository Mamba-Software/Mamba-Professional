// Flutter Libs
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Providers/UserProvider.dart';
import 'package:provider/provider.dart';

class TuMarca extends StatefulWidget {
  const TuMarca({Key? key}) : super(key: key);

  @override
  _TuMarcaState createState() => _TuMarcaState();
}

class _TuMarcaState extends State<TuMarca> {
  // Loading Screen Boolean
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("TU MARCA",style: purpleTextStyle.copyWith(fontSize: 30, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
