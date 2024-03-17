import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/Calendars/UserCalendarWidget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../Events/crud_events/models/Event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserCalendarMonthWidget extends StatefulWidget {
  String userId;
  var height;
  var width;

  UserCalendarMonthWidget(
      {super.key,
      required this.userId,
      required this.height,
      required this.width});

  @override
  _UserCalendarMonthWidgetState createState() =>
      _UserCalendarMonthWidgetState();
}

class _UserCalendarMonthWidgetState extends State<UserCalendarMonthWidget> {
  // Boolean Loading
  bool isLoading = true;
  // Acceso a Base de Datos
  final _eventDataService = EventDataService();
  // Calendar
  final CalendarController _calendarController = CalendarController();
  // Date in the Middle of the Month
  DateTime middleMonthDate = DateTime.now();
  // AlL Events From User
  List<Event> eventsList = [];
  List<Appointment> allAppointments = <Appointment>[];

  // Gets the Events Done by the User
  Future<void> getUserEvents() async {
    eventsList = await _eventDataService.getUserEvents(widget.userId);
    //Future.delayed(Duration(milliseconds: 750), () async {
    setState(() {
      isLoading = false;
    });
    //});
  }

  // Build the Calendar Widget
  AppointmentDataSource _getCalendarDataSource() {
    List<Appointment> tempAllAppointments = [];
    for (var i = 0; i < eventsList.length; i++) {
      var event = eventsList[i];
      // Date Time
      var startDate = DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      var hour = event.duration.toString().split(".")[0];
      var min = event.duration!.toStringAsFixed(2).split(".")[1];
      var endDate = startDate
          .add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
      // Subject
      String subject;
      Color color = Colors.black;
      if (event.isPrivate!) {
        subject = "${event.numClients}";
        color = Colors.black;
      } else {
        subject = "${event.numClients}/${event.maxMembers}";
        // Colors
        double numClients = double.parse(event.numClients.toString());
        double maxMembers = double.parse(event.maxMembers.toString());
        double bookedCapacity = numClients / maxMembers;
        if (bookedCapacity <= 0.20) {
          color = Colors.green;
        } else if (bookedCapacity > 0.20 && bookedCapacity <= 0.40)
          color = const Color(0xFFA8C76C);
        else if (bookedCapacity > 0.40 && bookedCapacity <= 0.60)
          color = const Color(0xFFECE014);
        else if (bookedCapacity > 0.60 && bookedCapacity <= 0.80)
          color = Colors.orangeAccent;
        else if (bookedCapacity > 0.80 && bookedCapacity < 1)
          color = Colors.deepOrangeAccent;
        else if (bookedCapacity >= 1) color = Colors.red;
      }
      // Afegir percentatges de members al Event.
      tempAllAppointments.add(Appointment(
        id: event.id,
        startTime: startDate,
        endTime: endDate,
        subject: subject,
        color: color,
        startTimeZone: '',
        endTimeZone: '',
      ));
    }
    allAppointments = tempAllAppointments;
    return AppointmentDataSource(allAppointments);
  }

  // Navigate to Feedback Screen on Tap
  void navigateToMyCalendar(DateTime? dateTime) {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
            builder: (context) => UserCalendarWidget(
                  userId: widget.userId,
                  dateTime: dateTime,
                )));
  }

  @override
  void initState() {
    getUserEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: widget.height * 0.18,
                  width: widget.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.myCalendar,
                          style: Theme.of(context).textTheme.displayLarge),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: widget.width * 0.08,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Theme.of(context).primaryColor,
                                  size: widget.width * 0.06,
                                ),
                                alignment: Alignment.centerRight,
                                onPressed: () {
                                  _calendarController.backward!();
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: widget.width * 0.05,
                            width: widget.width * 0.05,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Text(
                                StringUtils().toCapitalized(DateFormat(
                                  'MM',
                                  Localizations.localeOf(context).languageCode,
                                ).format(middleMonthDate)),
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: widget.width * 0.08,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Theme.of(context).primaryColor,
                                  size: widget.width * 0.06,
                                ),
                                alignment: Alignment.center,
                                onPressed: () {
                                  _calendarController.forward!();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: AppColors.grey,
                  highlightColor: AppColors.grey.withOpacity(0.5),
                  child: SizedBox(
                    height: widget.height * 0.82,
                    width: widget.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              Container(
                                height: widget.height / 9,
                                width: widget.width / 8,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: widget.height * 0.18,
                  width: widget.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.myCalendar,
                          style: Theme.of(context).textTheme.displayLarge),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: widget.width * 0.08,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Theme.of(context).primaryColor,
                                  size: widget.width * 0.06,
                                ),
                                alignment: Alignment.centerRight,
                                onPressed: () {
                                  _calendarController.backward!();
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: widget.width * 0.05,
                            width: widget.width * 0.05,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Text(
                                StringUtils().toCapitalized(DateFormat(
                                  'MM',
                                  Localizations.localeOf(context).languageCode,
                                ).format(middleMonthDate)),
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: widget.width * 0.08,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Theme.of(context).primaryColor,
                                  size: widget.width * 0.06,
                                ),
                                alignment: Alignment.center,
                                onPressed: () {
                                  _calendarController.forward!();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: widget.height * 0.82,
                  width: widget.width,
                  child: SfCalendar(
                    view: CalendarView.month,
                    controller: _calendarController,
                    dataSource: _getCalendarDataSource(),
                    firstDayOfWeek: 1,
                    showDatePickerButton: false,
                    showCurrentTimeIndicator: false,
                    showNavigationArrow: true,
                    todayHighlightColor:
                        Theme.of(context).colorScheme.secondary,
                    viewHeaderHeight: widget.width * 0.15,
                    viewHeaderStyle: ViewHeaderStyle(
                      dayTextStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 10),
                    ),
                    headerHeight: 0,
                    headerDateFormat: "MMMM yyyy",
                    headerStyle: CalendarHeaderStyle(
                      textAlign: TextAlign.center,
                      backgroundColor: Colors.transparent,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.transparent),
                    ),
                    cellBorderColor: Colors.transparent,
                    monthViewSettings: MonthViewSettings(
                      navigationDirection: MonthNavigationDirection.horizontal,
                      monthCellStyle: MonthCellStyle(
                        textStyle: Theme.of(context).textTheme.bodyLarge,
                        trailingDatesTextStyle:
                            Theme.of(context).textTheme.bodySmall,
                        leadingDatesTextStyle:
                            Theme.of(context).textTheme.bodySmall,
                      ),
                      numberOfWeeksInView: 6,
                      showTrailingAndLeadingDates: false,
                    ),
                    selectionDecoration: BoxDecoration(
                        border:
                            Border.all(width: 0.1, color: Colors.transparent)),
                    onViewChanged: (ViewChangedDetails viewChangedDetails) {
                      Future.delayed(Duration.zero, () async {
                        setState(() {
                          middleMonthDate = viewChangedDetails.visibleDates[14];
                        });
                      });
                    },
                    onTap: (CalendarTapDetails details) {
                      navigateToMyCalendar(details.date);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
