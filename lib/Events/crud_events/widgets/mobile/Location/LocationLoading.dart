import 'package:flutter/material.dart';
import 'package:mamba/events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/extensions/context.dart';

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
      dividerAddEditEvent(context, context.l10n.location, true),
    ],
  );
}
