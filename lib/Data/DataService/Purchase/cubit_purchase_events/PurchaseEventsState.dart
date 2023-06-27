part of 'PurchaseEventsCubit.dart';

abstract class PurchaseEventsState extends Equatable {
  const PurchaseEventsState();
}

class PurchaseEventsInitial extends PurchaseEventsState {
  const PurchaseEventsInitial();

  @override
  List<Object?> get props => [];
}

class PurchaseEventsLoading extends PurchaseEventsState {
  const PurchaseEventsLoading();

  @override
  List<Object?> get props => [];
}

class PurchaseEventsLoaded extends PurchaseEventsState {
  final Purchase purchase;

  const PurchaseEventsLoaded(this.purchase);

  @override
  List<Object?> get props => [purchase];
}