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
    Stream<DocumentSnapshot<Object?>> getBrandSubscriptionStream(String userId) {
      final _brandDataService = BrandDataService();
      return _brandDataService.getBrandSubscriptionStream(currentBrand.id!);
    }

    getBrandSubscriptionStream(currentBrand.id!).listen((querySnapshot) async {
      DocumentSnapshot document = querySnapshot;
      getBrandSuscription(document);
    });
  }

  Future<void> getBrandSuscription(DocumentSnapshot document) async {
    DateFormat formatter = DateFormat('dd/MM/yy');
    Brand brand = new Brand();
    brand = Brand.fromObjectAllData(document.id, document);
    final _suscriptionDataService = SuscriptionDataService();
    final _brandDataService = BrandDataService();
    Subscription subscription = Subscription();
    try {
      //Está en la antigua suscripción metodo
      if(brand.subscription == null) {
        currentBrand.subscription = null;
        if(brand.subscriptionId != null) {
          currentBrand.subscriptionId = brand.subscriptionId;
          if(brand.endDatePay != null) {
              currentBrand.endDatePay = brand.endDatePay;
          }
          subscription =
          await _brandDataService.getBrandSubscription(currentBrand.id!, currentBrand.subscriptionId!);
          subscription.unsuscribed = true;
          setBrandActive();
          if(brandIsActive) {
            emit(BrandSuscriptionLoadedTrue(subscription));
          }
          else {
            emit(BrandSuscriptionLoadedFalse());
          }
        }
        else {
          emit(BrandSuscriptionLoadedFalse());
        }

      }
      //Nuevo metodo de suscripcion
      else {
        currentBrand.subscription = brand.subscription!;
        setBrandActive();
        if(brandIsActive) {

          subscription.title = currentBrand.subscription!['product_plan_identifier'];
          subscription.description = currentBrand.subscription!['product_plan_identifier'];
          subscription.subscriptionId = currentBrand.subscription!['product_plan_identifier'];
          subscription.endDate = Timestamp.fromDate(DateTime.parse(currentBrand.subscription!['expires_date'].toString()));
          subscription.startDate = Timestamp.fromDate(DateTime.parse(currentBrand.subscription!['original_purchase_date'].toString()));
          subscription.unsuscribed = currentBrand.subscription!['unsuscribed'];

          List<StoreProduct> product = await Purchases.getProducts([subscription.subscriptionId!]);
          if(product.isNotEmpty) {
            subscription.title = product[0].description;
            if(subscription.title == 'month_sub') {
              subscription.title = 'Month plan';
            }
            subscription.description = product[0].description;
            if(subscription.description == 'month_sub') {
              subscription.description = 'Month plan';
            }
          }
          emit(BrandSuscriptionLoadedTrue(subscription));
        }
        else {
          emit(BrandSuscriptionLoadedFalse());
        }
      }
    } catch(e) {
      print(e);
      emit(BrandSuscriptionLoadedFalse());
    }
  }
}