// Utils for page selections in Mamba Pro
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../Strings/StringUtils.dart';

class MambaProUtils {
  // Date in the Middle of the Month
  DateTime middleMonthDate = DateTime.now();

  //Function to know the title on listview
  Widget titlePageSelectorListView(var context, int pageIndex) {
    if (pageIndex == 1) {
      return Text(AppLocalizations.of(context)!.staff,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 2) {
      return Text(
        AppLocalizations.of(context)!.clients,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: returnColor(context)),
      );
    }
    if (pageIndex == 4) {
      return Text(AppLocalizations.of(context)!.categories,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 5) {
      return Text("${AppLocalizations.of(context)!.bonos}",
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 8) {
      return Text(AppLocalizations.of(context)!.settings,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 7) {
      return Text(AppLocalizations.of(context)!.photos,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 6) {
      return Text(AppLocalizations.of(context)!.opinions,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 9) {
      return Text(AppLocalizations.of(context)!.stats,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 10) {
      return Text(AppLocalizations.of(context)!.sesionsBottomNav,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 11) {
      return Text(AppLocalizations.of(context)!.locations,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 12) {
      return Text(AppLocalizations.of(context)!.logo,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 13) {
      return Text(AppLocalizations.of(context)!.feedback,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 14) {
      return Text(AppLocalizations.of(context)!.eventHistory,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 15) {
      return Text(AppLocalizations.of(context)!.myRequests,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 16) {
      return Text(AppLocalizations.of(context)!.howTheySeeMe,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 17) {
      return Text(
          StringUtils().toCapitalized(AppLocalizations.of(context)!.boughts),
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 18) {
      return Text(
          StringUtils().toCapitalized(AppLocalizations.of(context)!.boughts),
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    return Container();
  }

  //Function to select the icon to load
  Widget iconSelectorListView(var context, int pageIndexView) {
    if (pageIndexView == 1) {
      return Icon(Icons.badge_outlined, color: returnColor(context));
    }
    if (pageIndexView == 2) {
      return Icon(Icons.group_outlined, color: returnColor(context));
    }
    if (pageIndexView == 8) {
      return Icon(Icons.tune_outlined, color: returnColor(context));
    }
    if (pageIndexView == 13) {
      return Icon(Icons.question_mark_outlined, color: returnColor(context));
    }
    if (pageIndexView == 4) {
      return Icon(Icons.category, color: returnColor(context));
    }
    if (pageIndexView == 5) {
      return Icon(
        Icons.confirmation_number_outlined,
        color: returnColor(context),
      );
    }
    if (pageIndexView == 12) {
      return Icon(Icons.run_circle_outlined, color: returnColor(context));
    }
    if (pageIndexView == 7) {
      return Icon(Icons.collections_outlined, color: returnColor(context));
    }
    if (pageIndexView == 10) {
      return Icon(Icons.calendar_month_outlined, color: returnColor(context));
    }
    if (pageIndexView == 11) {
      return Icon(Icons.room_outlined, color: returnColor(context));
    }
    if (pageIndexView == 6) {
      return Icon(Icons.chat_bubble_outline, color: returnColor(context));
    }
    if (pageIndexView == 9) {
      return Icon(Icons.leaderboard_outlined, color: returnColor(context));
    }
    if (pageIndexView == 14) {
      return Icon(Icons.history_outlined, color: returnColor(context));
    }
    if (pageIndexView == 15) {
      return Icon(Icons.group_add_outlined, color: returnColor(context));
    }
    if (pageIndexView == 16) {
      return Icon(Icons.preview, color: returnColor(context));
    }
    if (pageIndexView == 17) {
      return Icon(Icons.credit_card_outlined, color: returnColor(context));
    }
    if (pageIndexView == 18) {
      return Icon(Icons.credit_card_outlined, color: returnColor(context));
    }
    return Container();
  }

  Color returnColor(var context) {
    return Theme.of(context).primaryColor;
  }
}
