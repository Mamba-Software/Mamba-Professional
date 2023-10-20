import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/DividerAddEditEvent.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget locationLoading(BuildContext context) {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.028),
            Shimmer.fromColors(
              baseColor: AppColors.grey,
              highlightColor: AppColors.grey.withOpacity(0.5),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.height * 0.70,
                decoration: const BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
              ),
            ),
          ],
        ),
      ),
      dividerAddEditEvent(context, AppLocalizations.of(context)!.location),
    ],
  );
}
