import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import '../../Constants.dart';
import '../../Styles/Styles.dart';

// Loading View Widget which displays a Circular Progress indicator with the Mamba "M" inside.
class SplashScreenView extends StatefulWidget {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  _SplashScreenViewState createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {

  // Alignment For Animation
  AlignmentGeometry _alignment = Alignment.centerLeft;
  // Progress Indicator Value
  double value = 0;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _alignment = Alignment.centerRight;
        });
        downloadData();
      }
    });
    super.initState();
  }

  void downloadData(){
    new Timer.periodic(
        Duration(milliseconds: 30), (Timer timer) {
          if (mounted) {
            setState(() {
              if (value == 1) {
                timer.cancel();
              }
              else {
                value = value + 0.01;
              }
            });
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Theme.of(context).accentColor,
      body: Center(
        child: Stack(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.45),
                width: MediaQuery.of(context).size.width*0.6,
                child: AnimatedAlign(
                  alignment: _alignment,
                  duration: Duration(seconds: 3),
                  child: Image.asset(
                    Constants.runningFemale,
                    width: MediaQuery.of(context).size.width*0.18,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                  width: MediaQuery.of(context).size.width*0.50,
                  child: Image.asset(Constants.logoExtended)
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.3),
                child: Container(
                  width: MediaQuery.of(context).size.width*0.6,
                  child: LinearProgressIndicator(
                    color: AppColors.white,
                    backgroundColor: Theme.of(context).accentColor,
                    value: value,
                    minHeight: MediaQuery.of(context).size.width*0.01,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );

  }
}
