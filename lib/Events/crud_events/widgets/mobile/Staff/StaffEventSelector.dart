import 'package:flutter/cupertino.dart';
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
      List<Usuario> selectedTrainers =
          List.from(state.newEvent.selectedTrainers!);
      return selectedTrainers;
    }, builder: (context, brandTrainersSelected) {
      return Column(
        children: [
          Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.03,
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.staff,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03,
                  ),
                  Row(
                    children: [
                      Text(
                        "( " + brandTrainersSelected.length.toString() + " )",
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  )
                ],
              )),
          staffEventWidget(context, brandTrainersSelected),
        ],
      );
    });
  }
}
