import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';

Widget profileImage(BuildContext context) {
  return InkWell(
    onTap: () => navigateToProfileScreen(context),
    hoverColor: context.theme.primaryColor.withOpacity(0.2),
    splashColor: context.theme.primaryColor.withOpacity(0.2),
    borderRadius:
        BorderRadius.circular(24), // Optional: customize the splash radius
    child: Padding(
      padding: const EdgeInsets.all(8), // Control the space around the icon
      child: SizedBox(
        height: iconSize,
        child: Center(
          child: CircularImage(
            size: iconSize,
            image: currentUser.imageUrl,
            color: AppColors.grey,
            borderWidth: 0,
          ),
        ),
      ),
    ),
  );
}
