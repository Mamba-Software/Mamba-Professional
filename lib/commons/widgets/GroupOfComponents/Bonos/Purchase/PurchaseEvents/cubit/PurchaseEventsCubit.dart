import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:equatable/equatable.dart';


part 'PurchaseEventsState.dart';

class PurchaseEventsCubit extends Cubit<PurchaseEventsState> {
  final Purchase purchase;
  final _purchaseDataService = PurchaseDataService();

  PurchaseEventsCubit(this.purchase) : super(const PurchaseEventsInitial()) {
    loadList(purchase);
  }

  void loadList(Purchase purchase) async {
    if(purchase.id != null) {
      print("purchase.events");
      print(purchase.events.length);
      emit(const PurchaseEventsLoading());
      Purchase purchaseNew = await _purchaseDataService.getPurchaseEvents(purchase);
      purchaseNew.setInitialEventsData = purchaseNew.events;
      await Future.delayed(const Duration(milliseconds: 500));
      emit(PurchaseEventsLoaded(purchaseNew));
    }
  }

  void updateEvents(Purchase purchase) async {
    if(purchase.id != null) {
      emit(const PurchaseEventsLoading());
      print(purchase.events.length);
      emit(PurchaseEventsLoaded(purchase));
    }
  }



}