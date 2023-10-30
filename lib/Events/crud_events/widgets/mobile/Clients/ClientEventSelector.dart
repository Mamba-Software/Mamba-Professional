import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Clients/ClientEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Clients/MaxClientEventWidget.dart';
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
          List<Usuario> joinedMembers =
              List.from(state.newEvent.joinedMembers!);
          return joinedMembers;
        }, builder: (context, joinedMembers) {
          return Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.03,
                      bottom: MediaQuery.of(context).size.height * 0.01,
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
                            AppLocalizations.of(context)!.clients,
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
                            "( " + joinedMembers.length.toString() + " )",
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      )
                    ],
                  )),
              BlocSelector<CrudEventCubit, CrudEventLoaded, int>(
                  selector: (state) {
                return state.newEvent.maxMembers!;
              }, builder: (context, maxMembers) {
                return Column(
                  children: [
                    maxClientEventWidget(context, maxMembers),
                  ],
                );
              }),
              clientEventWidget(context, joinedMembers),
            ],
          );
        }),
      ],
    );
  }
}
