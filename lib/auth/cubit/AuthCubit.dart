import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mamba/auth/bloc/auth_bloc.dart';
import 'package:mamba/auth/models/enum_auth.dart';
import 'package:mamba/auth/models/exceptions.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/data/AdminService/SettingsDataService.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
part 'AuthState.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authBloc) : super(const AuthInitial());

  final AuthBloc _authBloc;
  StreamSubscription? authBlocSubscription;

  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _settingsDataService = SettingsDataService();
  final googleSignIn = GoogleSignIn();

  String email = "";

  Future<void> generalSignIn(AuthProviderEnum provider, BuildContext context,
      [String? email, String? password]) async {
    try {
      print('ARRIVE HERE');
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
      await _signUp(email, password1, context);
    } else {
      emit(const AuthError(AuthErrorEnum.validateErrorRegister));
    }
  }

  Future<void> _signUp(
      String email, String password1, BuildContext context) async {
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

  void checkAndGetUserDetails(BuildContext context) async {
    //_userDataService.signOut();
    // 1. We get the Firebase User
    User? firebaseUser = await _userDataService.getCurrentUser();
    // 2. Check if we have a user logged in.
    if (firebaseUser != null) {
      mixpanel?.identify(firebaseUser.uid);
      // Check If Maintenance
      var result = await _settingsDataService.checkIfIsMaintenance();
      if (result) {
        await Future.delayed(const Duration(milliseconds: 1500));
        //AuthMaintenance
      } else {
        // 2.1 User is logged in.
        // 3. We are in PROD or STG. We checked if email has been verified.
        if (flavor == Flavor.development ||
            (flavor != Flavor.development && firebaseUser.emailVerified)) {
          // 4. Define Prod Config for FirebaseChatCore
          FirebaseChatCore.instance.setConfig(const FirebaseChatCoreConfig(
            null,
            'Rooms',
            'Users',
          ));
          // 5. Load Users Data
          String userId = firebaseUser.uid;
          //String userId = "GFrVbdR5WNSuFydb8i32g620Rle2";
          await _getUserData(userId, context);
          // 6. Get Token for FirebaseMessaging
          FirebaseMessaging.instance.getToken().then((token) {
            print("Token: $token");
            if (token != currentUser.notificationToken) {
              print("New token updated");
              _userDataService.updateUserNotificationToken(
                  currentUser.id!, token!);
            }
          });
          // 7. Travel to Corresponding Screen
          if (currentUser.isAdmin!) {
            //AuthAdmin
          } else {
            if (!(currentUser.isFirst!)) {
              _sendMixPanelDataUsers();
              if (hasBrand) {
                // emit(AuthUserBrand(currentBrand));
              } else {
                // emit(const AuthUserNoBrand());
              }
            } else {
              //emit(const AuthNewUser());
            }
          }
        } else {
          // 3.1.2 Email has NOT been verified. Go back to Login.
          //emit(const AuthNotLoged());
        }
      }
    } else {
      // 2.2 User is logged NOT in. We travel to the Login
      //emit(const AuthNotLoged());
    }
  }

  Future<void> _getUserData(String userId, BuildContext context) async {
    // Get Current User Main Data from Document
    try {
      currentUser = await _userDataService.getUserDetails(userId);
    } catch (e) {
      _userDataService.signOut();
      await Future.delayed(const Duration(seconds: 1));
      //emit(const AuthNotLoged());
    }

    // Set App Locale To User Preferred Language - TO Do once user cubit is implemented
    // context.read<LanguageManager>().setLocale();
    // Set App Theme To User Preferred Theme Settings - TO Do once user cubit is implemented
    // context.read<ThemeManager>().personalizeAccentColor(AppColors.stripe);

    // Get Current User Brand, if any.
    // WAIT TO AVOID PROBLEMS DUE TO CLOUD FUNCTIONS NOT BEING INSTANTANEOUS.
    await Future.delayed(const Duration(seconds: 3));
    List<Brand> brands = await _brandDataService.getAllBrandsFromUser(userId);
    // Set the Brand List
    currentUser.setBrandList = brands;
    if (currentUser.brandsList.isNotEmpty) {
      // Put first brand to Current Brand
      Brand brand = currentUser.brandsList[0];
      currentBrand = await _brandDataService.getBrandDetails(brand.id!);
      hasBrand = true;
      print("This user has a Brand");
      mixpanel!.getPeople().set("Brands", [currentBrand.id!]);
    } else {
      // Empty Current Brand
      currentBrand = Brand();
      hasBrand = false;
      print("User with NO Brand");
      mixpanel!.getPeople().set("Brands", []);
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    await _userDataService.resendEmail(email);
  }

  void _sendMixPanelDataUsers() {
    // Send User Mix Panel Data
    mixpanel!.getPeople().set("email", currentUser.email);
    String genderString = "";
    if (currentUser.gender == 0) genderString = "Male";
    if (currentUser.gender == 1) genderString = "Female";
    if (currentUser.gender == 2) genderString = "Other";
    mixpanel!.getPeople().set("gender", genderString);
    mixpanel!.getPeople().set("language", currentUser.idioma!);
    var dateOfBirthSplit = currentUser.dateOfBirth!.split("-");
    DateTime dateOfBirth = DateTime(int.parse(dateOfBirthSplit[2]),
        int.parse(dateOfBirthSplit[1]), int.parse(dateOfBirthSplit[0]), 0, 0);
    mixpanel!.getPeople().set("dateOfBirth", dateOfBirth.toString());
    var firstLoginDateSplit = currentUser.dateJoined!.split("-");
    DateTime firstLoginDate = DateTime(
        int.parse(firstLoginDateSplit[2]),
        int.parse(firstLoginDateSplit[1]),
        int.parse(firstLoginDateSplit[0]),
        0,
        0);
    if (firstLoginDate.isBefore(DateTime(2022, 11, 15))) {
      /// Only update the First Login Date If Is Before the Mix Panel Update
      mixpanel!.getPeople().set("firstLoginDate", firstLoginDate.toString());
    }
    mixpanel!.getPeople().set("lastLoginDate", DateTime.now().toString());
  }

  void logOut() {
    //emit(const AuthLogOut());
  }

  bool checkIfIsLoading(AuthProviderEnum provider) {
    if (state is AuthLoading) {
      final authLoadingState = state as AuthLoading; // Cast to AuthLoading
      if (authLoadingState.provider == provider) {
        return true;
      }
    }
    return false;
  }
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
