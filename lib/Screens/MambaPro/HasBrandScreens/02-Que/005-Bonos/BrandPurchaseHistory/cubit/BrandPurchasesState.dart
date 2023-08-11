part of 'BrandPurchasesCubit.dart';

abstract class BrandPurchasesState extends Equatable {
  const BrandPurchasesState();
}

class BrandPurchasesInitial extends BrandPurchasesState {
  const BrandPurchasesInitial();

  @override
  List<Object?> get props => [];
}

class BrandPurchasesLoading extends BrandPurchasesState {
  const BrandPurchasesLoading();

  @override
  List<Object?> get props => [];
}

class BrandPurchasesLoaded extends BrandPurchasesState {
  DateTime startDate;
  DateTime endDate;
  DateTime dateJoinedBrand;
  List<PurchaseHistoryModel> purchasesHistoryObjects;
  bool orderByDescending;
  List<bool> filterByPurchaseStatus;
  List<bool> filterByActivePurchases;
  bool forceRebuild;

  BrandPurchasesLoaded({
    required this.startDate,
    required this.endDate,
    required this.dateJoinedBrand,
    required this.purchasesHistoryObjects,
    required this.orderByDescending,
    required this.filterByPurchaseStatus,
    required this.filterByActivePurchases,
    required this.forceRebuild,
  });

  BrandPurchasesLoaded copyWith({
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dateJoinedBrand,
    List<PurchaseHistoryModel>? purchasesHistoryObjects,
    bool? orderByDescending,
    List<bool>? filterByPurchaseStatus,
    List<bool>? filterByActivePurchases,
    bool? forceRebuild,
  }) {
    return BrandPurchasesLoaded(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dateJoinedBrand: dateJoinedBrand ?? this.dateJoinedBrand,
      purchasesHistoryObjects: purchasesHistoryObjects ?? this.purchasesHistoryObjects,
      orderByDescending: orderByDescending ?? this.orderByDescending,
      filterByPurchaseStatus: filterByPurchaseStatus ?? this.filterByPurchaseStatus,
      filterByActivePurchases: filterByActivePurchases ?? this.filterByActivePurchases,
      forceRebuild: forceRebuild ?? this.forceRebuild,
    );
  }

  @override
  List<Object?> get props {
    return [
      startDate,
      endDate,
      dateJoinedBrand,
      purchasesHistoryObjects,
      orderByDescending,
      filterByPurchaseStatus,
      filterByActivePurchases,
      forceRebuild
      /*
      const IterableEquality().hash(filterByPurchaseStatus),
      const IterableEquality().hash(filterByActivePurchases),
       */
    ];
  }

}

class BrandPurchasesError extends BrandPurchasesState {
  final String message;
  const BrandPurchasesError(this.message);

  @override
  List<Object?> get props => [message];
}