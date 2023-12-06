import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateEvent/DateEventSelector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/RecurrentEvent/RecurrentEventSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DividerAddEditEvent.dart';

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
                  titleEventWidget(
                      context, AppLocalizations.of(context)!.selectDayTime),
                  DateEventSelector(locale: locale),
                ],
              )),
        ]);
  }
}
