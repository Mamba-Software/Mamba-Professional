//TopSnackBar Class is used to send a snack bar message
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class TopSnackBarDef {
  //Function to send a snack bar message
  void showSnackBarTop(var context, String? message, var color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomSnackBar.success(
          icon: Container(),
          iconRotationAngle: 0,
          message: message!,
          backgroundColor: color,
          textStyle: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: AppColors.white),
        ),
        behavior: null, // Optional: makes it floating style
        // Set other SnackBar properties as needed
      ),
    );
  }

  void showSnackBarBottom(BuildContext context, String value, int duration,
      [bool isError = false]) {
    AnimatedSnackBar(
      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      duration: Duration(seconds: duration),
      builder: ((context) {
        return Material(
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.1,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isError == false
                  ? Theme.of(context).primaryColor
                  : AppColors.red.withOpacity(0.2),
              border: Border.all(
                  color: isError
                      ? AppColors.red
                      : Theme.of(context).primaryColorDark,
                  width: 1),
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                isError == false
                    ? Icon(
                        Icons.info_outlined,
                        color: Theme.of(context).primaryColorDark,
                        size: MediaQuery.of(context).size.width * 0.08,
                      )
                    : Icon(
                        Icons.error_outline,
                        color: AppColors.red,
                        size: MediaQuery.of(context).size.width * 0.08,
                      ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isError == false
                              ? Theme.of(context).primaryColorDark
                              : AppColors.red,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ).show(context);
  }

  void showSnackBarBottomBeta(
    BuildContext context,
    String value,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: CustomSnackBar.success(
          icon: Container(),
          iconRotationAngle: 0,
          message: value,
          backgroundColor: Theme.of(context).primaryColor,
          textStyle: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).primaryColorDark),
        ),
        behavior: null, // Optional: makes it floating style
        // Set other SnackBar properties as needed
      ),
    );
  }
}
