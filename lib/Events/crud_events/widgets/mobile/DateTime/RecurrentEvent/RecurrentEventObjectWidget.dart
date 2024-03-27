import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/models/Recurrent.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Badges/BetaBadge.dart';
import 'package:mamba/commons/widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:weekday_selector/weekday_selector.dart';

final _topSnackBar = TopSnackBarDef();

Widget recurrentEventObjectWidget(
    BuildContext context, Recurrent recurrent, Locale locale) {
  return Column(
    children: [
      Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  context.l10n.days,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              WeekdaySelector(
                fillColor: Theme.of(context).colorScheme.background,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).primaryColor),
                selectedFillColor: Theme.of(context).primaryColor,

                selectedTextStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).primaryColorDark),
                firstDayOfWeek: 0,
                shortWeekdays: [
                  context.l10n.mondayLetter,
                  context.l10n.tuesdarLetter,
                  context.l10n.wednesdayLetter,
                  context.l10n.thursdayLetter,
                  context.l10n.fridayLetter,
                  context.l10n.saturadayLetter,
                  context.l10n.sundayLetter,
                ],
                // Working Days disabledFillColor: Colors.red,
                onChanged: (v) {
                  context
                      .read<CrudEventCubit>()
                      .editEventInfo(v, EditEventType.dayFromRecurrent);
                },
                selectedElevation: 8,
                elevation: 4,
                disabledElevation: 0,
                values: recurrent.values!,
              ),
            ],
          )),
      Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  context.l10n.during,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  selectorRecurrent(recurrent.value!, 1, locale, context,
                      recurrent.oneWeek!, context.l10n.thisWeek),
                  selectorRecurrent(recurrent.value!, 2, locale, context,
                      recurrent.twoWeek!, context.l10n.nextTwoWeek),
                  selectorRecurrent(recurrent.value!, 4, locale, context,
                      recurrent.oneMonth!, context.l10n.wholeMonth),
                  selectorRecurrent(
                      recurrent.value!,
                      13,
                      locale,
                      context,
                      recurrent.threeMonth!,
                      context.l10n.wholeThreeMonth,
                      true),
                  selectorRecurrent(recurrent.value!, 26, locale, context,
                      recurrent.sixMonth!, context.l10n.wholeSixMonth, true)
                  /*
                  selectorRecurrent(
                      recurrent.value!,
                      39,
                      locale,
                      context,
                      recurrent.nineMonth!,
                      context.l10n.wholeNineMonth),
                  selectorRecurrent(
                      recurrent.value!,
                      52,
                      locale,
                      context,
                      recurrent.twelveMonth!,
                      context.l10n.wholeTwelveMonth),*/
                ],
              )
            ],
          )),
    ],
  );
}

Color getColor(BuildContext context, Set<MaterialState> states) {
  const Set<MaterialState> interactiveStates = <MaterialState>{
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
  };
  if (states.any(interactiveStates.contains)) {
    return Colors.blue;
  }
  return Theme.of(context).primaryColor;
}

Widget selectorRecurrent(int value, int group, Locale locale,
    BuildContext context, DateTime durationRecurrent, String text,
    [bool isBeta = false]) {
  return ListTile(
    dense: true,
    contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
    title: Row(
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        isBeta ? const BetaBadge() : Container(),
      ],
    ),
    subtitle: Text(
      context.l10n.until(StringUtils().toCapitalized(
          DateFormat('EEEE - d/M/yy', locale.languageCode)
              .format(durationRecurrent))),
      style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.left,
    ),
    leading: Radio(
      value: group,
      groupValue: value,
      activeColor: Theme.of(context).colorScheme.secondary,
      fillColor: MaterialStateProperty.resolveWith(
          (states) => getColor(context, states)),
      onChanged: (value) {
        context.read<CrudEventCubit>().editEventInfo(
            int.parse(value.toString()), EditEventType.valueRecurrent);
      },
    ),
  );
}
