import 'package:flutter/material.dart';
import '../../../Constants.dart';

class LoadingView extends StatefulWidget {
  bool? hasLogo;
  LoadingView({Key? key, this.hasLogo}) : super(key: key);

  @override
  _LoadingViewState createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: SizedBox(
            //width: MediaQuery.of(context).size.width * 0.14,
            width: 50,
            //height: MediaQuery.of(context).size.height * 0.07,
            height: 50,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        widget.hasLogo != null && widget.hasLogo! ? Center(
          child: SizedBox(
            //width: MediaQuery.of(context).size.width * 0.07,
            width: 25,
            //height: MediaQuery.of(context).size.height * 0.07,
            height: 25,
            child: Image(
                image: AssetImage(Constants.logoSimpleYellow)
            ),
          ),
        ) : Container(),
      ],
    );
  }
}