import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/home/models/home_page.dart';

final GlobalKey<ScaffoldState> navigationDrawerKey = GlobalKey<ScaffoldState>();

class HomeManagerState extends Equatable {
  final HomeNavigationPage page;
  final int pageIndex;
  final bool isExtendedDesktop;

  const HomeManagerState({
    required this.page,
    required this.pageIndex,
    required this.isExtendedDesktop,
  });

  @override
  List<Object> get props => [page, pageIndex, isExtendedDesktop];
}

class HomeManager extends Cubit<HomeManagerState>
    with PlatformMixin {
  HomeManager()
      : super(
          const HomeManagerState(
            page: HomeNavigationPage.BOOKINGS,
            pageIndex: 0,
            isExtendedDesktop: true,
          ),
        );

  HomeNavigationPage get page => state.page;

  int get pageIndex => state.pageIndex;

  bool get isExtendedDesktop => state.isExtendedDesktop;

  void jumpToIndex(int pageIndex) {
    HomeNavigationPage page = HomeNavigationPage.values[pageIndex];
    emit(
      HomeManagerState(
        page: page,
        pageIndex: pageIndex,
        isExtendedDesktop: state.isExtendedDesktop,
      ),
    );
  }

  void jumpToPage(HomeNavigationPage page) {
    int pageIndex =
        HomeNavigationPage.values.indexWhere((element) => page == element);
    emit(
      HomeManagerState(
        page: page,
        pageIndex: pageIndex,
        isExtendedDesktop: state.isExtendedDesktop,
      ),
    );
  }

  void toogleDesktopSideMenu() {    
    emit(
      HomeManagerState(
        page: state.page,
        pageIndex: state.pageIndex,
        isExtendedDesktop: !state.isExtendedDesktop,
      ),
    );
  }

  bool isWebSupported(HomeNavigationPage page) {
    List<HomeNavigationPage> webSupported = [HomeNavigationPage.BOOKINGS];
    if (isWeb == false || webSupported.contains(page)) {
      return true;
    }
    return false;
  }
}
