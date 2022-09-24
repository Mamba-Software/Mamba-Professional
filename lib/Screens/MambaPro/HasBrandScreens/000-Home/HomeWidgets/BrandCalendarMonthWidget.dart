import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef DateCallBack = void Function(int pageIndex, DateTime? dateTime, CalendarView calendarView);

class BrandCalendarMonthWidget extends StatefulWidget {
  String brandId;
  double height = 0;
  double width = 0;
  final DateCallBack navigateToPage;

  BrandCalendarMonthWidget({Key? key, required this.brandId, required this.height, required this.width, required this.navigateToPage}) : super(key: key);

  @override
  _BrandCalendarMonthWidgetState createState() => _BrandCalendarMonthWidgetState();
}

class _BrandCalendarMonthWidgetState extends State<BrandCalendarMonthWidget> {

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

  List<Event> documentsToEvents(List<DocumentSnapshot> documents) {
    List<Event> events = [];
    for(int i = 0; i < documents.length; i++) {
      events.add(Event.fromObjectOnlyCoverData(documents[i].id, documents[i]));
    }
    return events;
  }

  // Build the Calendar Widget
  AppointmentDataSource _getCalendarDataSource() {
    List<Appointment> tempAllAppointments = [];
    for (var i=0; i < eventsList.length; i++) {
      var event = eventsList[i];
      // Date Time
      var startDate =  DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      var hour = event.duration.toString().split(".")[0];
      var min = event.duration!.toStringAsFixed(2).split(".")[1];
      var endDate =  startDate.add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
      // Subject
      var subject;
      var color;
      if (event.isPrivate!) {
        subject = "${event.numClients}";
        color = Colors.black;
      } else {
        subject = "${event.numClients}/${event.maxMembers}";
        // Colors
        double numClients = double.parse(event.numClients.toString());
        double maxMembers = double.parse(event.maxMembers.toString());
        double bookedCapacity = numClients/maxMembers;
        if(bookedCapacity <= 0.20) color = Colors.green;
        else if(bookedCapacity > 0.20 && bookedCapacity <= 0.40) color = Color(0xFFA8C76C);
        else if(bookedCapacity > 0.40 && bookedCapacity <= 0.60) color = Color(0xFFECE014);
        else if(bookedCapacity > 0.60 && bookedCapacity <= 0.80) color = Colors.orangeAccent;
        else if(bookedCapacity > 0.80 && bookedCapacity < 1) color = Colors.deepOrangeAccent;
        else if(bookedCapacity == 1) color = Colors.red;
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: Material(
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
          ),// BoxDecoration
          child: Container(
            margin: const EdgeInsetsDirectional.only(start: 1, end: 1, bottom: 1, top: 1),
            height: widget.height,
            width: widget.width,
            padding: EdgeInsets.all(widget.width*0.05),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
            ),// BoxDecoration
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: SizedBox(
                    height: widget.height*0.10,
                    width: widget.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            widget.navigateToPage(10, DateTime.now(), CalendarView.day);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_outlined, size: widget.width*0.05, color: AppColors.grey,),
                              SizedBox(width: widget.width*0.02),
                              Text(
                                  AppLocalizations.of(context)!.calendar,
                                  style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.grey),
                                  textAlign: TextAlign.center
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _calendarController.displayDate = DateTime.now();
                              _calendarController.selectedDate = DateTime.now();
                            });
                          },
                          child: Text(
                              AppLocalizations.of(context)!.todayString,
                              style: Theme.of(context).textTheme.caption,
                              textAlign: TextAlign.center
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: SizedBox(
                    height: widget.height*0.85,
                    width: widget.width,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: _eventDataService.getBrandEventsStream(widget.brandId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return LoadingView(
                              isSmall: true,
                              hasLogo: false,
                            );
                          } else {
                            eventsList = documentsToEvents(snapshot.data!.docs);
                            return SfCalendar(
                              view: CalendarView.month,
                              controller: _calendarController,
                              dataSource: _getCalendarDataSource(),
                              firstDayOfWeek: 1,
                              showDatePickerButton: false,
                              showCurrentTimeIndicator: false,
                              showNavigationArrow: true,
                              todayHighlightColor: Theme.of(context).colorScheme.secondary,
                              viewHeaderStyle: ViewHeaderStyle(
                                dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                              ),
                              headerHeight: 0,
                              headerDateFormat: "MMMM yyyy",
                              headerStyle: CalendarHeaderStyle(
                                textAlign: TextAlign.center,
                                backgroundColor: Colors.transparent,
                                textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.transparent),
                              ),
                              cellBorderColor: Colors.transparent,
                              monthViewSettings: MonthViewSettings(
                                appointmentDisplayCount: 4,
                                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                                showAgenda: false,
                                navigationDirection: MonthNavigationDirection.horizontal,
                                monthCellStyle: MonthCellStyle(
                                  textStyle: Theme.of(context).textTheme.bodyText1,
                                  trailingDatesTextStyle: Theme.of(context).textTheme.caption,
                                  leadingDatesTextStyle: Theme.of(context).textTheme.caption,
                                ),
                                numberOfWeeksInView: 6,
                                showTrailingAndLeadingDates: true,
                              ),
                              selectionDecoration: BoxDecoration(
                                  border: Border.all(width: 0.1, color: Colors.transparent)
                              ),
                              onViewChanged: (ViewChangedDetails viewChangedDetails) {
                                Future.delayed(Duration.zero, () async {
                                  setState(() {
                                    middleMonthDate = viewChangedDetails.visibleDates[14];
                                  });
                                });
                              },
                              onTap: (CalendarTapDetails details) {
                                widget.navigateToPage(10, details.date, CalendarView.month);
                              },
                            );
                          }
                        }
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
