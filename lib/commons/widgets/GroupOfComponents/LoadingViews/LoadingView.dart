import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/constants.dart';

class LoadingView extends StatefulWidget {
  bool? hasLogo;
  bool? isSmall;
  Color? color;
  String? text;
  LoadingView({super.key, this.hasLogo, this.isSmall, this.color, this.text});

  @override
  _LoadingViewState createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: widget.isSmall != null && widget.isSmall == true ? 25 : 50,
            height: widget.isSmall != null && widget.isSmall == true ? 25 : 50,
            child: CircularProgressIndicator(
              strokeWidth:
                  widget.isSmall != null && widget.isSmall == true ? 2.5 : 4,
              color: widget.color ?? Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        widget.hasLogo != null && widget.hasLogo == false
            ? Container()
            : Center(
                child: SizedBox(
                  width: widget.isSmall != null && widget.isSmall == true
                      ? 12
                      : 25,
                  height: widget.isSmall != null && widget.isSmall == true
                      ? 12
                      : 25,
                  child: Image(image: AssetImage(Constants.logoSimpleYellow)),
                ),
              ),
        widget.text != null
            ? Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text(
                  widget.text!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            : Container(),
      ],
    );
  }
}
