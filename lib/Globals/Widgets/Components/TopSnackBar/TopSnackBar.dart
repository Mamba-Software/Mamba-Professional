

//TopSnackBar Class is used to send a snack bar message
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class TopSnackBar {

  //Function to send a snack bar message
  void topsnackbar(var context, String? message, var color) {
     showTopSnackBar(
        context,
        CustomSnackBar.success(
        icon: Container(),
    iconRotationAngle: 0,
    backgroundColor: color,
    message: message!,
    textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.white),
    ),
     );
  }
}
