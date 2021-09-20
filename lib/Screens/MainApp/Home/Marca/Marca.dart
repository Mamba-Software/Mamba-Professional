import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

import 'Client/MarcaClient.dart';
import 'Trainer/MarcaTrainer.dart';

class Marca extends StatefulWidget {
  const Marca({Key? key}) : super(key: key);

  @override
  _MarcaState createState() => _MarcaState();
}

class _MarcaState extends State<Marca> {

  // init Widget state. Loading user info.
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentUser.isTrainer! ?
        MarcaTrainer()
          :
        MarcaClient()
      ;
  }
}
