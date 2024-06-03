// ignore_for_file: avoid_print
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/auth/bloc/auth_bloc.dart';
import 'package:mamba/auth/views/Login.dart';
import 'package:mamba/brand/bloc/brand_bloc.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/DataService/Room/RoomDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/calendar/views/calendar.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/home/cubit/home_manager.dart';
import 'package:mamba/home/widgets/responsive_menu.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/BrandSubscription.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/Trainers.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/01-Qui/002-Clients/Clients.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/Bonos.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/007%20-%20Purchases/views/BrandPurchaseHistory.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/008-Information/BrandInfo.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/009%20-%20Stats/Stats.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/03-Com/007-Contenido/BrandImages.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/05-On/011-Locations/Locations.dart';

class BrandScreen extends StatefulWidget {
  static String routeName = '/brand';

  static GoRoute route = GoRoute(
    name: routeName,
    path: '/brand',
    builder: (BuildContext context, GoRouterState state) => const BrandScreen(),
  );

  const BrandScreen({super.key});

  @override
  _BrandScreenState createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    if (context.read<BrandBloc>().brandId == '') {
      context.goNamed(Login.routeName);
    }
    paywallFunc();
  }

  Future<void> paywallFunc() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentState = context.read<BrandSuscriptionCubit>().state;
      if (currentState is BrandSuscriptionLoadedFalse) {
        await navigateToPayWall(context, true);
      }
    });
    return;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthStateS>(
          listener: (context, state) {
            switch (state.status) {
              case AuthStatus.unauthenticated:
                context.goNamed(Login.routeName);
                break;
              case AuthStatus.authenticated:
                break;
              case AuthStatus.unknown:
                break;
            }
          },
        ),
        BlocListener<BrandSuscriptionCubit, BrandSuscriptionState>(
          listener: (context, state) async {
            if (state is BrandSuscriptionLoadedFalse) {
              await navigateToPayWall(context);
            }
          },
        ),
        BlocListener<HomeManager, HomeManagerState>(
          listener: (BuildContext context, state) {
            // Jump To Correct Home Page
            setState(() {
              _pageController.jumpToPage(state.pageIndex);
            });
            if (navigationDrawerKey.currentState != null &&
                navigationDrawerKey.currentState!.isDrawerOpen) {
              // Close Drawer
              Navigator.of(context).pop();
            }
          },
        ),
      ],
      child: ResponsiveMenu(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Gestión
            const Calendar(),
            BrandPurchaseHistory(
              brandId: currentBrand.id!,
            ),
            Stats(
              brandId: currentBrand.id!,
            ),
            // Tu Marca
            BonosPro(
              brandId: currentBrand.id!,
            ),
            Clients(
              brandId: currentBrand.id!,
              numClients: currentBrand.numClients!,
            ),
            Trainers(
              brandId: currentBrand.id!,
              numTrainers: currentBrand.numTrainers!,
            ),
            // Configuración
            BrandInfo(
              locale: Localizations.localeOf(context),
              brandId: currentBrand.id!,
            ),
            BrandImages(
              brandId: currentBrand.id!,
            ),
            Locations(
              brandId: currentBrand.id!,
            ),
            // Plan
            BrandSubscription(
              locale: Localizations.localeOf(context),
              brandId: currentBrand.id!,
            ),
          ],
        ),
      ),
    );
  }
}
