import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:equatable/equatable.dart';


part 'PurchaseEventsState.dart';

class PurchaseEventsCubit extends Cubit<PurchaseEventsState> {
  final _purchaseDataService = PurchaseDataService();

  PurchaseEventsCubit(Purchase purchase) : super(PurchaseEventsInitial()) {
    loadList(purchase);
  }

  void loadList(Purchase purchase) async {
    emit(PurchaseEventsLoaded(await _purchaseDataService.getPurchaseEvents(purchase)));
  }



}