import 'package:flutter/material.dart';

class NewBadge extends StatefulWidget {
  const NewBadge({super.key});

  @override
  _NewBadgeState createState() => _NewBadgeState();
}

class _NewBadgeState extends State<NewBadge> {
  

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
      height: MediaQuery.of(context).size.width * 0.05,
      width: MediaQuery.of(context).size.width * 0.12,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
      ),
      child: Center(
        child: Text(
          "New",
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }
}
