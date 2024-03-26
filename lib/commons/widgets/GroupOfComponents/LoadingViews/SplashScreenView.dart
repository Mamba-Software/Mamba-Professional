import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Loading View Widget which displays a Circular Progress indicator with the Mamba "M" inside.
class SplashScreenView extends StatefulWidget {
  bool isMaintenance;
  SplashScreenView({super.key, required this.isMaintenance});

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

  void downloadData() {
    Timer.periodic(const Duration(milliseconds: 30), (Timer timer) {
      if (mounted) {
        setState(() {
          if (value == 1) {
            timer.cancel();
          } else {
            value = value + 0.01;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: AppColors.black,
          surfaceTintColor: AppColors.black,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        backgroundColor: AppColors.black,
        body: Center(
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity: widget.isMaintenance == false ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width * 0.45),
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: AnimatedAlign(
                      alignment: _alignment,
                      duration: const Duration(seconds: 3),
                      child: Image.asset(
                        Assets.runningFemale,
                        width: MediaQuery.of(context).size.width * 0.18,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: widget.isMaintenance == true ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Center(
                  child: Container(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.width * 0.45),
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              height: MediaQuery.of(context).size.width * 0.15,
                              child: const CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          Icon(
                            FontAwesomeIcons.screwdriverWrench,
                            color: AppColors.white,
                            size: MediaQuery.of(context).size.width * 0.07,
                          ),
                        ],
                      )),
                ),
              ),
              Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Image.asset(Assets.logoExtended)),
              ),
              AnimatedOpacity(
                opacity: widget.isMaintenance == false ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.3),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: LinearProgressIndicator(
                        color: AppColors.white,
                        backgroundColor: AppColors.black,
                        value: value,
                        minHeight: MediaQuery.of(context).size.width * 0.01,
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: widget.isMaintenance == true ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.48),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        AppLocalizations.of(context)!.isMaintenanceText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
