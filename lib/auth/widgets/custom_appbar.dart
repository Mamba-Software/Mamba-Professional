import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final double? maxWidth;
  final bool? isDesktop;

  const CustomAppBar({
    super.key,
    required this.height,
    this.maxWidth,
    this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDesktop ?? false
            ? context.colorScheme.background
            : Colors.transparent,
        border: Border(
          bottom: isDesktop ?? false
              ? BorderSide(
                  color:
                      context.theme.dividerColor, // Color of the bottom border
                  width: 0.5, // Width of the bottom border
                )
              : BorderSide.none,
        ),
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
          child: Row(
            mainAxisAlignment: isDesktop ?? false
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(
                      Assets.mambaLogoIcon,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                appName,
                style: isDesktop ?? false
                    ? context.textTheme.headlineLarge
                    : context.textTheme.headlineSmall,
              ),
              const SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
