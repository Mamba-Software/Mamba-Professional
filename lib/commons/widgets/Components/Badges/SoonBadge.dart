import 'package:flutter/material.dart';

class SoonBadge extends StatefulWidget {
  const SoonBadge({super.key});

  @override
  _SoonBadgeState createState() => _SoonBadgeState();
}

class _SoonBadgeState extends State<SoonBadge> {
  

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
      height: MediaQuery.of(context).size.width * 0.05,
      width: MediaQuery.of(context).size.width * 0.12,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: Colors.blue.withOpacity(0.2),
      ),
      child: Center(
        child: Text(
          "Soon",
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.blue),
        ),
      ),
    );
  }
}
