// ignore_for_file: avoid_print
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba/events/Calendar/views/BrandCalendarWidget.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/home/models/MambaProUtils.dart';
import 'package:mamba/home/widgets/responsive_drawer.dart';
import 'package:mamba/notifications/NotificationService/LocalNotificationService.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/BrandSubscription.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/Trainers.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/01-Qui/002-Clients/Clients.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/Bonos.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/007%20-%20Purchases/views/BrandPurchaseHistory.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/008-Information/BrandInfo.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/009%20-%20Stats/Stats.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/03-Com/007-Contenido/BrandImages.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/05-On/011-Locations/Locations.dart';

// HomePage for the App. Here the user can change between the diferent pages.
// In this class we can only see the declaration of those pages and the swiping/changing between screens.
class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  _BrandScreenState createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  
  bool isLoading = false;
  

  bool isFirstBuild = true;

  @override
  void initState() {
    super.initState();
  }
    
  Widget bodyNavigation() {
    switch (pageIndex) {
      case 9:
        mixpanel!.track('brand_stats_view');
        return Stats(
          brandId: currentBrand.id!,
          initIndex: 0,
        );
      case 2:
        mixpanel!.track('brand_clients_view');
        return Clients(
          brandId: currentBrand.id!,
          numClients: currentBrand.numClients!,
        );
      case 1:
        mixpanel!.track('brand_trainers_view');
        return Trainers(
          brandId: currentBrand.id!,
          numTrainers: currentBrand.numTrainers!,
        );
      case 8:
        mixpanel!.track('brand_info_view');
        return BrandInfo(
          locale: Localizations.localeOf(context),
          brandId: currentBrand.id!,
        );
      case 5:
        mixpanel!.track('brand_bonos_view');
        return BonosPro(
          brandId: currentBrand.id!,
        );
      case 10:
        mixpanel!.track('brand_calendar_view');
        return BrandCalendarWidget(
          brandId: currentBrand.id!,
        );
      case 7:
        mixpanel!.track('brand_images_view');
        return BrandImages(
          brandId: currentBrand.id!,
        );
      case 11:
        mixpanel!.track('brand_locations_view');
        return Locations(
          brandId: currentBrand.id!,
        );
      case 17:
        mixpanel!.track('brand_subscription_view');
        return BrandSubscription(
          locale: Localizations.localeOf(context),
          brandId: currentBrand.id!,
        );
      case 18:
        mixpanel!.track('brand_subscription_view');
        return BrandPurchaseHistory(
          brandId: currentBrand.id!,
        );
      default:
        return Container();
    }
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDrawer(
      child: bodyNavigation(),      
    );
  } 

}
