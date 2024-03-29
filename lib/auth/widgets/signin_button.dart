import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';

// ignore: must_be_immutable
class SignUpButton extends StatelessWidget {
  final Color foregroundColor;
  final Color backgroundColor;
  final String text;
  final Widget? icon;
  void Function() onTap;
  bool Function() isLoading;

  SignUpButton({
    super.key,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.text,
    this.icon,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadiusSmall),
          ),
        ),
        child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: context.theme.dividerColor, // Color of the bottom border
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(borderRadiusSmall),
            ),
            child: isLoading() == true
                ? returnText(context)
                : returnLoading(context),),
      ),
    );
  }

  Widget returnText(BuildContext context) {
    return icon == null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: context.textTheme.titleLarge!
                    .copyWith(color: foregroundColor),
              )
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              icon!,
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: context.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  Widget returnLoading(BuildContext context) {
    return LoadingView(
      isSmall: true,
      hasLogo: false,
      color: foregroundColor,
    );
  }
}
