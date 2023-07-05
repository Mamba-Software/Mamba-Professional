import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/SelectCalendar/SelectCalendarDate.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/BrandPurchaseHistory/models/PurchaseHistoryModel.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/BrandPurchaseHistory/views/PurchaseCard.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../../../Data/Models/Bono.dart';
import '../../../../../../../../Data/Models/Usuario.dart';
import '../../../../../../../Data/DataService/Brand/BrandDataService.dart';
import '../../../../../../../Data/DataService/User/UserDataService.dart';
import '../../../../../../../Data/Models/Purchase.dart';
import '../../../../../../../Globals/Constants.dart';
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

  BrandPurchaseHistoryBody({Key? key, required this.brandId}) : super(key: key) ;

  void _show(BuildContext context, DateTime startDate, DateTime endDate, DateTime dateJoinedBrand) async {
    List<DateTime>? result = await showModalBottomSheet<List<DateTime>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.935,
          child: SelectCalendarDate(
            dateRange: [startDate, endDate],
            dateJoined: dateJoinedBrand,
            isFuture: false,
            acceptToday: true,
          ),
        );
      },
    );
    if (result != null) {
      context.read<BrandPurchasesCubit>().updateDateRange(result.first, result.last);
    }
  }

  String returnCorrectText(BuildContext context, DateTime startDate, DateTime endDate, DateTime dateJoinedBrand, bool acceptToday) {
    DateTime now = DateTime.now();
    DateTime maxEndDate = acceptToday ? now : now.subtract(const Duration(days: 1));

    int daysDifference = endDate.difference(startDate).inDays;
    print(daysDifference);

    // Check for "this month" selection
    if (startDate.day == 1 && startDate.month == now.month && startDate.year == now.year
        && endDate.day == maxEndDate.day && endDate.month == maxEndDate.month && endDate.year == maxEndDate.year) {
      return AppLocalizations.of(context)!.thisEventAndRest.split(" ")[0]+" "+StringUtils().toCapitalized(AppLocalizations.of(context)!.month);
    }

    // Check for "previous month" selection
    if (startDate.day == 1 && startDate.month == now.month - 1 && startDate.year == now.year
        && endDate.day == DateTime(now.year, now.month, 0).day && endDate.month == now.month - 1 && endDate.year == now.year) {
      return AppLocalizations.of(context)!.previousMonth;
    }

    // Check for "Historic" selection
    if (startDate.day == dateJoinedBrand.day && startDate.month == dateJoinedBrand.month && startDate.year == dateJoinedBrand.year
        && endDate.day == maxEndDate.day && endDate.month == maxEndDate.month && endDate.year == maxEndDate.year) {
      return AppLocalizations.of(context)!.historic;
    }

    switch (daysDifference) {
      case 7:
      case 14:
      case 30:
      case 90:
        if (maxEndDate.day == endDate.day && maxEndDate.month == endDate.month && maxEndDate.year == endDate.year) {
          return AppLocalizations.of(context)!.lastNDays(endDate.difference(startDate).inDays.toString());
        } else {
          return AppLocalizations.of(context)!.personlized;
        }
      default:
        return AppLocalizations.of(context)!.personlized;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandPurchasesCubit, BrandPurchasesState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case BrandPurchasesLoaded:
            // Handles Loaded State
            BrandPurchasesLoaded loadedState = state as BrandPurchasesLoaded;
            DateTime startDate = state.startDate;
            DateTime endDate = state.endDate;
            DateTime dateJoinedBrand = state.dateJoinedBrand;
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: MediaQuery.of(context).size.height * 0.14,
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
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04, right: MediaQuery.of(context).size.width * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  returnCorrectText(context, startDate, endDate, dateJoinedBrand, true),
                                  style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.keyboard_arrow_down_outlined, color: Theme.of(context).primaryColor)
                              ],
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.grey.withOpacity(0.1),
                              shape: RoundedRectangleBorder(  // add this
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.only(left: 16.0, right: 10.0),
                            ),
                            onPressed: () => _show(context, startDate, endDate, dateJoinedBrand),
                          ),
                          Text(
                            '${DateFormat('d MMM, yy\'').format(startDate)} - ${DateFormat('d MMM, yy\'').format(endDate)}',
                            style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              body: loadedState.purchasesHistoryObjects.isNotEmpty ? Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: loadedState.purchasesHistoryObjects.length,
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, bottom: MediaQuery.of(context).size.height*0.01),
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
                  ),
                ],
              ) : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width*0.30,
                          child: Image.asset(Constants.emptyCalendar)
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.015),
                      Text(AppLocalizations.of(context)!.noData, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
                      SizedBox(height: MediaQuery.of(context).size.height*0.1),
                    ],
                  ),
                ],
              ),
            );
          default:
            // Handle all other states aka Loading or Initial
            DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
            DateTime endDate = DateTime.now();
            DateTime dateJoinedBrand = DateTime(
              int.parse(currentBrand.dateJoined!.split("-")[2]),
              int.parse(currentBrand.dateJoined!.split("-")[1]),
              int.parse(currentBrand.dateJoined!.split("-")[0]),
              0,
              0
            );
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: MediaQuery.of(context).size.height * 0.14,
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
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04, right: MediaQuery.of(context).size.width * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  returnCorrectText(context, startDate, endDate, dateJoinedBrand, true),
                                  style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.keyboard_arrow_down_outlined, color: Theme.of(context).primaryColor)
                              ],
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.grey.withOpacity(0.1),
                              shape: RoundedRectangleBorder(  // add this
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.only(left: 16.0, right: 10.0),
                            ),
                            onPressed: () => _show(context, startDate, endDate, dateJoinedBrand),
                          ),
                          Text(
                            '${DateFormat('d MMM, yy\'').format(DateTime.now().subtract(const Duration(days: 30)))} - ${DateFormat('d MMM, yy\'').format(DateTime.now())}',
                            style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: IgnorePointer(
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.015),
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.width * 0.02),
                              child: Row(
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: AppColors.grey,
                                    highlightColor: AppColors.grey.withOpacity(0.5),
                                    child: Container(
                                      height: MediaQuery.of(context).size.width*0.15,
                                      width: MediaQuery.of(context).size.width*0.15,
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
                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                      SizedBox(height: MediaQuery.of(context).size.height*0.03),
                    ],
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}

