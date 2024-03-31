import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';

class CustomAppBar extends StatelessWidget {
  final double height;
  final double? maxWidth;

  const CustomAppBar({super.key, required this.height, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colorScheme.background,
        border: Border(
          bottom: BorderSide(
            color: context.theme.dividerColor, // Color of the bottom border
            width: 0.5, // Width of the bottom border
          ),
        ),
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
                style: context.textTheme.headlineLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
