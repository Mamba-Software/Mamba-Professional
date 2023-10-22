import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/DividerAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDurationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectTimeDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:weekday_selector/weekday_selector.dart';

TextEditingController startDateController = TextEditingController();

Widget timeEventWidget(BuildContext context, DateTime startDate,
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
                    selectTime(context, startDate);
                  }
                },
                child: TextFormField(
                  controller: startDateController,
                  readOnly: true,
                  enabled: false,
                  style: isBeforeEdit
                      ? Theme.of(context).textTheme.bodyText2
                      : Theme.of(context).textTheme.caption,
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
  /*
    if (pickedTimeTemp != null) {
      setState(() {
        errorDate = false;
        startDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          pickedTimeTemp.hour,
          pickedTimeTemp.minute,
        );
        startTimeController.text = DateFormat('HH:mm', widget.locale.languageCode).format(startDate);
        oneWeek = pickedTimeTemp.add(const Duration(days: 7));
        twoWeek = pickedTimeTemp.add(const Duration(days: 14));
        oneMonth= pickedTimeTemp.add(const Duration(days: 28));
      });
    }*/
}
