import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateEvent/DateEventSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DurationEvent/DurationEventSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';

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
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.00),
              child: Column(
                children: [
                  DateEventSelector(locale: locale),
                  /*
                errorDate Padding(
                                      padding: const EdgeInsets.only(left: 25, right: 25, top: 10.0),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.errorDate,
                                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ) : Container(),
                                    */
                ],
              )),
        ]);
  }
}
