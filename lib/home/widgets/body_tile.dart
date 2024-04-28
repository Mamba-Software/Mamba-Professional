import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/models/home_navigation_page.dart';

class BodyTile extends StatelessWidget with PlatformMixin {
  final HomeNavigationPage page;

  const BodyTile({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: returnLeadingIcon(context),
      title: returnTextWidget(context),
      onTap: () => context.read<HomeNavigationManager>().jumpToPage(page),
    );
  }

  //Function to select the icon to load
  Widget returnLeadingIcon(BuildContext context) {
    Color color = context.theme.primaryColor;

    switch (page) {
      case HomeNavigationPage.BOOKINGS:
        return Icon(
          Icons.calendar_month_outlined,
          color: color,
        );
      case HomeNavigationPage.PAYMENTS:
        return Icon(
          Icons.credit_card_outlined,
          color: color,
        );
      case HomeNavigationPage.STATS:
        return Icon(
          Icons.leaderboard_outlined,
          color: color,
        );
      case HomeNavigationPage.RATES:
        return Icon(
          Icons.confirmation_number_outlined,
          color: color,
        );
      case HomeNavigationPage.CLIENTS:
        return Icon(
          Icons.group_outlined,
          color: color,
        );
      case HomeNavigationPage.STAFF:
        return Icon(
          Icons.badge_outlined,
          color: color,
        );
      case HomeNavigationPage.INFO:
        return Icon(
          Icons.tune_outlined,
          color: color,
        );
      case HomeNavigationPage.IMAGES:
        return Icon(
          Icons.collections_outlined,
          color: color,
        );
      case HomeNavigationPage.LOCATIONS:
        return Icon(
          Icons.room_outlined,
          color: color,
        );
      case HomeNavigationPage.PLAN:
        return Container();
    }
  }

  //Function to select the icon to load
  Widget returnTextWidget(BuildContext context) {
    Color color = context.theme.primaryColor;
    TextStyle style = context.textTheme.bodyLarge!.copyWith(color: color);

    switch (page) {
      case HomeNavigationPage.BOOKINGS:
        return Text(
          context.l10n.bookings,
          style: style,
        );
      case HomeNavigationPage.PAYMENTS:
        return Text(
          context.l10n.payments,
          style: style,
        );
      case HomeNavigationPage.STATS:
        return Text(
          context.l10n.stats,
          style: style,
        );
      case HomeNavigationPage.RATES:
        return Text(
          context.l10n.rates,
          style: style,
        );
      case HomeNavigationPage.CLIENTS:
        return Text(
          context.l10n.clients,
          style: style,
        );
      case HomeNavigationPage.STAFF:
        return Text(
          context.l10n.staff,
          style: style,
        );
      case HomeNavigationPage.INFO:
        return Text(
          context.l10n.settings,
          style: style,
        );
      case HomeNavigationPage.IMAGES:
        return Text(
          context.l10n.photos,
          style: style,
        );
      case HomeNavigationPage.LOCATIONS:
        return Text(
          context.l10n.locations,
          style: style,
        );
      case HomeNavigationPage.PLAN:
        return Container();
    }
  }
}
