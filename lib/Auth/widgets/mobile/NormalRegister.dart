import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Auth/utils/enumAuth.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget normalRegister(BuildContext context, AuthState state, final formKey,
    String email, String password) {
  return GestureDetector(
    onTap: () async {
      if (formKey.currentState!.validate()) {
        //emailTemp = email;
        context.read<AuthCubit>().signUp(email, password, context);
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
        child: checkIfProvider(state, AuthProviderEnum.register)
            ? Center(
                child: Text(AppLocalizations.of(context)!.register,
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
