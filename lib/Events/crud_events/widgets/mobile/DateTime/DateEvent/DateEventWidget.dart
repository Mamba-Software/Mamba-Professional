import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDateDialog.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

TextEditingController startDateController = TextEditingController();

Widget dateEventWidget(BuildContext context, DateTime startDate,
    bool isBeforeEdit, Locale locale) {
  startDateController.text =
      DateFormat('EEEE d/M/y', locale.languageCode).format(startDate);
  startDateController.text =
      StringUtils().toCapitalized(startDateController.text);
  return Column(
    children: [
      Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: AppColors.grey,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.05),
          Flexible(
            child: GestureDetector(
                onTap: () {
                  if (isBeforeEdit) {
                    selectDate(context, startDate);
                  }
                },
                child: TextFormField(
                  controller: startDateController,
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

Future selectDate(BuildContext context, DateTime startDate) async {
//startDate = DateTime.now(); //TODO BORRAR
  DateTime startDateAux = DateTime(
    startDate.year,
    startDate.month,
    startDate.day,
    0,
    0,
  );
  // TODO: AQUI HI HA UN ERROR QUAN SINICIA EL CREATEEVENT A LES XX:59 Y ES CLICKA AIXO A LES XX+1:01
  DateTime? pickedDateTemp = await showCupertinoModalPopup(
      context: context,
      builder: (_) => SelectDateDialog(
            title: AppLocalizations.of(context)!.selectDay,
            startDate: startDate,
            onlyFuture: true,
            dateOfWeek: true,
          ));
  if (pickedDateTemp != null) {
    context
        .read<CrudEventCubit>()
        .editEventInfo(pickedDateTemp, EditEventType.startDate);
  }
}
