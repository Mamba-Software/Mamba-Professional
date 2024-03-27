import 'package:flutter/material.dart';
import 'package:mamba/commons/managers/language_manager.dart';

class LongTextContainer extends StatefulWidget {
  final String text;

  const LongTextContainer({super.key, required this.text});

  @override
  _LongTextContainerState createState() => _LongTextContainerState();
}

class _LongTextContainerState extends State<LongTextContainer> {
  bool readMore = false;
  var lines;

  @override
  Widget build(BuildContext context) {
    lines = readMore ? null : 2;
    return Container(
      child: Column(
        children: [
          Text(
            widget.text,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: lines,
            // overflow properties is used to show 3 dot in text widget
            // so that user can understand there are few more line to read.
            overflow: readMore ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          TextButton(
              onPressed: () {
                setState(() {
                  readMore = !readMore;
                });
              },
              style: const ButtonStyle(),
              child: Text(
                  !readMore ? context.l10n.readMore : context.l10n.readLess,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                  textAlign: TextAlign.left))
        ],
      ),
    );
  }
}
