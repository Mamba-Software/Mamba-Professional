import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
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

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();

  // init Widget state. Loading user info.
  @override
  void initState() {
    getUserBrand();
    super.initState();
  }

  // Gets the user info from firebase.
  void getUserBrand() async {
    currentUser = await _accessDatabase.getCurrentUserDetails();
    // Check for new brand
    if (currentUser.brandID != currentBrand.id && currentUser.brandID != "null" && currentUser.brandID != null) {
      Brand brand = await _accessDatabase.getBrandDetails(currentUser.brandID!);
      setState(() {
        currentBrand = brand;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return currentUser.isTrainer! ?
        MarcaTrainer()
          :
        MarcaClient();
  }
}
