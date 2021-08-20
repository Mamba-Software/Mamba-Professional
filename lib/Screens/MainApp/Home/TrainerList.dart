// Flutter Libs
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// App Internal Tools
import 'package:mamba_castelldefels/models/Trainer.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/TrainerTile.dart';


class TrainerList extends StatefulWidget {
  @override
  _TrainerListState createState() => _TrainerListState();
}

class _TrainerListState extends State<TrainerList> {
  @override
  Widget build(BuildContext context) {
    final trainers = Provider.of<List<Trainer>>(context);
    if (trainers != null) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: trainers.length,
        itemBuilder: (context, index) {
          return TrainerTile(trainer: trainers[index]);
        },
      );
    } else {
      return ListView();
    }
  }
}