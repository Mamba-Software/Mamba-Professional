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
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01,
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        child: InkWell(
          onTap: () {
            selectNumberOfMembers(context, eventMaxMembers);
          },
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person,
                      color: AppColors.grey,
                      size: MediaQuery.of(context).size.width * 0.1,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: AppColors.red,
                        radius: MediaQuery.of(context).size.width * 0.025,
                        child: Text(
                          membersController.text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                Text(
                  AppLocalizations.of(context)!.maxNumberClients.toLowerCase(),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
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
