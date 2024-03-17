import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Auth/utils/enumAuth.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget normalLogin(BuildContext context, AuthState state, final formKey,
    String email, String password) {
  return GestureDetector(
    onTap: () async {
      if (formKey.currentState!.validate()) {
        //emailTemp = email;
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        context
            .read<AuthCubit>()
            .generalSignIn(AuthProviderEnum.normal, context, email, password);
      }
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
            color: AppColors.white, borderRadius: BorderRadius.circular(30)),
        child: checkIfProvider(state, AuthProviderEnum.normal)
            ? Center(
                child: Text(
                    AppLocalizations.of(context)!
                        .continueWithGoogle
                        .split(" ")[0],
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(color: AppColors.black)),
              )
            : Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.06,
                  height: MediaQuery.of(context).size.width * 0.06,
                  child: const CircularProgressIndicator(
                    color: AppColors.black,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
      ),
    ),
  );
}

checkIfProvider(AuthState state, AuthProviderEnum provider) {
  if (state is AuthLoading && state.provider == provider) return false;
  return true;
}
