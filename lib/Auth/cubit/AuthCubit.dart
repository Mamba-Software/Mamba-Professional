import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mamba_castelldefels/Auth/utils/enumAuth.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'AuthState.dart';


class AuthCubit extends Cubit<AuthState> {

  AuthCubit() : super(const AuthInitial());

  final _userDataService = UserDataService();
  List<Event> finishedEventsList = [];
  List<Event> upcomingEventsList = [];
  late StreamSubscription<QuerySnapshot> _subscription;
  final googleSignIn = GoogleSignIn();

  void generalSignIn(AuthProviderEnum provider, BuildContext context, [String? email, String? password]) {
    emit(AuthLoading(provider));
    switch(provider) {
      case AuthProviderEnum.normal:
          _signIn(email!, password!);
        break;
      case AuthProviderEnum.google:
          _signInWithGoogle(context);
        break;
      case AuthProviderEnum.apple:
          _signInWithApple(context);
        break;
      case AuthProviderEnum.register:
        // TODO: Handle this case.
        break;
      case AuthProviderEnum.forgot:
        // TODO: Handle this case.
        break;
    }
  }

  void _signIn(String email, String password) async {
    int result = await _userDataService.signIn(email.trim(), password);
    if (result == 0) {
      User? user = await _userDataService.getCurrentUser();
      bool? isTrainer;
      try {
        isTrainer = await _userDataService.checkIfUserIsTrainer(user!.uid);
        if (isTrainer != null && isTrainer == false) {
          await _userDataService.signOut();
          mixpanel!.track('mamba_login_wrong_app_error');
          emit(const AuthError(AuthErrorEnum.wrongAppUser));
        } else {
          mixpanel!.track('mamba_login_completed');
          emit(const AuthLoaded());
        }
      } catch (e) {
        emit(const AuthError(AuthErrorEnum.loginError));
      }
    } else if (result == -1) {
      mixpanel!.track('mamba_login_notfound_error');
      //email = emailTemp;
      emit(const AuthError(AuthErrorEnum.loginError));
    } else if (result == -2) {
      mixpanel!.track('mamba_login_validate_email_error');
      emit(const AuthError(AuthErrorEnum.validateError));
    }
  }

  void _signInWithGoogle(BuildContext context) async {
    try {
      final user = await googleSignIn.signIn();
      if (user == null) {
        emit(const AuthError(AuthErrorEnum.loginError));
      } else {
        final googleAuth = await user.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
        bool userExists = await _userDataService.checkIfUserExists(authResult.user!.uid);
        if (userExists) {
          // Check it is no Trainer
          bool? isTrainer;
          try {
            isTrainer = await _userDataService.checkIfUserIsTrainer(authResult.user!.uid);
            if (isTrainer != null && isTrainer == false) {
              await _userDataService.signOut();
              await googleSignIn.signOut();
              emit(const AuthError(AuthErrorEnum.wrongAppUser));
            } else {
              mixpanel!.track('mamba_google_login_completed');
              emit(const AuthLoaded());
            }
          } catch (e) {
            emit(const AuthError(AuthErrorEnum.loginError));
          }
        } else {
          // Create an account and a user for this new person from google
          bool result = await _userDataService.addUserGoogleOrApple(authResult, Localizations.localeOf(context).languageCode);
          if (result) {
            mixpanel!.track('mamba_google_register_completed');
            emit(const AuthLoaded());
          } else {
            emit(const AuthError(AuthErrorEnum.loginError));
          }
        }
      }
    } catch (e) {
      emit(const AuthError(AuthErrorEnum.registerError));
    }
  }

  void _signInWithApple(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oAuthProvider = OAuthProvider('apple.com');
      final oAuthCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(oAuthCredential);
      String? fullName;
      if (credential.givenName != null && credential.familyName != null) {
        fullName = '${credential.givenName} ${credential.familyName}';
      }
      if (fullName != null) {
        await authResult.user!.updateDisplayName(fullName);
        await authResult.user!.reload();
      }
      bool userExists = await _userDataService.checkIfUserExists(authResult.user!.uid);
      if (userExists) {
        // Check it is no Trainer
        bool? isTrainer;
        try {
          isTrainer = await _userDataService.checkIfUserIsTrainer(authResult.user!.uid);
          if (isTrainer != null && isTrainer == false) {
            await _userDataService.signOut();
            emit(const AuthError(AuthErrorEnum.wrongAppUser));
          } else {
            mixpanel!.track('mamba_apple_login_completed');
            emit(const AuthLoaded());
          }
        } catch (e) {
          emit(const AuthError(AuthErrorEnum.loginError));
        }
      } else {
        // Create an account and a user for this new person from Apple
        bool result = await _userDataService.addUserGoogleOrApple(authResult, Localizations.localeOf(context).languageCode);
        if (result) {
          mixpanel!.track('mamba_apple_register_completed');
          emit(const AuthLoaded());
        } else {
          emit(const AuthError(AuthErrorEnum.loginError));
        }
      }
    } catch (e) {
      print(e.toString());
      emit(const AuthError(AuthErrorEnum.registerError));
    }
  }

  void signUp(String email, String password1, BuildContext context) async {
    emit(const AuthLoading(AuthProviderEnum.register));

    if (emailValidator(email)) {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      await _signUp(email, password1, context);
    } else {
      emit(const AuthError(AuthErrorEnum.validateErrorRegister));

    }
  }
  Future<void> _signUp(String email, String password1, BuildContext context) async {
    var result =  await _userDataService.addUser(email.trim(), password1, Localizations.localeOf(context).languageCode, true);
    if (result == 0) {
      mixpanel!.track('mamba_register_completed');
      emit(const AuthRegistered());
    } else if (result == -1) {
      mixpanel!.track('mamba_register_existing_email_error');
      emit(const AuthError(AuthErrorEnum.sameEmail));
    } else {
      emit(const AuthError(AuthErrorEnum.manualRegisterError));
    }
  }

  Future<void> forgotPassword(String email, String password1, BuildContext context) async {
    if(email.isEmpty) {
      emit(const AuthError(AuthErrorEnum.forgotEmailError));
    } else {
      if (emailValidator(email)) {
        emit(const AuthLoading(AuthProviderEnum.forgot));
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        var result = await _userDataService.resetPassword(email);
        if (result == 1) {
          emit(const AuthCorrectForget());
        } else {
          emit(const AuthError(AuthErrorEnum.forgotLoginError));
        }
      }
      else {
        emit(const AuthError(AuthErrorEnum.forgotValidateEmailError));
      }
    }
  }



}

// Validate email and pwd format
bool emailValidator(String value) {
  Pattern pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
  RegExp regex = RegExp(pattern.toString());
  if (!regex.hasMatch(value)) {
    return false;
  } else {
    return true;
  }
}
