import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Staff/staffEventWidget.dart';

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
          staffEventWidget(context, brandTrainersSelected),
        ],
      );
    });
  }
}
