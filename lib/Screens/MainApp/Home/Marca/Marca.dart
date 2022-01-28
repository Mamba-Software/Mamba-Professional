import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Client/MarcaClient.dart';

import 'Client/SinMarca/SinMarcaClient.dart';
import 'Trainer/MarcaTrainer.dart';
import 'Trainer/SinMarca/SinMarcaTrainer.dart';

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
        MarcaClient();
  }
}
