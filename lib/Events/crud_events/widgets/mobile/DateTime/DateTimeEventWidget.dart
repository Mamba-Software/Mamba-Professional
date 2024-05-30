import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba/events/crud_events/widgets/mobile/DateTime/DateEvent/DateEventSelector.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/events/crud_events/widgets/mobile/DividerAddEditEvent.dart';

class DateTimeEventWidget extends StatelessWidget {
  final Locale locale;
  const DateTimeEventWidget({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width * 0.00),
              child: Column(
                children: [
                  titleEventWidget(context, context.l10n.selectDayTime),
                  DateEventSelector(locale: locale),
                ],
              )),
        ]);
  }
}
