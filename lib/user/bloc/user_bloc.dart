import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mamba/auth/models/auth_user.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/settings/data/settings_repository.dart';
import 'package:mamba/user/data/user_repository.dart';
part 'user_state.dart';

class UserBloc extends Cubit<UserState> {
  // Data Repositories
  final UserRepository _userRepository;
  final SettingsRepository _settingsRepository;

  // To be Deleted
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  String userId;
  String brandId;
  // To be Deleted

  // Other Vars
  late StreamSubscription<Usuario>? _userSubscription;

  UserBloc({
    // Data Repositories
    required UserRepository userRepository,
    required SettingsRepository settingsRepository,
  })  : userId = '',
        brandId = '',
        _userRepository = userRepository,
        _settingsRepository = settingsRepository,
        super(UserState(user: Usuario()));

  void initializeUser({required String userId}) {
    // Set User Id
    this.userId = userId;
    // Check and Get User Details
    checkAndGetUserDetails();
    // Open User Subscription
    _userSubscription = _userRepository.getUserStream(userId: userId).listen(
      (Usuario user) async {
        // Stream Usuario from DataBase
        if (state.user != user && user != AuthUser.empty) {
          List<Brand> brands =
              await _brandDataService.getAllBrandsFromUser(userId);
          if (brands.isNotEmpty) {
            user.brandID = brands[0].id!;
            currentUser.setBrandList = brands;
          } else {
            user.brandID = 'none';
          }
          currentUser.setBasicData =
              await _userDataService.getUserDetails(userId);
          brandId = user.brandID!;
          emit(state.copyWith(user: user));
        }
      },
    );
  }

  void restoreUser() {
    // Restore User
    userId = '';
    _userSubscription?.cancel();
    _userSubscription = null;
  }

  void checkAndGetUserDetails() async {
    // 1. We get the Firebase User
    User? firebaseUser = await _userDataService.getCurrentUser();
    // 2. Check if we have a user logged in.
    if (firebaseUser != null) {
      mixpanel?.identify(firebaseUser.uid);
      // Check If Maintenance
      var result = await _settingsRepository.checkIfIsMaintenance();
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
          await _getUserData(userId);
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

  Future<void> _getUserData(String userId) async {
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

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
