import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/UserEventCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../../../../Data/Models/Event.dart';




class SelectAllEvents extends StatefulWidget {
  List<Event> selectedEvents = [];
  Purchase purchase;
  
  SelectAllEvents({Key? key, required this.selectedEvents, required this.purchase}) : super(key: key);

  @override
  _SelectAllEventsState createState() => _SelectAllEventsState();
}

class _SelectAllEventsState extends State<SelectAllEvents> {

  // Brand Data Service
  final _purchaseDataService = PurchaseDataService();
  // Boolean Loading
  bool isLoading = false;
  // Search Controller
  bool searchClicked = false;
  var searchController = TextEditingController();
  // Members Page
  List<Event> allEvents = [];
  List<Event> filteredEvents = [];
  List<Event> selectedEvents = [];
  List<Appointment> allAppointments = <Appointment>[];

  Widget _buildEventContainer(CalendarAppointmentDetails details) {
    final Appointment appointment = details.appointments.first;
    final DateTime today = DateTime.now();
    bool isCompleted = appointment.endTime.isBefore(today);
    final Event event = getEvent(appointment.id.toString());
    return GestureDetector(
      onTap: () {
        var selectedEventsAux = selectedEvents;
        if (selectedEventsAux.contains(event)) {
          selectedEventsAux.remove(event);
          setState(() {
            selectedEvents = selectedEventsAux;
          });
        } else {
          selectedEventsAux.add(event);
          setState(() {
            selectedEvents = selectedEventsAux;
          });
        }
      },
      child: UserEventCard(
        event: event,
        height: details.bounds.height,
        width: details.bounds.width,
        isMyEvent: true,
        showEmoji: false,
      ),
    );
  }

  Event getEvent(String eventId) {
    for (var i=0; i < filteredEvents.length; i++) {
      Event temp = filteredEvents[i];
      if (temp.id == eventId) return temp;
    }
    return Event();
  }

  Future<void> getAllEvents() async {
    allEvents = await _purchaseDataService.getPurchaseEventsLast30Days(widget.purchase,currentBrand.id!);
    print('ALL EVENTS ' + allEvents.length.toString());
    if(allEvents.isNotEmpty) {
      // Sort Clients
      allEvents.sort((a, b) {
        if (a.doneAt != null && b.doneAt != null) {
          return b.doneAt!.compareTo(a.doneAt!);
        } else if (a.doneAt != null) {
          return -1; // a is greater (comes first) if it has doneAt value
        } else if (b.doneAt != null) {
          return 1; // b is greater (comes first) if it has doneAt value
        } else {
          return 0; // both events don't have doneAt value, so no change in order
        }
      });
      filteredEvents = allEvents;
      // Selected Clients
      for (var event in widget.selectedEvents) {
        String id = event.id!;
        var index = filteredEvents.indexWhere((element) => element.id! == id);
        if(index >= 0) {
          selectedEvents.add(filteredEvents[index]);
        }
      }
      // Return Future Delayed
      await Future.delayed(const Duration(milliseconds: 500));
    }
    setState(() {
      isLoading = false;
    });
  }

  Color getColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return Theme.of(context).colorScheme.secondary;
    } else {
      return Colors.transparent;
    }
  }

  void filterSearchResults(String query) {
    List<Event> eventsFiltered = [];
    if (query.isNotEmpty || query != "") {
      for (var item in allEvents) {
        if (item.title!.toLowerCase().startsWith(query)) {
          eventsFiltered.add(item);
        }
      }
      setState(() {
        filteredEvents = eventsFiltered;
      });
    } else {
      setState(() {
        filteredEvents = allEvents;
      });
    }
  }

  @override
  initState() {
    isLoading = true;
    getAllEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body:  isLoading ?
      Center(child: LoadingView())
          :
      DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: searchController,
              onChanged: (value) {
                filterSearchResults(value);
              },
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.caption,
                hintText: AppLocalizations.of(context)!.search,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.0),
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
              onPressed: () {
                Navigator.pop(context, null);
                selectedEvents = [];
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  searchController.clear();
                  filterSearchResults("");
                },
                icon: const Icon(Icons.clear, color: AppColors.grey,),
              ),
            ],
          ),
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.03, left: MediaQuery.of(context).size.width*0.02),
            child: Column(
              children: [
                selectedEvents.isNotEmpty ? Container(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03,),
                  color: Theme.of(context).backgroundColor,
                  height: MediaQuery.of(context).size.height*0.04,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.80,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedEvents.length,
                            itemBuilder: (context, index) {
                              Event event = selectedEvents[index];
                              return Center(
                                child: Text(
                                  index == 0 && selectedEvents.length == 1 || index == selectedEvents.length-1 ? event.title! : event.title! + ", ",
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              );
                            }
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width*0.09,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "( "+selectedEvents.length.toString()+" )",
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 8),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ) : SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                Expanded(
                  child: SfCalendarTheme(
                    data: SfCalendarThemeData(
                      brightness: Brightness.dark,
                      backgroundColor: Theme.of(context).backgroundColor,
                      todayHighlightColor: Theme.of(context).primaryColor,
                      todayBackgroundColor: Theme.of(context).backgroundColor,
                    ),
                    child: SfCalendar(
                      // Controller
                      view: CalendarView.schedule,
                      blackoutDatesTextStyle: Theme.of(context).textTheme.headline3?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600),
                      // Data
                      initialDisplayDate: DateTime.now(),
                      initialSelectedDate: DateTime.now(),
                      dataSource: _getCalendarDataSource(),
                      // Config
                      cellEndPadding: 0,
                      firstDayOfWeek: 1,
                      showCurrentTimeIndicator: true,
                      cellBorderColor: Colors.transparent,
                      todayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark),
                      // Style
                      selectionDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                          border: Border.all(width: 1, color: Theme.of(context).colorScheme.secondary),
                          shape: BoxShape.circle
                      ),
                      headerHeight: 0,
                      headerStyle: CalendarHeaderStyle(
                        textAlign: TextAlign.center,
                        backgroundColor: Colors.transparent,
                        textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.transparent),
                      ),
                      viewHeaderHeight: 30,
                      viewHeaderStyle: ViewHeaderStyle(
                        backgroundColor: Theme.of(context).backgroundColor,
                        dateTextStyle: Theme.of(context).textTheme.bodyText2,
                        dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                      ),
                      // Monthly View
                      monthViewSettings: MonthViewSettings(
                        appointmentDisplayCount: 3,
                        numberOfWeeksInView: 6,
                        showTrailingAndLeadingDates: false,
                        appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                        showAgenda: true,
                        agendaViewHeight: MediaQuery.of(context).size.height*0.35,
                        agendaItemHeight: MediaQuery.of(context).size.height*0.15,
                        agendaStyle: AgendaStyle(
                          dateTextStyle: Theme.of(context).textTheme.bodyText2,
                          dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                          appointmentTextStyle: Theme.of(context).textTheme.bodyText2,
                        ),
                        monthCellStyle: MonthCellStyle(
                          textStyle: Theme.of(context).textTheme.bodyText1,
                          trailingDatesTextStyle: Theme.of(context).textTheme.caption,
                          leadingDatesTextStyle: Theme.of(context).textTheme.caption,
                        ),
                      ),
                      // Schedule View
                      scheduleViewSettings: ScheduleViewSettings(
                          hideEmptyScheduleWeek: true,
                          appointmentItemHeight: MediaQuery.of(context).size.height*0.15,
                          appointmentTextStyle: Theme.of(context).textTheme.bodyText2,
                          dayHeaderSettings: DayHeaderSettings(
                            dateTextStyle: Theme.of(context).textTheme.bodyText2,
                            dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                          ),
                          weekHeaderSettings: WeekHeaderSettings(
                            startDateFormat: 'dd/MM',
                            endDateFormat: 'dd/MM/yyyy',
                            textAlign: TextAlign.start,
                            backgroundColor: Theme.of(context).backgroundColor,
                            weekTextStyle: Theme.of(context).textTheme.caption,
                          ),
                          monthHeaderSettings: MonthHeaderSettings(
                            monthFormat: 'MMMM yyyy',
                            height: 70,
                            textAlign: TextAlign.start,
                            backgroundColor: Theme.of(context).backgroundColor,
                            monthTextStyle: Theme.of(context).textTheme.headline1,
                          )
                      ),
                      scheduleViewMonthHeaderBuilder: (BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
                        return Container(
                          color: Theme.of(context).backgroundColor,
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                StringUtils().toCapitalized(DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode,).format(details.date)),
                                style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.normal, color: AppColors.grey),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        );
                      },
                      appointmentTextStyle: Theme.of(context).textTheme.bodyText2!,
                      appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                        return _buildEventContainer(details);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
              /*
          Column(
              children: [
                selectedEvents.length > 0 ? Container(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05,),
                  color: Theme.of(context).backgroundColor,
                  height: MediaQuery.of(context).size.height*0.04,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.80,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedEvents.length,
                            itemBuilder: (context, index) {
                              Event event = selectedEvents[index];
                              return Center(
                                child: Text(
                                  index == 0 && selectedEvents.length == 1 || index == selectedEvents.length-1 ? event.title! : event.title! + ", ",
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              );
                            }
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width*0.09,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "( "+selectedEvents.length.toString()+" )",
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 8),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ) : SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        Event event = filteredEvents[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  var selectedEventsAux = selectedEvents;
                                  if (selectedEventsAux.contains(event)) {
                                    selectedEventsAux.remove(event);
                                    setState(() {
                                      selectedEvents = selectedEventsAux;
                                    });
                                  } else {
                                    selectedEventsAux.add(event);
                                    setState(() {
                                      selectedEvents = selectedEventsAux;
                                    });
                                  }
                                },
                                child: UserEventCard(
                                  event: event,
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.15,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.9,
                                  isMyEvent: true,
                                  showEmoji: false,
                                ),
                              ),
                              Positioned(
                                top: MediaQuery.of(context).size.width*0.03,
                                left: MediaQuery.of(context).size.width*0.07,
                                child: Theme(
                                  data: ThemeData(unselectedWidgetColor: Colors.transparent),
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    tristate: false,
                                    fillColor: MaterialStateProperty.resolveWith(getColor),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    value: selectedEvents.contains(event),
                                    shape: const CircleBorder(
                                        side: BorderSide.none
                                    ),
                                    onChanged: (bool? value) {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                  ),
                ),
              ],
          ),

               */
          floatingActionButton: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.05),
            child: Container(
              height: MediaQuery.of(context).size.width*0.17,
              width: MediaQuery.of(context).size.width*0.17,
              child: FloatingActionButton(
                heroTag: "64",
                onPressed: () {
                  Navigator.pop(context, selectedEvents);
                },
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Icon(
                  Icons.add,
                  size: MediaQuery.of(context).size.width*0.07,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppointmentDataSource _getCalendarDataSource() {
    List<Appointment> tempAllAppointments = [];
    print('EVENTS ' + filteredEvents.length.toString());
    for (var i=0; i < filteredEvents.length; i++) {
      var event = filteredEvents[i];
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
        if(bookedCapacity <= 0.20) {
          color = Colors.green;
        } else if(bookedCapacity > 0.20 && bookedCapacity <= 0.40) {
          color = const Color(0xFFA8C76C);
        } else if(bookedCapacity > 0.40 && bookedCapacity <= 0.60) {
          color = const Color(0xFFECE014);
        } else if(bookedCapacity > 0.60 && bookedCapacity <= 0.80) {
          color = Colors.orangeAccent;
        } else if(bookedCapacity > 0.80 && bookedCapacity < 1) {
          color = Colors.deepOrangeAccent;
        } else if(bookedCapacity == 1) {
          color = Colors.red;
        }
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
  // Navigate to Event Screen on Tap
  Future<void> navigateToEventScreen(String eventId) async {
    await Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => EventPage(
            eventId: eventId,
          ),
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}