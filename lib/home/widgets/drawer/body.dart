import 'package:flutter/material.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/home/models/home_navigation_page.dart';
import 'package:mamba/home/widgets/drawer/body_tile.dart';

class Body extends StatelessWidget with PlatformMixin {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  context.l10n.management,
                  style: context.textTheme.labelLarge,
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 4),
              const BodyTile(
                page: HomeNavigationPage.BOOKINGS,
              ),
              const BodyTile(
                page: HomeNavigationPage.PAYMENTS,
              ),
              const BodyTile(
                page: HomeNavigationPage.STATS,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  context.l10n.yourBrand,
                  style: context.textTheme.labelLarge,
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 4),
              const BodyTile(
                page: HomeNavigationPage.RATES,
              ),
              const BodyTile(
                page: HomeNavigationPage.CLIENTS,
              ),
              const BodyTile(
                page: HomeNavigationPage.STAFF,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  context.l10n.information,
                  style: context.textTheme.labelLarge,
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 4),
              const BodyTile(page: HomeNavigationPage.INFO),
              const BodyTile(
                page: HomeNavigationPage.IMAGES,
              ),
              const BodyTile(
                page: HomeNavigationPage.LOCATIONS,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
