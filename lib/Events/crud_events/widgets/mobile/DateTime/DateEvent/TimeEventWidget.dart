import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/commons/widgets/Components/CupertinoSelect/SelectTimeDialog.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

TextEditingController startTimeController = TextEditingController();

Widget timeEventWidget(BuildContext context, DateTime startDate,
    bool isBeforeEdit, Locale locale) {
  startTimeController.text =
      DateFormat('HH:mm', locale.languageCode).format(startDate);
  return Column(
    children: [
      Row(
        children: [
          Icon(
            Icons.schedule,
            color: AppColors.grey,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.05),
          Flexible(
            child: GestureDetector(
                onTap: () {
                  if (isBeforeEdit) {
                    selectTime(context, startDate);
                  }
                },
                child: TextFormField(
                  controller: startTimeController,
                  readOnly: true,
                  enabled: false,
                  style: isBeforeEdit
                      ? Theme.of(context).textTheme.bodyMedium
                      : Theme.of(context).textTheme.bodySmall,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  textAlign: TextAlign.start,
                )),
          ),
        ],
      ),
      SizedBox(height: MediaQuery.of(context).size.width * 0.01),
    ],
  );
}

Future selectTime(BuildContext context, DateTime startDate) async {
  // TODO: AQUI HI HA UN ERROR QUAN SINICIA EL CREATEEVENT A LES XX:59 Y ES CLICKA AIXO A LES XX+1:01
  if (startDate.isBefore(DateTime.now())) startDate = DateTime.now();
  DateTime? pickedTimeTemp = await showCupertinoModalPopup(
      context: context,
      builder: (_) => SelectTimeDialog(
            title: AppLocalizations.of(context)!.selectTime,
            startDate: startDate,
            onlyFuture: true,
          ));

  if (pickedTimeTemp != null) {
    context
        .read<CrudEventCubit>()
        .editEventInfo(pickedTimeTemp, EditEventType.time);
  }
}
