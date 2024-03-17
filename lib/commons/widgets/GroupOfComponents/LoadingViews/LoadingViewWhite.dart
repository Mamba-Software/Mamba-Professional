import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:mamba_castelldefels/commons/constants/constants.dart';

// Loading View Widget which displays a Circular Progress indicator with the Mamba "M" inside.
class LoadingViewWhite extends StatelessWidget {
  const LoadingViewWhite({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Center(
          child: SizedBox(
            //width: MediaQuery.of(context).size.width * 0.14,
            width: 50,
            //height: MediaQuery.of(context).size.height * 0.07,
            height: 50,
            child: CircularProgressIndicator(
              color: AppColors.white,
            ),
          ),
        ),
        Center(
          child: SizedBox(
            //width: MediaQuery.of(context).size.width * 0.07,
            width: 25,
            //height: MediaQuery.of(context).size.height * 0.07,
            height: 25,
            child: Image(
                  image: AssetImage(Constants.logoSimple)
              ),
            ),
          ),
      ],
    );
  }
}