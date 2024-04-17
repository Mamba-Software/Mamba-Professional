part of 'UserPurchasesCubit.dart';

abstract class UserPurchasesState extends Equatable {
  const UserPurchasesState();
}

class UserPurchasesInitial extends UserPurchasesState {
  const UserPurchasesInitial();

  @override
  List<Object?> get props => [];
}

class UserPurchasesLoading extends UserPurchasesState {
  const UserPurchasesLoading();

  @override
  List<Object?> get props => [];
}

class UserPurchasesLoaded extends UserPurchasesState {
  DateTime startDate;
  DateTime endDate;
  DateTime dateJoinedBrand;
  List<PurchaseHistoryModel> purchasesHistoryObjects;
  bool orderByDescending;
  List<bool> filterByPurchaseStatus;
  List<bool> filterByActivePurchases;
  bool forceRebuild;

  UserPurchasesLoaded({
    required this.startDate,
    required this.endDate,
    required this.dateJoinedBrand,
    required this.purchasesHistoryObjects,
    required this.orderByDescending,
    required this.filterByPurchaseStatus,
    required this.filterByActivePurchases,
    required this.forceRebuild,
  });

  UserPurchasesLoaded copyWith({
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dateJoinedBrand,
    List<PurchaseHistoryModel>? purchasesHistoryObjects,
    bool? orderByDescending,
    List<bool>? filterByPurchaseStatus,
    List<bool>? filterByActivePurchases,
    bool? forceRebuild,
  }) {
    return UserPurchasesLoaded(
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

class UserPurchasesError extends UserPurchasesState {
  final String message;
  const UserPurchasesError(this.message);

  @override
  List<Object?> get props => [message];
}