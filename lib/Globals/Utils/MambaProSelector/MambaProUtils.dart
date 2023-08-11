// Utils for page selections in Mamba Pro
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
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
    if(pageIndex == 1)return Text(AppLocalizations.of(context)!.staff, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 2)return Text(AppLocalizations.of(context)!.clients, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)),);
    if(pageIndex == 4)return Text(AppLocalizations.of(context)!.categories, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 5)return Text(AppLocalizations.of(context)!.bonos+" "+AppLocalizations.of(context)!.and+" "+AppLocalizations.of(context)!.boughts.toLowerCase(), style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 8)return Text(AppLocalizations.of(context)!.settings, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 7)return Text(AppLocalizations.of(context)!.photos, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 6)return Text(AppLocalizations.of(context)!.opinions, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 9)return Text(AppLocalizations.of(context)!.stats, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 10)return Text(AppLocalizations.of(context)!.sesionsBottomNav, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 11)return Text(AppLocalizations.of(context)!.locations, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 12)return Text(AppLocalizations.of(context)!.logo, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 13)return Text(AppLocalizations.of(context)!.feedback, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 14)return Text(AppLocalizations.of(context)!.eventHistory, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 15) return Text(AppLocalizations.of(context)!.myRequests, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 16) return Text(AppLocalizations.of(context)!.howTheySeeMe, style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    if(pageIndex == 17) return Text(StringUtils().toCapitalized(AppLocalizations.of(context)!.yourPlan.split(" ")[1]), style: Theme.of(context).textTheme.bodyText1?.copyWith(color: returnColor(context)));
    return Container();
  }

  //Function to select the icon to load
  Widget iconSelectorListView(var context, int pageIndexView)
  {
    if(pageIndexView == 1) return Icon(Icons.badge_outlined, color: returnColor(context));
    if(pageIndexView == 2) return Icon(Icons.group_outlined, color: returnColor(context));
    if(pageIndexView == 8) return Icon(Icons.tune_outlined, color: returnColor(context));
    if(pageIndexView == 13) return Icon(Icons.question_mark_outlined, color: returnColor(context));
    if(pageIndexView == 4) return Icon(Icons.category, color: returnColor(context));
    if(pageIndexView == 5) return Icon(Icons.confirmation_number_outlined, color: returnColor(context),);
    if(pageIndexView == 12) return Icon(Icons.run_circle_outlined, color: returnColor(context));
    if(pageIndexView == 7) return Icon(Icons.collections_outlined, color: returnColor(context));
    if(pageIndexView == 10) return Icon(Icons.calendar_month_outlined, color: returnColor(context));
    if(pageIndexView == 11) return Icon(Icons.room_outlined, color: returnColor(context));
    if(pageIndexView == 6) return Icon(Icons.chat_bubble_outline, color: returnColor(context));
    if(pageIndexView == 9) return Icon(Icons.leaderboard_outlined, color: returnColor(context));
    if(pageIndexView == 14) return Icon(Icons.history_outlined, color: returnColor(context));
    if(pageIndexView == 15) return Icon(Icons.group_add_outlined, color: returnColor(context));
    if(pageIndexView == 16) return Icon(Icons.preview, color: returnColor(context));
    if(pageIndexView == 17) return Icon(Icons.credit_card_outlined, color: returnColor(context));
    return Container();
  }

  Color returnColor(var context)
  {
    return Theme.of(context).primaryColor;
  }


}