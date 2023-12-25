import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDurationDialog.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

TextEditingController durationController = TextEditingController();

Widget durationEventWidget(
    BuildContext context, double durationDouble, bool isBeforeEdit) {
  String duration = durationDouble.toStringAsFixed(2);
  durationController.text = StringUtils().durationToString(durationDouble);
  var hour = duration.split(".")[0];
  var min = duration.split(".")[1];
  return Column(
    children: [
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.timer_outlined,
            color: AppColors.grey,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.05),
          Flexible(
            child: GestureDetector(
                onTap: () {
                  if (isBeforeEdit) {
                    selectDuration(context, duration);
                  }
                },
                child: TextFormField(
                  controller: durationController,
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
    ],
  );
}

Future selectDuration(BuildContext context, String duration) async {
  String? pickedDuration = await showCupertinoModalPopup(
      context: context,
      builder: (_) => SelectDurationDialog(
            title: AppLocalizations.of(context)!.selectDuration,
            initialDuration: duration,
          ));
  if (pickedDuration != null) {
    context
        .read<CrudEventCubit>()
        .editEventInfo(double.parse(pickedDuration), EditEventType.duration);
  }
}
