import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
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

final ValueNotifier<bool> isRecurrentValue = ValueNotifier<bool>(false);
TextEditingController startDateController = TextEditingController();
TextEditingController startTimeController = TextEditingController();
bool errorDate = false;

// Duration
String duration = "1.00";
TextEditingController durationController = TextEditingController();
List<bool?> values = [false, false, false, false, false, false, false];
int _value = 1;

Widget dateTimeEventWidget(BuildContext context, DateTime startDate,
    String duration, bool isBeforeEdit, String eventId, String eventGroupId) {
  return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.width * 0.05),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Time
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01),
              child: Text(
                AppLocalizations.of(context)!.selectDayTime,
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
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
                ],
              ),
            ),
            errorDate && isBeforeEdit
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 25, right: 25, top: 10.0),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.errorDate,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            ?.copyWith(color: AppColors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Container(),
            !isBeforeEdit
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 25, right: 25, top: 10.0),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.cantEditText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            ?.copyWith(color: AppColors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Container(),
            // Recurrent Event
            ValueListenableBuilder<bool>(
                valueListenable: isRecurrentValue,
                builder: (context, isRecurrent, child) {
                  return Column(
                    children: [
                      eventId == null
                          ? Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.03),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .recurrentEvent,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline1,
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.035,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.1,
                                          child: CupertinoSwitch(
                                            value: isRecurrent,
                                            onChanged: (bool newVal) {
                                              if (isBeforeEdit) {
                                                isRecurrentValue.value = newVal;
                                                /*
                                                if (brandClientsSelected
                                                    .isEmpty) {
                                                
                                                    if (isRecurrent) {
                                                      values = [
                                                        false,
                                                        false,
                                                        false,
                                                        false,
                                                        false,
                                                        false,
                                                        false
                                                      ];
                                                    } else {
                                                      values[startDate.weekday -
                                                          1] = true;
                                                    }
                                                    isRecurrentValue.value = newVal;
                                                  
                                                }*/
                                              }
                                            },
                                            trackColor:
                                                Colors.green.withOpacity(0.4),
                                            thumbColor: AppColors.white,
                                            activeColor: Colors.green,
                                          ),
                                        ),
                                      ],
                                    )),
                                eventId == null
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 25, right: 25, top: 10.0),
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .cantEditRecurrent,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                ?.copyWith(
                                                    color: AppColors.red),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                isRecurrent
                                    ? Column(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .days,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2,
                                                    ),
                                                  ),
                                                  WeekdaySelector(
                                                    fillColor: Theme.of(context)
                                                        .backgroundColor,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                    selectedFillColor:
                                                        Theme.of(context)
                                                            .primaryColor,

                                                    selectedTextStyle: Theme.of(
                                                            context)
                                                        .textTheme
                                                        .bodyText2!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark),
                                                    firstDayOfWeek: 0,
                                                    shortWeekdays: [
                                                      AppLocalizations.of(
                                                              context)!
                                                          .mondayLetter,
                                                      AppLocalizations.of(
                                                              context)!
                                                          .tuesdarLetter,
                                                      AppLocalizations.of(
                                                              context)!
                                                          .wednesdayLetter,
                                                      AppLocalizations.of(
                                                              context)!
                                                          .thursdayLetter,
                                                      AppLocalizations.of(
                                                              context)!
                                                          .fridayLetter,
                                                      AppLocalizations.of(
                                                              context)!
                                                          .saturadayLetter,
                                                      AppLocalizations.of(
                                                              context)!
                                                          .sundayLetter,
                                                    ],
                                                    // Working Days disabledFillColor: Colors.red,
                                                    onChanged: (v) {
                                                      if (isBeforeEdit) {
                                                        /*
                                                        setState(() {
                                                          values[v % 7] =
                                                              !values[v % 7]!;
                                                        });*/
                                                      }
                                                    },
                                                    selectedElevation: 8,
                                                    elevation: 4,
                                                    disabledElevation: 0,
                                                    values: values,
                                                  ),
                                                ],
                                              )),
                                          /*
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .during,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2,
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      ListTile(
                                                        dense: true,
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 0.0,
                                                                right: 0.0),
                                                        title: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .thisWeek,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText2,
                                                        ),
                                                        subtitle: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .until(StringUtils().toCapitalized(DateFormat(
                                                                      'EEEE - d/M/yy',
                                                                      widget
                                                                          .locale
                                                                          .languageCode)
                                                                  .format(
                                                                      oneWeek))),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption,
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                        leading: Radio(
                                                          value: 1,
                                                          groupValue: _value,
                                                          activeColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fillColor: MaterialStateProperty
                                                              .resolveWith(
                                                                  (states) =>
                                                                      getColor(
                                                                          states)),
                                                          onChanged: (value) {
                                                            if (isBeforeEdit) {
                                                              setState(() {
                                                                _value = int
                                                                    .parse(value
                                                                        .toString());
                                                              });
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      ListTile(
                                                        dense: true,
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 0.0,
                                                                right: 0.0),
                                                        title: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .nextTwoWeek,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText2,
                                                        ),
                                                        subtitle: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .until(StringUtils().toCapitalized(DateFormat(
                                                                      'EEEE - d/M/yy',
                                                                      widget
                                                                          .locale
                                                                          .languageCode)
                                                                  .format(
                                                                      twoWeek))),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption,
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                        leading: Radio(
                                                          value: 2,
                                                          groupValue: _value,
                                                          activeColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fillColor: MaterialStateProperty
                                                              .resolveWith(
                                                                  (states) =>
                                                                      getColor(
                                                                          states)),
                                                          onChanged: (value) {
                                                            if (isBeforeEdit) {
                                                              setState(() {
                                                                _value = int
                                                                    .parse(value
                                                                        .toString());
                                                              });
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      ListTile(
                                                        dense: true,
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 0.0,
                                                                right: 0.0),
                                                        title: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .wholeMonth,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText2,
                                                        ),
                                                        subtitle: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .until(StringUtils().toCapitalized(DateFormat(
                                                                      'EEEE - d/M/yy',
                                                                      widget
                                                                          .locale
                                                                          .languageCode)
                                                                  .format(
                                                                      oneMonth))),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption,
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                        leading: Radio(
                                                          value: 3,
                                                          groupValue: _value,
                                                          activeColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fillColor: MaterialStateProperty
                                                              .resolveWith(
                                                                  (states) =>
                                                                      getColor(
                                                                          states)),
                                                          onChanged: (value) {
                                                            if (isBeforeEdit) {
                                                              setState(() {
                                                                _value = int
                                                                    .parse(value
                                                                        .toString());
                                                              });
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )),
                                        */
                                        ],
                                      )
                                    : Container(),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.05)
                              ],
                            )
                          : eventGroupId != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: 15,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .recurrentEvent,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1,
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.035,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.1,
                                        child: CupertinoSwitch(
                                          value: true,
                                          onChanged: null,
                                          trackColor:
                                              Colors.green.withOpacity(0.4),
                                          thumbColor: AppColors.white,
                                          activeColor: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ))
                              : Padding(
                                  padding: const EdgeInsets.only(
                                    top: 15,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .recurrentEvent,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1,
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.035,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.1,
                                        child: CupertinoSwitch(
                                          value: false,
                                          onChanged: null,
                                          trackColor:
                                              Colors.green.withOpacity(0.4),
                                          thumbColor: AppColors.white,
                                          activeColor: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )),
                    ],
                  );
                }),
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          ]));
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

Future selectDuration(BuildContext context, String duration) async {
  String? pickedDuration = await showCupertinoModalPopup(
      context: context,
      builder: (_) => SelectDurationDialog(
            title: AppLocalizations.of(context)!.selectDuration,
            initialDuration: duration,
          ));
  /*
    if (pickedDuration != null) {
      setState(() {
        var hour = pickedDuration.split(".")[0];
        var min = pickedDuration.split(".")[1];
        duration = pickedDuration;
        durationController.text = "${hour}h ${min}min";
      });
    }*/
}
