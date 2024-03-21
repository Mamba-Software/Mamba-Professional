import 'package:flutter/material.dart';
import 'package:mamba/app/style/AppColors.dart';

/*
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
}*/

Widget dividerAddEditEvent(
    BuildContext context, String eventField, bool validated) {
  return Column(
    children: [
      Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
        child: Divider(
            color: validated ? Theme.of(context).dividerColor : AppColors.red,
            thickness: 1.5),
      ),
    ],
  );
}

Widget titleEventWidget(BuildContext context, String eventField,
    [bool space = true]) {
  return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                eventField,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ],
          ),
        ],
      ));
}
