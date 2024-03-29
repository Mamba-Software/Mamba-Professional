import 'package:flutter/material.dart';
import 'package:mamba/commons/extensions/context.dart';

class ResponsiveCenter extends StatelessWidget {
  final Widget child;

  const ResponsiveCenter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: kToolbarHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colorScheme.background,
            border: Border(
              bottom: BorderSide(
                color: context.theme.dividerColor, // Color of the bottom border
                width: 0.5, // Width of the bottom border
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Mamba",
              style: context.textTheme.displayLarge,
            ),
          ),
        ),
        Expanded(
          child: Container(
            child: child,
          ),
        ),
        Container(
          height: kToolbarHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colorScheme.background,
            border: Border(
              bottom: BorderSide(
                color: context.theme.dividerColor, // Color of the bottom border
                width: 0.5, // Width of the bottom border
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Mamba",
              style: context.textTheme.displayLarge,
            ),
          ),
        ),
      ],
    );
  }
}
