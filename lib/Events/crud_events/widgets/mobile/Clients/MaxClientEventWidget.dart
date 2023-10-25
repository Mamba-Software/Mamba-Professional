import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectMembersDialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

TextEditingController membersController = TextEditingController();

Widget maxClientEventWidget(BuildContext context, int eventMaxMembers) {
  membersController.text = eventMaxMembers.toString();
  return Column(
    children: [
      Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.02,
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
            ],
          )),
      Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.01,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05),
        child: GestureDetector(
          onTap: () {
            selectNumberOfMembers(context, eventMaxMembers);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.person,
                color: AppColors.grey,
                size: MediaQuery.of(context).size.width * 0.08,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.04),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
                child: TextFormField(
                  controller: membersController,
                  readOnly: true,
                  enabled: false,
                  style: Theme.of(context).textTheme.bodyText2,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero),
                  textAlign: TextAlign.start,
                ),
              ),
              Text(
                membersController.text == "1"
                    ? AppLocalizations.of(context)!
                        .asistants
                        .toLowerCase()
                        .substring(0,
                            AppLocalizations.of(context)!.asistants.length - 1)
                    : AppLocalizations.of(context)!.asistants.toLowerCase(),
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Future selectNumberOfMembers(BuildContext context, int eventMaxMembers) async {
  int? pickedMembers = await showCupertinoModalPopup(
      context: context,
      builder: (_) => SelectMembersDialog(
            title: AppLocalizations.of(context)!.maxNumberClients,
            initialMembers: eventMaxMembers - 1,
          ));
  if (pickedMembers != null) {
    context
        .read<CrudEventCubit>()
        .editEventInfo(pickedMembers, EditEventType.maxMembers);
  }
}
