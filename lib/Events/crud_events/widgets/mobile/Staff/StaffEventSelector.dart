import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:mamba/events/crud_events/widgets/mobile/Staff/staffEventWidget.dart';
import 'package:mamba/l10n/language_manager.dart';

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
              titleEventWidget(context, context.l10n.staff),
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
              "${context.l10n.staff}    ( ${brandTrainersSelected.length} )",
              !errorNoTrainerSelected),
        ],
      );
    });
  }
}
