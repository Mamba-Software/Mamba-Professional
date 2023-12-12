import 'package:flutter/material.dart';

class BetaBadge extends StatefulWidget {
  BetaBadge({Key? key}) : super(key: key);

  @override
  _BetaBadgeState createState() => new _BetaBadgeState();
}

class _BetaBadgeState extends State<BetaBadge> {
  

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
      height: MediaQuery.of(context).size.width * 0.05,
      width: MediaQuery.of(context).size.width * 0.12,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
      ),
      child: Center(
        child: Text(
          "Beta",
          style: Theme.of(context)
              .textTheme
              .bodyText2
              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }
}
