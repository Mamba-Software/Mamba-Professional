import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/events/crud_events/widgets/mobile/Bonos/EventBonosWidget.dart';
import 'package:mamba/events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Event event = Event();

class EventBonosBlocSelector extends StatelessWidget {
  const EventBonosBlocSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, Map<Bono, bool>>(
        selector: (state) {
      Map<Bono, bool> newEventBonos = Map.from(state.newEvent.eventBonos!);
      return newEventBonos;
    }, builder: (context, eventBonosMap) {
      return Column(
        children: [
          titleEventWidget(context, AppLocalizations.of(context)!.rates),
          eventBonosWidget(context, eventBonosMap),
        ],
      );
    });
  }
}
