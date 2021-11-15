import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Client/SinMarca/SinMarcaClient.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/SinMarca/SinMarcaTrainer.dart';

import 'TieneMarca/TieneMarcaClient.dart';

class MarcaClient extends StatefulWidget {
  const MarcaClient({Key? key}) : super(key: key);

  @override
  _MarcaClientState createState() => _MarcaClientState();
}

class _MarcaClientState extends State<MarcaClient> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentBrand.id == null ?
    SinMarcaClient()
        :
    TieneMarcaClient();
  }
}
