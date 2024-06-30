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
  Usuario get user => state is UserLoaded ? (state as UserLoaded).user : Usuario();

  // Init Bloc Function
  Future<void> initializeUser({required String userId}) async {
    // Identidy Mix Panel User
    mixpanel?.identify(userId);

    // Get User Data
    currentUser = await _userDataService.getUserDetails(userId);

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
        print("New token updated");
        _userDataService.updateUserNotificationToken(currentUser.id!, token!);
      }
    });

    /*
    // Get Brand List
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
    */

    // Open User Subscription
    _userSubscription = _userRepository.getUserStream(userId: userId).listen(
      (Usuario user) async {        
        // Stream Usuario from Database
        if (state.user != user && user != Usuario()) {
          // Get Brand List
          List<Brand> brands = await _brandDataService.getAllBrandsFromUser(userId);
          // Set User Brand Id
          if (brands.isNotEmpty) {
            user.brandID = brands[0].id!;
            currentUser.setBrandList = brands;
          }
          // Update Current User
          currentUser.setBasicData = await _userDataService.getUserDetails(userId);
          // Emit New State
          emit(state.copyWith(user: user));
        }
      },
    );
  }

  void restoreUser() {
    // Restore User
    _userSubscription?.cancel();
    _userSubscription = null;
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
