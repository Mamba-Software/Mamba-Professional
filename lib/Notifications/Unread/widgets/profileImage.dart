import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';

Widget profileImage(BuildContext context) {
  return GestureDetector(
    onTap: () => navigateToProfileScreen(context),
    child: SizedBox(
      height: MediaQuery.of(context).size.width * 0.08,
      child: Center(
        child: CircularImage(
          size: MediaQuery.of(context).size.width * 0.08,
          image: currentUser.imageUrl,
          color: AppColors.grey,
          borderWidth: 0,
        ),
      ),
    ),
  );
}
