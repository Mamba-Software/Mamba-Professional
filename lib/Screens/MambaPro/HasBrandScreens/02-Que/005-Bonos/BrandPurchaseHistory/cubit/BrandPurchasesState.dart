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

  BrandPurchasesLoaded(
    this.startDate,
    this.endDate,
    this.dateJoinedBrand,
    this.purchasesHistoryObjects,
  );

  @override
  List<Object?> get props => [startDate, endDate, dateJoinedBrand, purchasesHistoryObjects];
}

class BrandPurchasesError extends BrandPurchasesState {
  final String message;
  const BrandPurchasesError(this.message);

  @override
  List<Object?> get props => [message];
}