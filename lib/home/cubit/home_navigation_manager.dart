import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/home/models/home_navigation_page.dart';

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
