import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
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
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // Model Usuario
  Usuario? user;

  // init Widget state. Loading user info.
  @override
  void initState() {
    super.initState();
    isLoading = true;
    getUser();
  }
  // Gets the user info from firebase.
  void getUser() async {
    user = await _accessDatabase.getCurrentUserDetails();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      LoadingView()
        :
      user!.isTrainer! ?
        MarcaTrainer()
          :
        MarcaClient()
      ;
  }
}
