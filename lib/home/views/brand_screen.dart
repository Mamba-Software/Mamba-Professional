// ignore_for_file: avoid_print
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/events/Calendar/views/BrandCalendarWidget.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
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
  const BrandScreen({super.key});

  @override
  _BrandScreenState createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeNavigationManager, HomeNavigationManagerState>(
      listener: (BuildContext context, state) {
        // Jump To Correct Home Page
        setState(() {
          _pageController.jumpToPage(state.pageIndex);
        });
        print("navigationDrawerKey.currentState!.isDrawerOpen");
        print(navigationDrawerKey.currentState!.isDrawerOpen);
        if (navigationDrawerKey.currentState!.isDrawerOpen) {
          // Close Drawer
          Navigator.of(context).pop();
        }
      },
      child: ResponsiveMenu(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Gestión
            BrandCalendarWidget(
              brandId: currentBrand.id!,
            ),
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
