import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/home/models/home_navigation_page.dart';

final GlobalKey<ScaffoldState> navigationDrawerKey = GlobalKey<ScaffoldState>();

class HomeNavigationManagerState extends Equatable {
  final HomeNavigationPage page;
  final int pageIndex;

  const HomeNavigationManagerState({
    required this.page,
    required this.pageIndex,
  });

  @override
  List<Object> get props => [page, pageIndex];
}

class HomeNavigationManager extends Cubit<HomeNavigationManagerState> {
  
  HomeNavigationManager()
      : super(
          const HomeNavigationManagerState(
            page: HomeNavigationPage.BOOKINGS,
            pageIndex: 0,
          ),
        );

  HomeNavigationPage get page => state.page;
  
  int get pageIndex => state.pageIndex;

  void jumpToIndex(int pageIndex) {    
    HomeNavigationPage page = HomeNavigationPage.values[pageIndex];
    emit(
      HomeNavigationManagerState(
        page: page,
        pageIndex: pageIndex,
      ),
    );
  }
  
  void jumpToPage(HomeNavigationPage page) {
    int pageIndex = HomeNavigationPage.values.indexWhere((element) => page == element);
    emit(
      HomeNavigationManagerState(
        page: page,
        pageIndex: pageIndex,
      ),
    );
  }
}
