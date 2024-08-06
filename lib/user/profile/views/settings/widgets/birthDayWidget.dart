import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba/data/Models/Usuario.dart';

class BirthDayWidget extends StatefulWidget {
  final ValueChanged<DateTime> selectStartDateChanged;
  final Usuario? user;

  const BirthDayWidget({
    required this.selectStartDateChanged,
    required this.user,
  });

  @override
  _BirthDayWidgetState createState() => _BirthDayWidgetState();
}

class _BirthDayWidgetState extends State<BirthDayWidget> {
  DateTime startDateLocal = DateTime.now();
  TextEditingController startDateController = TextEditingController();

  @override
  void initState() {
    startDateController = TextEditingController(text: widget.user?.dateOfBirth);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          context.l10n.dateOfBirth,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            onTap: () {
              selectSlot(0);
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(15.0),
                    child: TextFormField(
                      controller: startDateController,
                      readOnly: true,
                      enabled: false,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: context.l10n.lastNameError,
                        hintStyle: Theme.of(context).textTheme.bodySmall,
                        errorStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.red),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 1.5),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 1.5),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 1.5),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 1.5),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 1.5),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.04),
      ],
    );
  }

  Future<void> selectSlot(int type) async {
    // Initial Vars
    var startDate = DateTime.now();
    String title = "";
    Widget widgetPicker = Container();

    // Different types of pickers
    Widget dateTimePicker = CupertinoTheme(
      data: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          dateTimePickerTextStyle: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime:
            DateTime(startDate.year, startDate.month, startDate.day),
        minimumDate: startDate.subtract(const Duration(days: 365 * 80)),
        maximumDate: DateTime(startDate.year, startDate.month, 31),
        minimumYear: 1941,
        maximumYear: startDate.year,
        use24hFormat: true,
        onDateTimeChanged: (val) {
          setState(() {
            startDateLocal = val;
          });
        },
      ),
    );

    if (type == 0) {
      title = context.l10n.selectDateOfBirth;
      widgetPicker = dateTimePicker;
    }

    bool? confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => Material(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
                  child: widgetPicker,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  FloatingActionButton.extended(
                    shape: const StadiumBorder(),
                    heroTag: "43",
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    icon: Container(),
                    label: Text(
                      context.l10n.confirm,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Theme.of(context).primaryColorDark),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() {
        startDateController.text = DateTimeUtils()
            .formatDateTimeToStringDDMMMMYYYY(
                startDateLocal, Localizations.localeOf(context).languageCode);
        widget.selectStartDateChanged(startDateLocal);
      });
    }
  }
}
