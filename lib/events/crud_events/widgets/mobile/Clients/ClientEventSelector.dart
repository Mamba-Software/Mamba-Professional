import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/data/Models/Usuario.dart';
import 'package:mamba_castelldefels/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/events/crud_events/widgets/mobile/Clients/ClientEventWidget.dart';
import 'package:mamba_castelldefels/events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Event event = Event();

class ClientEventSelector extends StatelessWidget {
  const ClientEventSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocSelector<CrudEventCubit, CrudEventLoaded, List<Usuario>>(
            selector: (state) {
          if (state.newEvent.joinedMembersList != null) {
            List<Usuario> joinedMembersList =
                List.from(state.newEvent.joinedMembersList!);
            return joinedMembersList;
          }
          return [];
        }, builder: (context, joinedMembersList) {
          return Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  titleEventWidget(
                      context, AppLocalizations.of(context)!.clients),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02),
                    child: Row(
                      children: [
                        Text(
                          "( ${joinedMembersList.length} )",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              clientEventWidget(context, joinedMembersList),
              /*
              dividerAddEditEvent(
                  context,
                  AppLocalizations.of(context)!.clients +
                      "    ( " +
                      joinedMembersList.length.toString() +
                      " )",
                  true),*/
            ],
          );
        }),
      ],
    );
  }
}
