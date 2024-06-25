import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mamba/auth/bloc/auth_bloc.dart';
import 'package:mamba/auth/models/enum_auth.dart';
import 'package:mamba/auth/models/exceptions.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
part 'AuthState.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthBloc _authBloc;
  StreamSubscription? authBlocSubscription;

  AuthCubit({
    required AuthBloc authBloc,
  })  : _authBloc = authBloc,
        super(const AuthInitial());

  final _userDataService = UserDataService();

  String email = "";
  final googleSignIn = GoogleSignIn();

  bool checkIfIsLoading(AuthProviderEnum provider) {
    if (state is AuthLoading) {
      final authLoadingState = state as AuthLoading; // Cast to AuthLoading
      if (authLoadingState.provider == provider) {
        return true;
      }
    }
    return false;
  }

  Future<void> generalSignIn(AuthProviderEnum provider, BuildContext context,
      [String? email, String? password]) async {
    try {
      emit(AuthLoading(provider));
      switch (provider) {
        case AuthProviderEnum.normal:
          if (email == null) {
            emit(const AuthError(AuthErrorEnum.loginError));
          } else if (password == null) {
            emit(const AuthError(AuthErrorEnum.loginError));
          } else {
            await _authBloc.logInWithCredentials(
              email: email.trim(),
              password: password,
              provider: provider,
            );
          }
          break;
        case AuthProviderEnum.google:
          await _authBloc.logInWithCredentials(
            email: null,
            password: null,
            provider: provider,
          );
          break;
        case AuthProviderEnum.apple:
          await _authBloc.logInWithCredentials(
            email: null,
            password: null,
            provider: provider,
          );
          break;
        case AuthProviderEnum.register:
          // TODO: Handle this case.
          break;
        case AuthProviderEnum.forgot:
          // TODO: Handle this case.
          break;
      }
      await _authBloc.checkUserType(checkTrainer: true);
      mixpanel!.track('mamba_login_completed');
      emit(const AuthInitial());
    } on EmailNotVerified {
      mixpanel!.track('mamba_login_validate_email_error');
      emit(const AuthError(AuthErrorEnum.validateError));
    } on EmailNotValid {
      emit(const AuthError(AuthErrorEnum.loginError));
    } on WrongCredentials {
      mixpanel!.track('mamba_login_notfound_error');
      emit(const AuthError(AuthErrorEnum.loginError));
    } on RegisterError {
      emit(const AuthError(AuthErrorEnum.registerError));
    } on WrongAppUser {
      emit(const AuthError(AuthErrorEnum.wrongAppUser));
    } on Exception {
      emit(const AuthError(AuthErrorEnum.loginError));
    }
  }

  void signUp(String email, String password1, BuildContext context) async {
    emit(const AuthLoading(AuthProviderEnum.register));

    if (emailValidator(email)) {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      var result = await _userDataService.addUser(email.trim(), password1,
          Localizations.localeOf(context).languageCode, true);
      if (result == 0) {
        mixpanel!.track('mamba_register_completed');
        emit(AuthRegistered(email: email));
      } else if (result == -1) {
        mixpanel!.track('mamba_register_existing_email_error');
        emit(const AuthError(AuthErrorEnum.sameEmail));
      } else {
        emit(const AuthError(AuthErrorEnum.manualRegisterError));
      }
    } else {
      emit(const AuthError(AuthErrorEnum.validateErrorRegister));
    }
  }

  void signOut() {
    //emit(const AuthLogOut());
  }

  Future<void> forgotPassword(String email, BuildContext context) async {
    emit(const AuthLoading(AuthProviderEnum.forgot));
    if (email.isEmpty) {
      emit(const AuthError(AuthErrorEnum.forgotEmailError));
    } else {
      if (emailValidator(email)) {
        emit(const AuthLoading(AuthProviderEnum.forgot));
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        try {
          await _authBloc.resetPassword(email: email);
          emit(AuthCorrectForget(email: email));
        } on ResetPasswordFailure {
          emit(const AuthError(AuthErrorEnum.forgotLoginError));
        }
        //var result = await _userDataService.resetPassword(email);
      } else {
        emit(const AuthError(AuthErrorEnum.forgotValidateEmailError));
      }
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    await _userDataService.resendEmail(email);
  }

  // Validate email and pwd format
  bool emailValidator(String value) {
    Pattern pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }
}
