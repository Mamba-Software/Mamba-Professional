import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
          onPressed: isLoading() ? null : onTap,
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(foregroundColor),
            backgroundColor: MaterialStateProperty.all(backgroundColor),
            surfaceTintColor: MaterialStateProperty.all(backgroundColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadiusSmall),
              ),
            ),
            elevation: MaterialStateProperty.all(2),           
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          child: isLoading() ? returnLoading(context) : returnText(context)),
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
              Container(
                constraints: BoxConstraints(
                  maxHeight: iconSize
                ),
                child: icon!,),
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
