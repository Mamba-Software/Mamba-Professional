import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Staff/staffEventWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StaffEventSelector extends StatelessWidget {
  const StaffEventSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, List<Usuario>>(
        selector: (state) {
      if (state.newEvent.selectedTrainersList != null) {
        List<Usuario> selectedTrainersList =
            List.from(state.newEvent.selectedTrainersList!);
        return selectedTrainersList;
      }
      return [];
    }, builder: (context, brandTrainersSelected) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              titleEventWidget(context, AppLocalizations.of(context)!.staff),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.03,
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.02),
                child: Row(
                  children: [
                    Text(
                      "( ${brandTrainersSelected.length} )",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            ],
          ),
          staffEventWidget(context, brandTrainersSelected),
          dividerAddEditEvent(
              context,
              "${AppLocalizations.of(context)!.staff}    ( ${brandTrainersSelected.length} )",
              !errorNoTrainerSelected),
        ],
      );
    });
  }
}
