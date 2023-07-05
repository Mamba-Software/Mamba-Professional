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
  final List<PurchaseHistoryModel> purchasesHistoryObjects;
  List<bool> filterByPurchaseStatus;

  BrandPurchasesLoaded({
    required this.startDate,
    required this.endDate,
    required this.dateJoinedBrand,
    required this.purchasesHistoryObjects,
    required this.filterByPurchaseStatus,
  });

  BrandPurchasesLoaded copyWith({
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dateJoinedBrand,
    List<PurchaseHistoryModel>? purchasesHistoryObjects,
    List<bool>? filterByPurchaseStatus,
  }) {
    return BrandPurchasesLoaded(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dateJoinedBrand: dateJoinedBrand ?? this.dateJoinedBrand,
      purchasesHistoryObjects: purchasesHistoryObjects ?? this.purchasesHistoryObjects,
      filterByPurchaseStatus: filterByPurchaseStatus ?? this.filterByPurchaseStatus,
    );
  }

  @override
  List<Object?> get props => [startDate, endDate, dateJoinedBrand, purchasesHistoryObjects, filterByPurchaseStatus];
}

class BrandPurchasesError extends BrandPurchasesState {
  final String message;
  const BrandPurchasesError(this.message);

  @override
  List<Object?> get props => [message];
}