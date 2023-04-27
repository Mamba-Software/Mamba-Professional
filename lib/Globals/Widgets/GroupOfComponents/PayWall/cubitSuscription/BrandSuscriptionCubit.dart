import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'BrandSuscriptionState.dart';

class BrandSuscriptionCubit extends Cubit<BrandSuscriptionState> {

  BrandSuscriptionCubit() : super(BrandSuscriptionInitial()) {
    getBrandSuscription();
  }

  Future<void> getBrandSuscription() async {
    DateFormat formatter = DateFormat('dd/MM/yy');
    Brand brand = new Brand();
    final _brandDataService = BrandDataService();
    Subscription subscription = Subscription();
    try {
      if(brandIsActive && currentBrand.subscriptionId != null) {
        subscription =
        await _brandDataService.getBrandSubscription(currentBrand.id!, currentBrand.subscriptionId!);
        if(subscription.isRevenueCat != null) {
          if(subscription.isRevenueCat == true) {
            if(userIsAdmin) {
              currentUser.customerInfo = await Purchases.getCustomerInfo();
              print(currentUser.customerInfo);
            }
            setBrandActive(false);
            print('brand');
            if(brandIsActive) {
              emit(BrandSuscriptionLoadedTrue(subscription));
            }
            else {
              emit(BrandSuscriptionLoadedFalse());
            }
          }
        }
        else {
          setBrandActive(true);
          if(brandIsActive) {
            emit(BrandSuscriptionLoadedTrue(subscription));
          }
          else {
            emit(BrandSuscriptionLoadedFalse());
          }
        }
      }
      else {
        emit(BrandSuscriptionLoadedFalse());
      }
    } catch(e) {
      emit(BrandSuscriptionLoadedFalse());
    }
  }
}