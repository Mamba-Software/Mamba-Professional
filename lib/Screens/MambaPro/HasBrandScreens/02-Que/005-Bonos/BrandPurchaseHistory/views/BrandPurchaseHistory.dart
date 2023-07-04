import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/BrandPurchaseHistory/models/PurchaseHistoryModel.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/BrandPurchaseHistory/views/PurchaseCard.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../../../Data/Models/Bono.dart';
import '../../../../../../../../Data/Models/Usuario.dart';
import '../../../../../../../Data/DataService/Brand/BrandDataService.dart';
import '../../../../../../../Data/DataService/User/UserDataService.dart';
import '../../../../../../../Data/Models/Purchase.dart';
import '../cubit/BrandPurchasesCubit.dart';

class BrandPurchaseHistory extends StatelessWidget {
  final String brandId;

  const BrandPurchaseHistory({Key? key, required this.brandId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BrandPurchasesCubit>(
      create: (context) => BrandPurchasesCubit(brandId),
      child: BrandPurchaseHistoryBody(brandId: brandId),
    );
  }
}

class BrandPurchaseHistoryBody extends StatelessWidget {

  final String brandId;

  const BrandPurchaseHistoryBody({Key? key, required this.brandId}) : super(key: key) ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.purchaseHistory,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<BrandPurchasesCubit, BrandPurchasesState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case BrandPurchasesLoaded:
              // Handles Loaded State
              BrandPurchasesLoaded loadedState = state as BrandPurchasesLoaded;
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: loadedState.purchasesHistoryObjects.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          PurchaseHistoryModel obj = loadedState.purchasesHistoryObjects[index];
                          return PurchaseCard(
                            bono: obj.bono,
                            user: obj.user,
                            brand: obj.brand,
                            bonoRequest: obj.bonoReq,
                            purchase: obj.purchase,
                          );
                        }
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.03),
                  ],
                ),
              );
            default:
              // Handle all other states aka Loading or Initial
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.width * 0.04),
                            child: Row(
                              children: [
                                Shimmer.fromColors(
                                  baseColor: AppColors.grey,
                                  highlightColor: AppColors.grey.withOpacity(0.5),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height*0.08,
                                    width: MediaQuery.of(context).size.height*0.08,
                                    decoration: const BoxDecoration(
                                      color: AppColors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.04), // adjust this value as needed
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      /// USER
                                      Shimmer.fromColors(
                                        baseColor: AppColors.grey,
                                        highlightColor: AppColors.grey.withOpacity(0.5),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height*0.02,
                                          width: MediaQuery.of(context).size.width*0.25,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5.0),
                                            ),
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                                      /// BONO
                                      Shimmer.fromColors(
                                        baseColor: AppColors.grey,
                                        highlightColor: AppColors.grey.withOpacity(0.5),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height*0.015,
                                          width: MediaQuery.of(context).size.width*0.45,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5.0),
                                            ),
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                                      /// DETAILS
                                      Shimmer.fromColors(
                                        baseColor: AppColors.grey,
                                        highlightColor: AppColors.grey.withOpacity(0.5),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height*0.015,
                                          width: MediaQuery.of(context).size.width*0.55,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5.0),
                                            ),
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                                      /// STATUS
                                      Shimmer.fromColors(
                                        baseColor: AppColors.grey,
                                        highlightColor: AppColors.grey.withOpacity(0.5),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height*0.015,
                                          width: MediaQuery.of(context).size.width*0.3,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5.0),
                                            ),
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                                      /// DATE
                                      Shimmer.fromColors(
                                        baseColor: AppColors.grey,
                                        highlightColor: AppColors.grey.withOpacity(0.5),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height*0.013,
                                          width: MediaQuery.of(context).size.width*0.25,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5.0),
                                            ),
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.015),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

