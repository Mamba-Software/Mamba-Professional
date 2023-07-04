import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
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
      child: _BrandPurchaseHistoryBody(brandId: brandId),
    );
  }
}

class _BrandPurchaseHistoryBody extends StatelessWidget {

  final String brandId;

  _BrandPurchaseHistoryBody({Key? key, required this.brandId}) : super(key: key);


  // Data Base Access
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();

  Widget returnBonoRequest(BonoRequest _bonoRequest, var user, var bono) {
    Usuario _user = user;
    Bono _bono = bono;
    return PurchaseCard(
      bono: _bono,
      user: _user,
      brand: currentBrand,
      bonoRequest: _bonoRequest,
      purchase: Purchase(),
    );
  }

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
                    SizedBox(height: MediaQuery.of(context).size.height*0.03),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                          child: Text(
                            AppLocalizations.of(context)!.bonoRequestDescription,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.015),
                    ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: loadedState.brandBonoRequests.length,
                        itemExtent: MediaQuery.of(context).size.height*0.12,
                        itemBuilder: (context, index) {
                          BonoRequest bonoRequest = loadedState.brandBonoRequests[index];
                          return Column(
                            children: [
                              index == 0 ? const SizedBox(height: 4) : Container(),
                              FutureBuilder(
                                  future: _userDataService.getUserDetails(bonoRequest.userId!),
                                  // Run check for a single queryRow
                                  builder: (context, snapshot) {
                                    if (snapshot.data != null) {
                                      Object? user = snapshot.data;
                                      return FutureBuilder(
                                          future: _brandDataService.getBonoInfo(brandId, bonoRequest.bonoId!),
                                          // Run check for a single queryRow
                                          builder: (context, snapshot) {
                                            if (snapshot.data != null) {
                                              return returnBonoRequest(
                                                  bonoRequest,
                                                  user,
                                                  snapshot.data
                                              );
                                            } else {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                child: ListTile(
                                                  dense: true,
                                                  leading: Shimmer.fromColors(
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
                                                  title: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Shimmer.fromColors(
                                                        baseColor: AppColors.grey,
                                                        highlightColor: AppColors.grey.withOpacity(0.5),
                                                        child: Container(
                                                          height: MediaQuery.of(context).size.height*0.02,
                                                          width: MediaQuery.of(context).size.width*0.2,
                                                          decoration: const BoxDecoration(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(5.0),
                                                            ),
                                                            color: AppColors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                      Shimmer.fromColors(
                                                        baseColor: AppColors.grey,
                                                        highlightColor: AppColors.grey.withOpacity(0.5),
                                                        child: Container(
                                                          height: MediaQuery.of(context).size.height*0.02,
                                                          width: MediaQuery.of(context).size.width*0.4,
                                                          decoration: const BoxDecoration(
                                                            color: AppColors.grey,
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(5.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: Shimmer.fromColors(
                                                    baseColor: AppColors.grey,
                                                    highlightColor: AppColors.grey.withOpacity(0.5),
                                                    child: Container(
                                                      height: MediaQuery.of(context).size.height*0.05,
                                                      width: MediaQuery.of(context).size.height*0.08,
                                                      decoration: const BoxDecoration(
                                                        color: AppColors.grey,
                                                        borderRadius: BorderRadius.all(
                                                          Radius.circular(10.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: null,
                                                ),
                                              );
                                            }
                                          }
                                      );
                                    } else {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                                        child: ListTile(
                                          dense: true,
                                          leading: Shimmer.fromColors(
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
                                          title: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Shimmer.fromColors(
                                                baseColor: AppColors.grey,
                                                highlightColor: AppColors.grey.withOpacity(0.5),
                                                child: Container(
                                                  height: MediaQuery.of(context).size.height*0.02,
                                                  width: MediaQuery.of(context).size.width*0.2,
                                                  decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                    color: AppColors.grey,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                              Shimmer.fromColors(
                                                baseColor: AppColors.grey,
                                                highlightColor: AppColors.grey.withOpacity(0.5),
                                                child: Container(
                                                  height: MediaQuery.of(context).size.height*0.02,
                                                  width: MediaQuery.of(context).size.width*0.4,
                                                  decoration: const BoxDecoration(
                                                    color: AppColors.grey,
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Shimmer.fromColors(
                                            baseColor: AppColors.grey,
                                            highlightColor: AppColors.grey.withOpacity(0.5),
                                            child: Container(
                                              height: MediaQuery.of(context).size.height*0.05,
                                              width: MediaQuery.of(context).size.height*0.08,
                                              decoration: const BoxDecoration(
                                                color: AppColors.grey,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          onTap: null,
                                        ),
                                      );
                                    }
                                  }
                              ),
                              index == loadedState.brandBonoRequests.length-1 ? SizedBox(height: MediaQuery.of(context).size.width * 0.02) : Container(),
                            ],
                          );
                        }
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                          child: Text(
                            AppLocalizations.of(context)!.bonoRequestDescription,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.015),
                    ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: loadedState.brandBonoRequests.length,
                        itemExtent: MediaQuery.of(context).size.height*0.13,
                        itemBuilder: (context, index) {
                          BonoRequest bonoRequest = loadedState.brandBonoRequests[index];
                          return Column(
                            children: [
                              index == 0 ? const SizedBox(height: 4) : Container(),
                              FutureBuilder(
                                  future: _userDataService.getUserDetails(bonoRequest.userId!),
                                  // Run check for a single queryRow
                                  builder: (context, snapshot) {
                                    if (snapshot.data != null) {
                                      Object? user = snapshot.data;
                                      return FutureBuilder(
                                          future: _brandDataService.getBonoInfo(brandId, bonoRequest.bonoId!),
                                          // Run check for a single queryRow
                                          builder: (context, snapshot) {
                                            if (snapshot.data != null) {
                                              return returnBonoRequest(
                                                  bonoRequest,
                                                  user,
                                                  snapshot.data
                                              );
                                            } else {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                child: ListTile(
                                                  dense: true,
                                                  leading: Shimmer.fromColors(
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
                                                  title: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Shimmer.fromColors(
                                                        baseColor: AppColors.grey,
                                                        highlightColor: AppColors.grey.withOpacity(0.5),
                                                        child: Container(
                                                          height: MediaQuery.of(context).size.height*0.02,
                                                          width: MediaQuery.of(context).size.width*0.2,
                                                          decoration: const BoxDecoration(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(5.0),
                                                            ),
                                                            color: AppColors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                      Shimmer.fromColors(
                                                        baseColor: AppColors.grey,
                                                        highlightColor: AppColors.grey.withOpacity(0.5),
                                                        child: Container(
                                                          height: MediaQuery.of(context).size.height*0.02,
                                                          width: MediaQuery.of(context).size.width*0.4,
                                                          decoration: const BoxDecoration(
                                                            color: AppColors.grey,
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(5.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: Shimmer.fromColors(
                                                    baseColor: AppColors.grey,
                                                    highlightColor: AppColors.grey.withOpacity(0.5),
                                                    child: Container(
                                                      height: MediaQuery.of(context).size.height*0.05,
                                                      width: MediaQuery.of(context).size.height*0.08,
                                                      decoration: const BoxDecoration(
                                                        color: AppColors.grey,
                                                        borderRadius: BorderRadius.all(
                                                          Radius.circular(10.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: null,
                                                ),
                                              );
                                            }
                                          }
                                      );
                                    } else {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                                        child: ListTile(
                                          dense: true,
                                          leading: Shimmer.fromColors(
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
                                          title: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Shimmer.fromColors(
                                                baseColor: AppColors.grey,
                                                highlightColor: AppColors.grey.withOpacity(0.5),
                                                child: Container(
                                                  height: MediaQuery.of(context).size.height*0.02,
                                                  width: MediaQuery.of(context).size.width*0.2,
                                                  decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                    color: AppColors.grey,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                              Shimmer.fromColors(
                                                baseColor: AppColors.grey,
                                                highlightColor: AppColors.grey.withOpacity(0.5),
                                                child: Container(
                                                  height: MediaQuery.of(context).size.height*0.02,
                                                  width: MediaQuery.of(context).size.width*0.4,
                                                  decoration: const BoxDecoration(
                                                    color: AppColors.grey,
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Shimmer.fromColors(
                                            baseColor: AppColors.grey,
                                            highlightColor: AppColors.grey.withOpacity(0.5),
                                            child: Container(
                                              height: MediaQuery.of(context).size.height*0.05,
                                              width: MediaQuery.of(context).size.height*0.08,
                                              decoration: const BoxDecoration(
                                                color: AppColors.grey,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          onTap: null,
                                        ),
                                      );
                                    }
                                  }
                              ),
                              index == loadedState.brandBonoRequests.length-1 ? SizedBox(height: MediaQuery.of(context).size.width * 0.02) : Container(),
                            ],
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
                        itemExtent: MediaQuery.of(context).size.height*0.09,
                        itemBuilder: (context, index) {
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
                            leading: Shimmer.fromColors(
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
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Shimmer.fromColors(
                                  baseColor: AppColors.grey,
                                  highlightColor: AppColors.grey.withOpacity(0.5),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height*0.02,
                                    width: MediaQuery.of(context).size.width*0.2,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                Shimmer.fromColors(
                                  baseColor: AppColors.grey,
                                  highlightColor: AppColors.grey.withOpacity(0.5),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height*0.02,
                                    width: MediaQuery.of(context).size.width*0.4,
                                    decoration: const BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Shimmer.fromColors(
                              baseColor: AppColors.grey,
                              highlightColor: AppColors.grey.withOpacity(0.5),
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.03,),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.all(0),
                                onPressed: null,
                              ),
                            ),
                            onTap: null,
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

