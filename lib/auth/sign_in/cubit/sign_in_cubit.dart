import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mamba/auth/bloc/auth_bloc.dart';
import 'package:mamba/auth/models/auth_exceptions.dart';
import 'package:mamba/auth/sign_in/models/sign_in_error_type.dart';
import 'package:mamba/auth/sign_in/models/sign_in_provider.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  final AuthBloc _authBloc;
  StreamSubscription? authBlocSubscription;

  SignInCubit({
    required AuthBloc authBloc,
  })  : _authBloc = authBloc,
        super(const SignInInitial());

  final _userDataService = UserDataService();

  String email = "";
  final googleSignIn = GoogleSignIn();

  bool checkIfIsLoading(SignInProvider provider) {
    if (state is SignInLoading) {
      final authLoadingState = state as SignInLoading; // Cast to AuthLoading
      if (authLoadingState.provider == provider) {
        return true;
      }
    }
    return false;
  }

  Future<void> generalSignIn(SignInProvider provider, BuildContext context,
      [String? email, String? password]) async {
    try {
      emit(SignInLoading(provider));
      switch (provider) {
        case SignInProvider.normal:
          if (email == null) {
            emit(const SignInError(SignInErrorType.loginError));
          } else if (password == null) {
            emit(const SignInError(SignInErrorType.loginError));
          } else {
            await _authBloc.logIn(
              email: email.trim(),
              password: password,
              provider: provider,
            );
          }
          break;
        case SignInProvider.google:
          await _authBloc.logIn(
            email: null,
            password: null,
            provider: provider,
          );
          break;
        case SignInProvider.apple:
          await _authBloc.logIn(
            email: null,
            password: null,
            provider: provider,
          );
          break;
        default:
          break;
      }
      await _authBloc.checkUserType(checkTrainer: true);
      mixpanel!.track('mamba_login_completed');
      emit(const SignInInitial());
    } on EmailNotVerified {
      mixpanel!.track('mamba_login_validate_email_error');
      emit(const SignInError(SignInErrorType.validateError));
    } on EmailNotValid {
      emit(const SignInError(SignInErrorType.loginError));
    } on WrongCredentials {
      mixpanel!.track('mamba_login_notfound_error');
      emit(const SignInError(SignInErrorType.loginError));
    } on RegisterError {
      emit(const SignInError(SignInErrorType.registerError));
    } on WrongAppUser {
      emit(const SignInError(SignInErrorType.wrongAppUser));
    } on Exception {
      emit(const SignInError(SignInErrorType.loginError));
    }
  }

  void signUp(String email, String password1, BuildContext context) async {
    emit(const SignInLoading(SignInProvider.register));

    if (emailValidator(email)) {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      var result = await _userDataService.addUser(email.trim(), password1,
          Localizations.localeOf(context).languageCode, true);
      if (result == 0) {
        mixpanel!.track('mamba_register_completed');
        emit(SignInRegistered(email: email));
      } else if (result == -1) {
        mixpanel!.track('mamba_register_existing_email_error');
        emit(const SignInError(SignInErrorType.sameEmail));
      } else {
        emit(const SignInError(SignInErrorType.manualRegisterError));
      }
    } else {
      emit(const SignInError(SignInErrorType.validateErrorRegister));
    }
  }

  void signOut() {
    //emit(const AuthLogOut());
  }

  Future<void> forgotPassword(String email, BuildContext context) async {
    emit(const SignInLoading(SignInProvider.forgot));
    if (email.isEmpty) {
      emit(const SignInError(SignInErrorType.forgotEmailError));
    } else {
      if (emailValidator(email)) {
        emit(const SignInLoading(SignInProvider.forgot));
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        try {
          await _authBloc.resetPassword(email: email);
          emit(SignInForgetPassword(email: email));
        } on ResetPasswordError {
          emit(const SignInError(SignInErrorType.forgotLoginError));
        }
        //var result = await _userDataService.resetPassword(email);
      } else {
        emit(const SignInError(SignInErrorType.forgotValidateEmailError));
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
