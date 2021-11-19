import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'PerfilClient.dart';
import 'PerfilTrainer.dart';

class Perfil extends StatelessWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return currentUser.isTrainer! ?
    PerfilTrainer()
        :
    PerfilClient();
  }
}
