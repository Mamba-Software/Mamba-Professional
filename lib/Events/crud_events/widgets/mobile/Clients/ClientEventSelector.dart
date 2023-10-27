import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Clients/ClientEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Clients/MaxClientEventWidget.dart';

Event event = Event();

class ClientEventSelector extends StatelessWidget {
  const ClientEventSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocSelector<CrudEventCubit, CrudEventLoaded, int>(selector: (state) {
          return state.newEvent.maxMembers!;
        }, builder: (context, maxMembers) {
          return Column(
            children: [
              maxClientEventWidget(context, maxMembers),
            ],
          );
        }),
        BlocSelector<CrudEventCubit, CrudEventLoaded, List<Usuario>>(
            selector: (state) {
          List<Usuario> joinedMembers =
              List.from(state.newEvent.joinedMembers!);
          return joinedMembers;
        }, builder: (context, joinedMembers) {
          return Column(
            children: [
              clientEventWidget(context, joinedMembers),
            ],
          );
        }),
      ],
    );
  }
}
