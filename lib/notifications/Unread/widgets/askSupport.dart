import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';

Widget askSupport(BuildContext context) {
  return InkWell(
    onTap: () => navigateToMainFeedbackScreen(context),
    splashColor: Colors.white
        .withOpacity(0.2), // Customize splash color and radius if needed
    borderRadius:
        BorderRadius.circular(24), // Optional: customize the splash radius
    child: Padding(
      padding: const EdgeInsets.all(8), // Control the space around the icon
      child: Icon(
        Icons.help_outline_outlined,
        color: AppColors.white,
        size: MediaQuery.of(context).size.width * 0.06,
      ),
    ),
  );
}
