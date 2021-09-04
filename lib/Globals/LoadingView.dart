import 'package:flutter/material.dart';

import 'Constants.dart';
import 'Styles.dart';

class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.15,
            child: CircularProgressIndicator(
              color: Styles.mainColor,
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.13,
            height: MediaQuery.of(context).size.height * 0.13,
            child: Image(
                image: AssetImage(Constants.logoSimpleYellow)
            ),
          ),
        ),
      ],
    );
  }
}