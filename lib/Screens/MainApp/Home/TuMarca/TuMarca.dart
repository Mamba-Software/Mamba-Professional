import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';

class TuMarca extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("TU MARCA",style: Styles.purpleTextStyle.copyWith(fontSize: 30, fontWeight: FontWeight.bold)));
  }
}
