import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/brand/bloc/brand_bloc.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Suscription/SuscriptionDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Subscription.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
part 'BrandSuscriptionState.dart';

class BrandSuscriptionCubit extends Cubit<BrandSuscriptionState>
    with PlatformMixin {
  BrandSuscriptionCubit(final BrandBloc brandBloc)
      : super(const BrandSuscriptionInitial()) {
    try {
      initialize();
      brandBloc.stream.distinct().listen((state) {
        // Handle the state change
        if (state.brand.id != null && state.brand.id != '') {
          // Listen to Subscription Change
          getBrandSubscriptionStream(currentBrand.id!).listen(
            (querySnapshot) async {
              DocumentSnapshot document = querySnapshot;
              getBrandSuscription(document);
            },
          );
        } else {
          //_streamBrandSuscription.cancel();
        }
      });
    } catch (e) {
      emit(const BrandSuscriptionLoadedFalse());
    }
  }

  Future<void> initialize() async {
    // Init Revenue Cat
    if (isAndroid) {
      PurchasesConfiguration configuration = PurchasesConfiguration(
        dotenv.env['REVCAT_GOOGLE_API_KEY']!,
      );
      await Purchases.configure(configuration);
    } else if (isIOS) {
      PurchasesConfiguration configuration = PurchasesConfiguration(
        dotenv.env['REVCAT_APPLE_API_KEY']!,
      );
      await Purchases.configure(configuration);
    }
    // Set Log Level
    if (flavor != Flavor.development) {
      await Purchases.setLogLevel(LogLevel.info);
    }
  }

  Stream<DocumentSnapshot<Object?>> getBrandSubscriptionStream(String userId) {
    final brandDataService = BrandDataService();
    return brandDataService.getBrandSubscriptionStream(currentBrand.id!);
  }

  Future<void> getBrandSuscription(DocumentSnapshot document) async {
    DateFormat formatter = DateFormat('dd/MM/yy');
    Brand brand = Brand();
    brand = Brand.fromObjectAllData(document.id, document);
    final suscriptionDataService = SuscriptionDataService();
    final brandDataService = BrandDataService();
    Subscription subscription = Subscription();
    try {
      //Está en la antigua suscripción metodo
      if (brand.subscription == null) {
        currentBrand.subscription = null;
        if (brand.subscriptionId != null) {
          currentBrand.subscriptionId = brand.subscriptionId;
          if (brand.endDatePay != null) {
            currentBrand.endDatePay = brand.endDatePay;
          }
          subscription = await brandDataService.getBrandSubscription(
              currentBrand.id!, currentBrand.subscriptionId!);
          subscription.unsuscribed = true;
          setBrandActive();
          if (brandIsActive) {
            emit(BrandSuscriptionLoadedTrue(subscription));
          } else {
            emit(const BrandSuscriptionLoadedFalse());
          }
        } else {
          emit(const BrandSuscriptionLoadedFalse());
        }
      }
      //Nuevo metodo de suscripcion
      else {
        currentBrand.subscription = brand.subscription!;
        setBrandActive();
        if (brandIsActive) {
          subscription.title =
              currentBrand.subscription!['product_plan_identifier'];
          subscription.description =
              currentBrand.subscription!['product_plan_identifier'];
          subscription.subscriptionId =
              currentBrand.subscription!['product_plan_identifier'];
          subscription.endDate = Timestamp.fromDate(DateTime.parse(
              currentBrand.subscription!['expires_date'].toString()));
          subscription.startDate = Timestamp.fromDate(DateTime.parse(
              currentBrand.subscription!['original_purchase_date'].toString()));
          subscription.unsuscribed = currentBrand.subscription!['unsuscribed'];

          List<StoreProduct> product =
              await Purchases.getProducts([subscription.subscriptionId!]);
          if (product.isNotEmpty) {
            subscription.title = product[0].description;
            if (subscription.title == 'month_sub') {
              subscription.title = 'Plan Mensual';
            }
            subscription.description = product[0].description;
            if (subscription.description == 'month_sub') {
              subscription.description = 'Plan Mensual';
            }
          }
          emit(BrandSuscriptionLoadedTrue(subscription));
        } else {
          emit(const BrandSuscriptionLoadedFalse());
        }
      }
    } catch (e) {
      print(e);
      emit(const BrandSuscriptionLoadedFalse());
    }
  }
}
