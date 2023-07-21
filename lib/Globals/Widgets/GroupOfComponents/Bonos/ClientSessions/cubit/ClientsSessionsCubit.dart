import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';


part 'ClientsSessionsState.dart';

class ClientSessionsCubit extends Cubit<ClientsSessionsState> {
  final List<Usuario> allUsers;
  final _purchaseDataService = PurchaseDataService();

  ClientSessionsCubit(this.allUsers) : super(const ClientsSessionsInitial()) {
    loadList();
  }

  void loadList() async {
      emit(const ClientsSessionsLoading());
      List<Usuario> users = [];
      emit(ClientsSessionsLoaded(allUsers));
  }

}