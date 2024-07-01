import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/user/data/user_repository.dart';
part 'user_state.dart';

class UserBloc extends Cubit<UserState> {
  // Data Repositories
  final UserRepository _userRepository;

  // To be Deleted
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  // To be Deleted

  // Other Vars
  late StreamSubscription<Usuario>? _userSubscription;

  UserBloc({
    // Data Repositories
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const UserInitial());

  // Getters
  Usuario get user =>
      state is UserLoaded ? (state as UserLoaded).user : Usuario();

  // Init Bloc Function
  Future<void> initializeUser({required String userId}) async {
    // Identidy Mix Panel User
    mixpanel?.identify(userId);

    // Define Prod Config for FirebaseChatCore
    FirebaseChatCore.instance.setConfig(const FirebaseChatCoreConfig(
      null,
      'Rooms',
      'Users',
    ));

    // Get Token for FirebaseMessaging
    FirebaseMessaging.instance.getToken().then((token) {
      print("Token: $token");
      if (token != currentUser.notificationToken) {
        _userDataService.updateUserNotificationToken(userId, token!);
        print("New token updated");
      }
    });

    // Open User Details Subscription
    _userSubscription = _userRepository.getUserStream(userId: userId).listen(
      (Usuario user) async {
        // Get Brand List
        List<Brand> brands = await _brandDataService.getAllBrandsFromUser(userId);
        // Set User Brand Id
        if (brands.isNotEmpty) {
          String brandId = brands[0].id!;
          user.brandId = brandId;
        }
        // Emit Loaded State
        emit(UserLoaded(user: user));
        
        // To Be Refactored
        // Global Vars CurrentUser and CurrentBrand should not be used
        updateCurrentUserGlobalVar(user,brands);
        // To Be Refactored
      },
    );
  }

  void restoreUser() {
    // Restore User
    _userSubscription?.cancel();
    _userSubscription = null;
  }

  void updateCurrentUserGlobalVar(Usuario user, List<Brand> brands) {
    // Update Current User
    currentUser = user;
    // Set User Brand Id
    if (brands.isNotEmpty) {
      currentUser.setBrandList = brands;
      hasBrand = true;
    } else {
      hasBrand = false;
    }
  }

  void sendMixPanelDataUsers() {
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
}
