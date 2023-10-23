import 'package:flutter/material.dart';

Widget dividerAddEditEvent(BuildContext context, String eventField) {
  return Column(
    children: [
      Divider(color: Theme.of(context).dividerColor, thickness: 1.5),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            eventField,
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
    ],
  );
}
