import 'package:flutter/material.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/styles/AppColors.dart';

class AppBarIcon extends StatelessWidget with PlatformMixin {
  IconData icon;
  double iconSize;
  Color color;
  void Function() onTap;

  AppBarIcon({
    Key? key,
    required this.icon,
    required this.iconSize,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap,
      hoverColor: color.withOpacity(0.2),
      splashColor: color.withOpacity(0.2),
      borderRadius:
          BorderRadius.circular(24), // Optional: customize the splash radius
      child: Padding(
        padding: const EdgeInsets.all(8), // Control the space around the icon
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }
}
