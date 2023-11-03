import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateEvent/DateEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateEvent/TimeEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateTimeEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DurationEvent/DurationEventSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/RecurrentEvent/RecurrentEventObjectSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:weekday_selector/weekday_selector.dart';

class RecurrentEventSelector extends StatelessWidget {
  final Locale locale;
  const RecurrentEventSelector({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, bool>(
        selector: (state) {
      return state.newEvent.isRecurrent!;
    }, builder: (context, isRecurrent) {
      return // Recurrent Event
          context.read<CrudEventCubit>().state.isNew
              ? Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.recurrentEvent,
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.035,
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: CupertinoSwitch(
                                value: isRecurrent,
                                onChanged: (bool newVal) {
                                  context.read<CrudEventCubit>().editEventInfo(
                                      newVal, EditEventType.recurrent);
                                },
                                trackColor: Colors.green.withOpacity(0.4),
                                thumbColor: AppColors.white,
                                activeColor: Colors.green,
                              ),
                            ),
                          ],
                        )),
                    isRecurrent
                        ? RecurrentEventObjectSelector(locale: locale)
                        : Container(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05)
                  ],
                )
              : isRecurrent
                  ? Padding(
                      padding: const EdgeInsets.only(
                        top: 15,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.recurrentEvent,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.035,
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: CupertinoSwitch(
                              value: true,
                              onChanged: null,
                              trackColor: Colors.green.withOpacity(0.4),
                              thumbColor: AppColors.white,
                              activeColor: Colors.grey,
                            ),
                          ),
                        ],
                      ))
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.recurrentEvent,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.035,
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: CupertinoSwitch(
                              value: false,
                              onChanged: null,
                              trackColor: Colors.green.withOpacity(0.4),
                              thumbColor: AppColors.white,
                              activeColor: Colors.grey,
                            ),
                          ),
                        ],
                      ));
    });
  }
}
