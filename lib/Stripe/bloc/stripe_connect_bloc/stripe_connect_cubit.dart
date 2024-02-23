import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Stripe/Data/data_repository/stripe_connect_data_provider.dart';
import 'package:mamba_castelldefels/Stripe/Data/data_repository/stripe_connect_repository.dart';
part 'stripe_connect_state.dart';

class StripeConnectCubit extends Cubit<StripeConnectState> {
  StripeConnectCubit() : super(StripeConnectInitial());
  Brand brand = Brand();
  StripeConnectRepository stripeConnectRepository = StripeConnectRepository();
  final BrandDataService _brandDataService = BrandDataService();

  Future<void> getLink(Brand trainerData) async {
    brand = trainerData;
    emit(StripeConnectGettingLink());
    (String?, String?) result =
        await stripeConnectRepository.createAccount(brand);
    if (result.$1 != null) {      
      print("Get Link");
      print(result.$1);
      emit(StripeConnectGetLinkSuccess(result.$1!));
    } else {
      emit(StripeConnectGetLinkError(result.$2!));
    }
  }

  void createAccountApi(Brand trainerData) async {
    try {
      http.Response result =
          await StripeConnectDataProvider.createStripeAccount(trainerData);

      if (result.statusCode == 200) {
        var bodyData = jsonDecode(result.body);
        String? url = bodyData['url'];
        if (url != null && url != '') {}
      }
    } catch (e) {
      print('d');
    }
  }

  getUser() async {
    emit(Loading());
    brand = await _brandDataService.getBrandDetails(brand.id!);
    emit(StripeConnectSuccess(brand));
  }
}
