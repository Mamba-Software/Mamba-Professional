import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';

Widget profileImage(BuildContext context) {
  return GestureDetector(
    onTap: () => navigateToProfileScreen(context),
    child: SizedBox(
      height: iconSizeBig,
      child: Center(
        child: CircularImage(
          size: iconSizeBig,
          image: currentUser.imageUrl,
          color: AppColors.grey,
          borderWidth: 0,
        ),
      ),
    ),
  );
}
