import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LongTextContainer extends StatefulWidget {
  final String text;

  LongTextContainer({Key? key, required this.text}) : super(key: key);

  @override
  _LongTextContainerState createState() => new _LongTextContainerState();
}

class _LongTextContainerState extends State<LongTextContainer> {

  bool readMore = true;
  var lines;

  @override
  Widget build(BuildContext context) {
    lines = readMore ? null : 1;
    return Container(
      child: Column(
        children: [
          Text(
            widget.text,
            style: Theme.of(context).textTheme.caption,
            maxLines: lines,
            // overflow properties is used to show 3 dot in text widget
            // so that user can understand there are few more line to read.
            overflow: readMore ? TextOverflow.visible: TextOverflow.ellipsis,
          ),
          TextButton(
            onPressed: () {
              setState(() {
                readMore = !readMore;
              });
            },
            style: ButtonStyle(

            ),
            child: Text(
              !readMore ? AppLocalizations.of(context)!.readMore : AppLocalizations.of(context)!.readLess,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).accentColor),
              textAlign: TextAlign.left
            )
          )
        ],
      ),
    );
  }
}