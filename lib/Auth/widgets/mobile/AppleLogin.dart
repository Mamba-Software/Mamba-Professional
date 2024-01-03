import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Auth/utils/enumAuth.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget appleLogin(BuildContext context, AuthState state) {

  return GestureDetector(
    onTap: () {
      context.read<AuthCubit>().generalSignIn(AuthProviderEnum.apple, context);
    },
    child: Material(
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30.0),
        ),
      ),
      child: Container(
        height: MediaQuery
            .of(context)
            .size
            .height * 0.07,
        width: MediaQuery
            .of(context)
            .size
            .width * 0.9,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.07,
              width: MediaQuery
                  .of(context)
                  .size
                  .height * 0.07,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(30)
              ),
              child: Image(
                  image: AssetImage(Constants.apple)
              ),
            ),
            Expanded(
              child: checkIfProvider(state, AuthProviderEnum.apple)
                  ? Text(
                  AppLocalizations.of(context)!.continueWithApple,
                  style: Theme
                      .of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: AppColors.black),
                  textAlign: TextAlign.center
              ) : Center(
                child: SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.06,
                  height: MediaQuery
                      .of(context)
                      .size
                      .width * 0.06,
                  child: const CircularProgressIndicator(
                    color: AppColors.black,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

checkIfProvider(AuthState state, AuthProviderEnum provider)
{
  if(state is AuthLoading && state.provider == provider) return false;
  return true;
}
