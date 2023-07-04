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
  final List<BonoRequest> brandBonoRequests;
  final List<Purchase> brandPurchasesList;

  const BrandPurchasesLoaded(
    this.brandBonoRequests,
    this.brandPurchasesList,
  );

  @override
  List<Object?> get props => [brandPurchasesList];
}

class BrandPurchasesError extends BrandPurchasesState {
  final String message;
  const BrandPurchasesError(this.message);

  @override
  List<Object?> get props => [message];
}