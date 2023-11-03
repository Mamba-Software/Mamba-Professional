import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Recurrent.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/RecurrentEvent/RecurrentEventObjectWidget.dart';

class RecurrentEventObjectSelector extends StatelessWidget {
  final Locale locale;
  const RecurrentEventObjectSelector({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, Recurrent>(
        selector: (state) {
      return state.newEvent.recurrent!;
    }, builder: (context, recurrent) {
      return recurrentEventObjectWidget(context, recurrent, locale);
    });
  }
}
