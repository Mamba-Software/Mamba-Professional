import 'package:flutter/material.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/snackbar/models/custom_snackbar.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';

class CustomSnackbarView extends StatelessWidget {
  final double maxWidth;
  final CustomSnackbar snackbar;
  final VoidCallback? actionCallback;
  final String? actionText;

  const CustomSnackbarView({
    Key? key,
    required this.maxWidth,
    required this.snackbar,
    this.actionText,
    this.actionCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth) ,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: _getBackgroundColor(snackbar.type, context),
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          border: Border.all(
            width: 2,
            color: _getColor(snackbar.type, context),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _getIconForType(snackbar.type, context),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                snackbar.message,
                style: _getTextStyle(snackbar.type, context),
              ),
            ),
            if (actionText != null && actionCallback != null)
              Flexible(
                child: TextButton(
                  onPressed: actionCallback,
                  child: Text(actionText!),
                ),
              ),
            const SizedBox(width: 10),
            CountdownIndicator(
                foregroundColor: _getColor(snackbar.type, context),
                backgroundColor: snackbar.type == SnackbarType.information
                    ? context.colorScheme.background
                    : AppColors.white,
                duration: snackbar.duration ??
                    Duration(seconds: snackbarDefaultDuration)),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  TextStyle? _getTextStyle(SnackbarType type, BuildContext context,
      {bool isTitle = false}) {
    final color =
        (type == SnackbarType.error || type == SnackbarType.success)
            ? Colors.white
            : context.colorScheme.onPrimary;
    return isTitle
        ? context.textTheme.titleLarge?.copyWith(color: color)
        : context.textTheme.bodyLarge?.copyWith(color: color);
  }

  Widget _getIconForType(SnackbarType type, BuildContext context) {
    switch (type) {
      case SnackbarType.success:
        return const Icon(
          Icons.check_circle,
          color: AppColors.white,
          size: 20,
        );
      case SnackbarType.error:
        return const Icon(
          Icons.error,
          color: AppColors.white,
          size: 20,
        );
      case SnackbarType.information:
      default:
        return Icon(
          Icons.info,
          color: context.theme.scaffoldBackgroundColor,
          size: 20,
        );
    }
  }

  Color _getColor(SnackbarType type, BuildContext context) {
    switch (type) {
      case SnackbarType.success:
        return AppColors.green;
      case SnackbarType.error:
        return AppColors.red;
      case SnackbarType.information:
      default:
        return context.colorScheme.onPrimary;
    }
  }
}

Color _getBackgroundColor(SnackbarType type, BuildContext context) {
  switch (type) {
    case SnackbarType.success:
      return AppColors.ligtherGreen;
    case SnackbarType.error:
      return AppColors.ligtherRed;
    case SnackbarType.information:
    default:
      return context.colorScheme.primary;
  }
}

class CountdownIndicator extends StatelessWidget {
  final Color foregroundColor;
  final Color backgroundColor;
  final Duration duration;

  const CountdownIndicator(
      {Key? key,
      required this.foregroundColor,
      required this.backgroundColor,
      required this.duration})
      : super(key: key);

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
              backgroundColor: foregroundColor,
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
