import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Models/Trainer.dart';
import 'package:mamba_castelldefels/Providers/AuthenticationProvider.dart';
import 'package:mamba_castelldefels/Providers/ClientProvider.dart';
import 'package:mamba_castelldefels/Providers/TrainerProvider.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilClient.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilTrainer.dart';
import 'package:provider/provider.dart';

import 'TuMarcaClient.dart';

class TuMarca extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if(userIsTrainer) {
      return Consumer<TrainerProvider>(
          builder: (context, TrainerProvider trainerProvider, _) {
            //return TuMarcaTrainer();
            return Container();
          });
    } else {
      return Consumer<ClientProvider>(
          builder: (context, ClientProvider clientProvider, _) {
            return TuMarcaClient();
          });
    }
  }
}
