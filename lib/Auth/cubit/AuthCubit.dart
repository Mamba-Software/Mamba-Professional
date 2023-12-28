import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mamba_castelldefels/Auth/utils/enumAuth.dart';
import 'package:mamba_castelldefels/Data/AdminService/SettingsDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Globals/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
part 'AuthState.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _settingsDataService = SettingsDataService();
  final googleSignIn = GoogleSignIn();

  void generalSignIn(AuthProviderEnum provider, BuildContext context,
      [String? email, String? password]) {
    emit(AuthLoading(provider));
    switch (provider) {
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
        UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        bool userExists =
            await _userDataService.checkIfUserExists(authResult.user!.uid);
        if (userExists) {
          // Check it is no Trainer
          bool? isTrainer;
          try {
            isTrainer = await _userDataService
                .checkIfUserIsTrainer(authResult.user!.uid);
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
          bool result = await _userDataService.addUserGoogleOrApple(
              authResult, Localizations.localeOf(context).languageCode);
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
      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(oAuthCredential);
      String? fullName;
      if (credential.givenName != null && credential.familyName != null) {
        fullName = '${credential.givenName} ${credential.familyName}';
      }
      if (fullName != null) {
        await authResult.user!.updateDisplayName(fullName);
        await authResult.user!.reload();
      }
      bool userExists =
          await _userDataService.checkIfUserExists(authResult.user!.uid);
      if (userExists) {
        // Check it is no Trainer
        bool? isTrainer;
        try {
          isTrainer =
              await _userDataService.checkIfUserIsTrainer(authResult.user!.uid);
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
        bool result = await _userDataService.addUserGoogleOrApple(
            authResult, Localizations.localeOf(context).languageCode);
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

  Future<void> _signUp(
      String email, String password1, BuildContext context) async {
    var result = await _userDataService.addUser(email.trim(), password1,
        Localizations.localeOf(context).languageCode, true);
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

  Future<void> forgotPassword(
      String email, String password1, BuildContext context) async {
    if (email.isEmpty) {
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
        emit(const AuthMaintenance());
      } else {
        // 2.1 User is logged in.        
        // 3. We are in PROD or STG. We checked if email has been verified.
        if (currentFlavor == Flavor.development || (currentFlavor != Flavor.development && firebaseUser.emailVerified)) {                  
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
            emit(const AuthAdmin());
          } else {
            if (!(currentUser.isFirst!)) {
              _sendMixPanelDataUsers();
              if (hasBrand) {
                emit(AuthUserBrand(currentBrand));
              } else {
                emit(const AuthUserNoBrand());
              }
            } else {
              emit(const AuthNewUser());
            }
          }
        } else {
          // 3.1.2 Email has NOT been verified. Go back to Login.
          emit(const AuthNotLoged());
        }        
      }
    } else {
      // 2.2 User is logged NOT in. We travel to the Login
      emit(const AuthNotLoged());
    }
  }

  Future<void> _getUserData(String userId, BuildContext context) async {
    // Get Current User Main Data from Document
    try {
      currentUser = await _userDataService.getUserDetails(userId);
    } catch (e) {
      _userDataService.signOut();
      await Future.delayed(const Duration(seconds: 1));
      emit(const AuthNotLoged());
    }
    // Set App Locale To User Preferred Language
    Provider.of<LanguageProvider>(context, listen: false)
        .setLocale(Idiomas.getLocaleFromString(currentUser.idioma!));
    // Set App Theme To User Preferred Theme Settings
    if (currentUser.isDark != null) {
      print("This user has a Dark Mode: ${currentUser.isDark!}");
      Provider.of<ThemeProvider>(context, listen: false)
          .toggleTheme(currentUser.isDark!);
    }
    print("This user has the System Theme On");

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
    emit(const AuthLogOut());
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
