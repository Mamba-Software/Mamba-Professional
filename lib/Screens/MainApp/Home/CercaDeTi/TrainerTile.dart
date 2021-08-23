// Flutter Libs
import 'package:flutter/material.dart';
// Internal App Tools
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Models/Trainer.dart';

class TrainerTile extends StatelessWidget {

  final Trainer trainer;
  TrainerTile({ required this.trainer });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Color(0x80F4AD1F),
          ),
          title: Text(trainer.name, style: purpleTextStyle),
          subtitle: Text('Has ${trainer.email} as its email'),
        ),
      ),
    );
  }
}