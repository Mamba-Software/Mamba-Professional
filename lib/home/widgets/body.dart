import 'package:flutter/material.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/home/models/home_navigation_page.dart';
import 'package:mamba/home/widgets/body_tile.dart';

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
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04),
                child: Text(
                  context.l10n.management,
                  style: context.textTheme.bodyLarge,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              const BodyTile(
                page: HomeNavigationPage.BOOKINGS,
              ),
              const BodyTile(
                page: HomeNavigationPage.PAYMENTS,
              ),
              const BodyTile(
                page: HomeNavigationPage.STATS,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04),
                child: Text(
                  context.l10n.yourBrand,
                  style: context.textTheme.bodyLarge,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              const BodyTile(
                page: HomeNavigationPage.RATES,
              ),
              const BodyTile(
                page: HomeNavigationPage.CLIENTS,
              ),
              const BodyTile(
                page: HomeNavigationPage.STAFF,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04),
                child: Text(
                  context.l10n.information,
                  style: context.textTheme.bodyLarge,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              const BodyTile(
                page: HomeNavigationPage.INFO
              ),
              const BodyTile(
                page: HomeNavigationPage.IMAGES,
              ),
              const BodyTile(
                page: HomeNavigationPage.LOCATIONS,
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        ],
      ),
    );
  }
}
