import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/SinMarca/SinMarcaTrainer.dart';

import 'TieneMarca/TieneMarcaTrainer.dart';

class MarcaTrainer extends StatefulWidget {
  const MarcaTrainer({Key? key}) : super(key: key);

  @override
  _MarcaTrainerState createState() => _MarcaTrainerState();
}

class _MarcaTrainerState extends State<MarcaTrainer> {

  // Boolean For Brand Creation
  var _newBrand = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentBrand.id == null ?
    SinMarcaTrainer()
        :
    TieneMarcaTrainer();
  }
}
