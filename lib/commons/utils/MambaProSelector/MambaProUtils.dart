// Utils for page selections in Mamba Pro
import 'package:flutter/material.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/l10n/language_manager.dart';

class MambaProUtils {
  // Date in the Middle of the Month
  DateTime middleMonthDate = DateTime.now();

  //Function to know the title on listview
  Widget titlePageSelectorListView(BuildContext context, int pageIndex) {
    if (pageIndex == 1) {
      return Text(context.l10n.staff,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 2) {
      return Text(
        context.l10n.clients,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: returnColor(context)),
      );
    }
    if (pageIndex == 4) {
      return Text(context.l10n.categories,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 5) {
      return Text("${context.l10n.rates}",
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 8) {
      return Text(context.l10n.settings,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 7) {
      return Text(context.l10n.photos,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 6) {
      return Text(context.l10n.opinions,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 9) {
      return Text(context.l10n.stats,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 10) {      
      return Text(context.l10n.bookings,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 11) {
      return Text(context.l10n.locations,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 12) {
      return Text(context.l10n.logo,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 13) {
      return Text(context.l10n.feedback,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 14) {
      return Text(context.l10n.eventHistory,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 15) {
      return Text(context.l10n.myRequests,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 16) {
      return Text(context.l10n.howTheySeeMe,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 17) {
      return Text(StringUtils().toCapitalized(context.l10n.yourPlan),
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    if (pageIndex == 18) {
      return Text(StringUtils().toCapitalized(context.l10n.payments),
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: returnColor(context)));
    }
    return Container();
  }

  //Function to select the icon to load
  Widget iconSelectorListView(BuildContext context, int pageIndexView) {
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

  Color returnColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }
}
