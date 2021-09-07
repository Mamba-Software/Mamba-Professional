import 'package:flutter/material.dart';
import 'Constants.dart';
import 'Styles.dart';

// Loading View Widget which displays a Circular Progress indicator with the Mamba "M" inside.
class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.14,
            height: MediaQuery.of(context).size.height * 0.07,
            child: CircularProgressIndicator(
              color: Styles.mainColor,
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.07,
            height: MediaQuery.of(context).size.height * 0.07,
            child: Image(
                  image: AssetImage(Constants.logoSimpleYellow)
              ),
            ),
          ),
      ],
    );
  }
}