// Utils for page selections in Mamba Pro
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/000-Home/HomePro.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/004-Categories/Categories.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/012-Logo/Logo.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/03-Com/007-Contenido/BrandImages.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/04-Quan/014-Historial/BrandEventHistoryPage.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/05-On/011-Locations/Locations.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../Strings/StringUtils.dart';

class MambaProUtils {

  // Date in the Middle of the Month
  DateTime middleMonthDate = DateTime.now();

  //Function to know the title on listview
  Widget titlePageSelectorListView(var context, int pageIndex)
  {
    if(pageIndex == 0) return Text(AppLocalizations.of(context)!.homeBottomNav, style: Theme.of(context).textTheme.bodyText1,);
    if(pageIndex == 1)return Text(AppLocalizations.of(context)!.staff, style: Theme.of(context).textTheme.bodyText1,);
    if(pageIndex == 2)return Text(AppLocalizations.of(context)!.clients);
    if(pageIndex == 4)return Text(AppLocalizations.of(context)!.categories);
    if(pageIndex == 5)return Text(AppLocalizations.of(context)!.bonos);
    if(pageIndex == 8)return Text(AppLocalizations.of(context)!.information);
    if(pageIndex == 7)return Text(AppLocalizations.of(context)!.photos);
    if(pageIndex == 6)return Text(AppLocalizations.of(context)!.opinions);
    if(pageIndex == 9)return Text(AppLocalizations.of(context)!.stats);
    if(pageIndex == 10)return Text(AppLocalizations.of(context)!.calendar);
    if(pageIndex == 11)return Text(AppLocalizations.of(context)!.locations);
    if(pageIndex == 12)return Text(AppLocalizations.of(context)!.logo);
    if(pageIndex == 13)return Text(AppLocalizations.of(context)!.feedback);
    if(pageIndex == 14)return Text(AppLocalizations.of(context)!.eventHistory);
    if(pageIndex == 15) return Text(AppLocalizations.of(context)!.myRequests);
    if(pageIndex == 16) return Text(AppLocalizations.of(context)!.howTheySeeMe);
    return Container();
  }

  //Function to select the icon to load
  Widget iconSelectorListView(var context, int pageIndexView)
  {
    if(pageIndexView == 1) return Icon(Icons.badge_outlined, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 2) return Icon(Icons.group_outlined, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 8) return Icon(Icons.feed_outlined, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 13) return Icon(Icons.question_mark_outlined, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 4) return Icon(Icons.category, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 5) return Icon(Icons.confirmation_number_outlined, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 12) return Icon(Icons.run_circle_outlined, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 7) return Icon(Icons.collections_outlined, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 10) return Icon(Icons.calendar_month_outlined, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 11) return Icon(Icons.pin_drop_outlined, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 6) return Icon(Icons.chat_bubble_outline, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 9) return Icon(Icons.leaderboard_outlined, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 14) return Icon(Icons.history_outlined, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 15) return Icon(Icons.group_add_outlined, color: Theme.of(context).primaryColor,);
    if(pageIndexView == 16) return Icon(Icons.preview, color: Theme.of(context).primaryColor,);
    return Container();
  }


}