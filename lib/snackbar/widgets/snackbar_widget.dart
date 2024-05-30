import 'package:flutter/material.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/snackbar/models/custom_snackbar.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';

class CustomSnackbarView extends StatelessWidget {
  final double padding;
  final double maxWidth;
  final CustomSnackbar snackbar;
  final VoidCallback? onAccept;
  final Color? color;
  final IconData? icon;

  const CustomSnackbarView({
    Key? key,
    required this.padding,
    required this.maxWidth,
    required this.snackbar,
    this.onAccept,
    this.color,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          border: Border.all(
            width: 2,
            color: _getColor(context),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getIconForType(context),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                snackbar.message,
                style: _getTextStyle(context),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            if (snackbar.onAccept != null && snackbar.actionText != null)
              TextButton(
                onPressed: () {
                  print("TextButton onPressed triggered.");
                  onAccept?.call();
                },
                child: Text(
                  snackbar.actionText!,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: snackbar.type == SnackbarType.information
                        ? context.colorScheme.primary
                        : AppColors.white,
                  ),
                ),
              ),
            if (snackbar.onAccept == null && snackbar.actionText == null)
              const SizedBox(width: 10),
            CountdownIndicator(
                foregroundColor: _getColor(context),
                backgroundColor: snackbar.type == SnackbarType.information
                    ? context.theme.primaryColor
                    : AppColors.white,
                snackbar: snackbar,
                duration: Duration(seconds: snackbarDefaultDuration)),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  TextStyle? _getTextStyle(BuildContext context, {bool isTitle = false}) {
    var textStyle = context.isDesktop
        ? context.textTheme.bodyLarge
        : context.textTheme.bodyMedium;
    final color = (snackbar.type == SnackbarType.error ||
            snackbar.type == SnackbarType.success)
        ? Colors.white
        : context.colorScheme.primary;
    return isTitle
        ? context.textTheme.titleLarge?.copyWith(color: color)
        : textStyle?.copyWith(
            color: color,
          );
  }

  Widget _getIconForType(BuildContext context) {
    if (icon != null) {
      return Icon(
        icon!,
        color: color,
        size: iconSize,
      );
    }
    switch (snackbar.type) {
      case SnackbarType.success:
        return Icon(
          Icons.check_circle,
          color: AppColors.white,
          size: iconSize,
        );
      case SnackbarType.error:
        return Icon(
          Icons.error,
          color: AppColors.white,
          size: iconSize,
        );
      case SnackbarType.information:
      default:
        return Icon(
          Icons.info,
          color: context.colorScheme.primary,
          size: iconSize,
        );
    }
  }

  Color _getColor(BuildContext context) {
    if (color != null) {
      return color!;
    }
    switch (snackbar.type) {
      case SnackbarType.success:
        return AppColors.green;
      case SnackbarType.error:
        return AppColors.red;
      case SnackbarType.information:
      default:
        return context.colorScheme.primary;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    if (color != null) {
      return color!.withOpacity(0.3);
    }
    switch (snackbar.type) {
      case SnackbarType.success:
        return AppColors.ligtherGreen;
      case SnackbarType.error:
        return AppColors.ligtherRed;
      case SnackbarType.information:
      default:
        return context.colorScheme.background;
    }
  }
}

class CountdownIndicator extends StatelessWidget {
  final Color foregroundColor;
  final Color backgroundColor;
  final Duration duration;
  final CustomSnackbar snackbar;

  const CountdownIndicator({
    Key? key,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.snackbar,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: duration,
      builder: (context, double value, child) => Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 1.5,
              backgroundColor: snackbar.type == SnackbarType.information
                  ? context.theme.scaffoldBackgroundColor
                  : foregroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(backgroundColor),
            ),
          ),
          Text("${(value * duration.inSeconds).ceil()}",
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: backgroundColor)),
        ],
      ),
    );
  }
}
