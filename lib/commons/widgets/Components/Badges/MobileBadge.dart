import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/snackbar/cubit/snackbar_cubit.dart';
import 'package:mamba/snackbar/models/custom_snackbar.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';

class OnlyMobileBadge extends StatefulWidget {
  const OnlyMobileBadge({super.key});

  @override
  _OnlyMobileBadgeState createState() => _OnlyMobileBadgeState();
}

class _OnlyMobileBadgeState extends State<OnlyMobileBadge> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CustomSnackbar snackbar = CustomSnackbar(
          type: SnackbarType.information,
          message: context.l10n.mobileOnly,
          icon: Icons.smartphone,
          color: Colors.blue,
        );
        context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: defaultPaddingSmall,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: defaultPaddingSmall,
          vertical: defaultPaddingSmall / 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(borderRadiusBig)),
          color: Colors.blue.withOpacity(0.2),
        ),
        child: Center(
          child: Text(
            "Soon",
            style: context.textTheme.bodyMedium?.copyWith(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
