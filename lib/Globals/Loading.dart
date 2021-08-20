// Flutter Libs
import 'package:flutter/material.dart';
// Flutter Spinner Kit
import 'package:flutter_spinkit/flutter_spinkit.dart';
//Internal App Resources
import 'package:mamba_castelldefels/Globals/Globals.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: yellowColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.only(bottom: 10.0),
                width: 200,
                height: 60,
                child: Image.asset(logoSimple)),
            SpinKitThreeBounce(
              color: whiteColor,
              size: 40.0
            ),
          ],
        ),
      ),
    );
  }
}
