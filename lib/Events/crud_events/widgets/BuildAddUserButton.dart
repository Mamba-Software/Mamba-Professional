import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/SelectEventUsers/SelectTrainersEvent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget buildAddUserButton(
    BuildContext context, bool isTrainer, List<Usuario> brandTrainersSelected) {
  return GestureDetector(
    onTap: () async {
      List<Usuario>? selectedTrainers = await Navigator.push(
          context,
          CupertinoPageRoute<List<Usuario>>(
            builder: (context) => SelectTrainersEvent(
              selectedTrainers: brandTrainersSelected,
            ),
          ));
      if (selectedTrainers != null) {
        context
            .read<CrudEventCubit>()
            .editEventInfo(selectedTrainers, EditEventType.trainers);
      }
    }, //: null,
    child: Padding(
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.06, right: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.width * 0.17,
            width: MediaQuery.of(context).size.width * 0.17,
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
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
                  AppLocalizations.of(context)!.add,
                  style: Theme.of(context).textTheme.bodyText2,
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
