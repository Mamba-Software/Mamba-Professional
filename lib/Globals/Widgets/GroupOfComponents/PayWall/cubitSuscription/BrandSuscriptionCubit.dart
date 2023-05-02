import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Suscription/SuscriptionDataService.dart';
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
    final _suscriptionDataService = SuscriptionDataService();
    final _brandDataService = BrandDataService();
    Subscription subscription = Subscription();
    try {
      //Está en la antigua suscripción metodo
      if(currentBrand.adminAppUserId == null && currentBrand.subscriptionId != null) {
        subscription =
        await _brandDataService.getBrandSubscription(currentBrand.id!, currentBrand.subscriptionId!);
        setBrandActive();
        if(brandIsActive) {
          emit(BrandSuscriptionLoadedTrue(subscription));
        }
        else {
          emit(BrandSuscriptionLoadedFalse());
        }
      }
      //Nuevo metodo de suscripcion
      else {
        subscription = await _suscriptionDataService.getBrandSubscription(currentBrand.adminAppUserId!);
        if(subscription.subscriptionId == null) {
          DateTime pastDate = DateTime.now().subtract(Duration(days: 100));
          Timestamp timestamp = Timestamp.fromDate(pastDate);
          currentBrand.endDatePay = timestamp;
          setBrandActive();
          emit(BrandSuscriptionLoadedFalse());
        }
        else {
          List<StoreProduct> product = await Purchases.getProducts([subscription.subscriptionId!]);
          if(product.isNotEmpty) {
              subscription.title = product[0].description!;
              subscription.description = product[0].description;
          }

          if(!subscription.unsuscribed!) {
            currentBrand.endDatePay = Timestamp.fromDate((subscription.endDate!.toDate()).add((Duration(days: 500))));
          }
          else {
            currentBrand.endDatePay = subscription.endDate;
          }
          setBrandActive();
          emit(BrandSuscriptionLoadedTrue(subscription));
        }
      }
      /*
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
      }*/
    } catch(e) {
      emit(BrandSuscriptionLoadedFalse());
    }
  }
}