import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';

Widget dividerAddEditEvent(
    BuildContext context, String eventField, bool validated) {
  return Column(
    children: [
      Divider(
          color: validated ? Theme.of(context).dividerColor : AppColors.red,
          thickness: 1.5),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          validated
              ? Text(
                  eventField,
                  style: Theme.of(context).textTheme.caption,
                )
              : Text(
                  eventField,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.copyWith(color: AppColors.red),
                )
        ],
      ),
    ],
  );
}
