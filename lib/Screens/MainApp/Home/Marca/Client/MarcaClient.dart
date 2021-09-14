import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';

class MarcaClient  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
                "Cargando los entrenadors en tu zona...",
                style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 20,),
            LoadingViewPurple(),
          ],
        )
    );
  }
}
