import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/auth/utils/enumAuth.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget googleLogin(BuildContext context, AuthState state) {
  return GestureDetector(
    onTap: () {
      context.read<AuthCubit>().generalSignIn(AuthProviderEnum.google, context);
    },
    child: Material(
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30.0),
        ),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.07,
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: const Color(0xFF4285F4),
            borderRadius: BorderRadius.circular(30)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.height * 0.07,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30)),
              child: Image(image: AssetImage(Assets.google)),
            ),
            Expanded(
              child: checkIfProvider(state, AuthProviderEnum.google)
                  ? Text(AppLocalizations.of(context)!.continueWithGoogle,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: AppColors.white),
                      textAlign: TextAlign.center)
                  : Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.06,
                        height: MediaQuery.of(context).size.width * 0.06,
                        child: const CircularProgressIndicator(
                          color: AppColors.white,
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

checkIfProvider(AuthState state, AuthProviderEnum provider) {
  if (state is AuthLoading && state.provider == provider) return false;
  return true;
}
