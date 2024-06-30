import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/brand/data/brand_repository.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
part 'brand_state.dart';

class BrandBloc extends Cubit<BrandState> {
  // Data Repositories
  final BrandRepository _brandRepository;

  // State Blocs
  final UserBloc _userBloc;

  // Other Vars

  StreamSubscription? userBlocSubscription;

  StreamSubscription<Brand>? brandSubscription;

  final _brandDataService = BrandDataService();

  BrandBloc({
    // Data Repositories
    required BrandRepository brandRepository,
    // State Blocs
    required UserBloc userBloc,
  })  : _brandRepository = brandRepository,
        _userBloc = userBloc,
        super(BrandState(brand: Brand())) {
    initializeBrand();
  }

  // Getters
  Usuario get user => _userBloc.state.user!;
  String get brandId => state.brand.id!;

  Brand get brand => state.brand;

  List<Usuario> get getBrandTrainers => [];

  // Init Bloc Function

  void initializeBrand() {
    // Assuming Brand.empty() is a valid initializer for an empty Brand
    // Listen to changes in the UserBloc
    userBlocSubscription = _userBloc.stream.listen((userState) {
      if (userState.user.id != '') {
        if (userState.user.brandID == '') {
          emit(state.copyWith(brand: Brand()));
        } else {
          brandSubscription =
              _brandRepository.getBrandStream(brandId: brandId).listen(
            (brand) async {
              if (state.brand != brand && brand != Brand()) {
                await getBrandUser(brand.id!, user.id!);
                currentBrand.id = brand.id!;
                currentBrand.setBasicData = brand;
                currentBrand.brandActive = setBrandActive();
                emit(state.copyWith(brand: brand));
              }
            },
          );
        }
      } else {
        restoreBrand();
      }
    });
  }

  Future<void> getBrandUser(String brandId, String userId) async {
    currentBrand.setUserList = await _brandDataService.getBrandUsers(brandId);

    int role = await _brandDataService.getUserBrandRole(brandId, userId);
    currentUser.setBrandRole = role;
    if (currentUser.id == currentBrand.adminID) {
      Purchases.logIn(currentBrand.id!);
    }
    mixpanel!.getPeople().set("Brands Roles", [role]);
  }

  void restoreBrand() {
    brandSubscription?.cancel();
    brandSubscription = null;
  }

  @override
  Future<void> close() {
    brandSubscription?.cancel();
    return super.close();
  }
}
