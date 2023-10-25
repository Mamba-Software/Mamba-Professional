import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Clients/ClientEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Clients/MaxClientEventWidget.dart';

Event event = Event();

class ClientEventSelectoWidget extends StatelessWidget {
  const ClientEventSelectoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocSelector<CrudEventCubit, CrudEventState, int>(selector: (state) {
          if (state is CrudEventLoaded) {
            return state.newEvent.maxMembers!;
          }
          return 1;
        }, builder: (context, maxMembers) {
          return Column(
            children: [
              maxClientEventWidget(context, maxMembers),
            ],
          );
        }),
        BlocBuilder<CrudEventCubit, CrudEventState>(
          buildWhen: (previous, current) {
            final result = previous.runtimeType != current.runtimeType ||
                current is CrudEventLoaded &&
                    current.newEvent.maxMembers !=
                        (previous as CrudEventLoaded).newEvent.maxMembers;
            return result;
          },
          builder: (context, state) {
            if (state is CrudEventLoaded) {
              final joinedMembers = state.newEvent.joinedMembers;
              return Column(
                children: [
                  clientEventWidget(context, joinedMembers),
                ],
              );
            }
            return Column(
              children: [],
            ); // return an empty Column or some other widget if the state is not CrudEventLoaded
          },
        ),
      ],
    );
  }
}
