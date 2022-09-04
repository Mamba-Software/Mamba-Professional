import 'package:flutter/material.dart';
import '../../../Constants.dart';

class LoadingView extends StatefulWidget {
  bool? hasLogo;
  String? text;
  LoadingView({Key? key, this.hasLogo, this.text}) : super(key: key);

  @override
  _LoadingViewState createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
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
            widget.hasLogo != null && widget.hasLogo == false ? Container() : Center(
              child: SizedBox(
                //width: MediaQuery.of(context).size.width * 0.07,
                width: 25,
                //height: MediaQuery.of(context).size.height * 0.07,
                height: 25,
                child: Image(
                    image: AssetImage(Constants.logoSimpleYellow)
                ),
              ),
            ),
          ],
        ),
        widget.text != null ? Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.02,),
            Text(
              widget.text!,
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ) : Container(),
      ],
    );
  }
}