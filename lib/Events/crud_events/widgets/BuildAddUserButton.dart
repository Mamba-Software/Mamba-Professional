import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba/events/crud_events/widgets/mobile/SelectEventUsers/SelectClientsEvent.dart';
import 'package:mamba/events/crud_events/widgets/mobile/SelectEventUsers/SelectTrainersEvent.dart';
import 'package:mamba/l10n/language_manager.dart';

Widget buildAddUserButton(
    BuildContext context, bool isTrainer, List<Usuario> brandUsersSelected) {
  return GestureDetector(
    onTap: () async {
      if (isTrainer) {
        List<Usuario>? selectedTrainers = await Navigator.push(
            context,
            CupertinoPageRoute<List<Usuario>>(
              builder: (context) => SelectTrainersEvent(
                selectedTrainers: brandUsersSelected,
              ),
            ));
        if (selectedTrainers != null) {
          context
              .read<CrudEventCubit>()
              .editEventInfo(selectedTrainers, EditEventType.trainers);
        }
      } else {
        final state = context.read<CrudEventCubit>().state;
        List<Bono> bonos = [];
        bonos = state.newEvent.eventBonos!.keys
            .where((key) => state.newEvent.eventBonos![key] == true)
            .toList();
        List<String> selectedBonos =
            bonos.map((Bono bono) => bono.id.toString()).toList();
        List<Usuario>? selectedClients = await Navigator.push(
            context,
            CupertinoPageRoute<List<Usuario>>(
              builder: (context) => SelectClientsEvent(
                selectedUsers: brandUsersSelected,
                selectedBonos: selectedBonos,
                bonos: bonos,
              ),
            ));
        if (selectedClients != null) {
          context
              .read<CrudEventCubit>()
              .editEventInfo(selectedClients, EditEventType.clients);

          //clientsModified = true;
        }
      }
    }, //: null,
    child: Padding(
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.00, right: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.width * 0.17,
            width: MediaQuery.of(context).size.width * 0.17,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              border: Border.all(
                width: 1,
                color: Theme.of(context).primaryColor,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 2,
                ),
              ],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.person_add_alt_1,
                  color: Theme.of(context).primaryColor,
                  size: MediaQuery.of(context).size.width * 0.05),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.025),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.add,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
