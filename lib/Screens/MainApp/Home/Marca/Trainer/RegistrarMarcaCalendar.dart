import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

class RegistrarMarcaCalendar extends StatefulWidget {
  const RegistrarMarcaCalendar({Key? key}) : super(key: key);

  @override
  _RegistrarMarcaCalendarState createState() => _RegistrarMarcaCalendarState();
}

class _RegistrarMarcaCalendarState extends State<RegistrarMarcaCalendar> {
  //DataBase Access
  var _accessDatabase = new DatabaseAccess();
  // Controllers of Calendar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TimetableController<BasicEvent>? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TimetableController(
      // A basic EventProvider containing a single event:
      eventProvider: EventProvider.list([
         BasicEvent(
           id: 0,
           title: 'My Event',
           color: Colors.blue,
           start: LocalDate.today().at(LocalTime(13, 0, 0)),
           end: LocalDate.today().at(LocalTime(15, 0, 0)),
         ),
      ]),

      // For a demo of overlapping events, use this one instead:
      //eventProvider: positioningDemoEventProvider,

      // Or even this short example using a Stream:
      // eventProvider: EventProvider.stream(
      //   eventGetter: (range) => Stream.periodic(
      //     Duration(milliseconds: 16),
      //     (i) {
      //       final start =
      //           LocalDate.today().atMidnight() + Period(minutes: i * 2);
      //       return [
      //         BasicEvent(
      //           id: 0,
      //           title: 'Event',
      //           color: Colors.blue,
      //           start: start,
      //           end: start + Period(hours: 5),
      //         ),
      //       ];
      //     },
      //   ),
      // ),

      // Other (optional) parameters:
      initialTimeRange: InitialTimeRange.range(
        startTime: LocalTime(8, 0, 0),
        endTime: LocalTime(20, 0, 0),
      ),
      initialDate: LocalDate.today(),
      visibleRange: VisibleRange.days(3),
      firstDayOfWeek: DayOfWeek.monday,
    );
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.disponibilidad, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22),),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.today),
              onPressed: () => _controller!.animateToToday(),
              tooltip: 'Jump to today',
            ),
          ],
          centerTitle: true,
          elevation: 10,
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
        ),
        backgroundColor: Styles.white,
        body: Container(
          constraints: BoxConstraints(
            maxHeight: (MediaQuery.of(context).size.height*0.7889),
          ),
          child: SingleChildScrollView(
              child: Timetable<BasicEvent>(
                controller: _controller,
                onEventBackgroundTap: (start, isAllDay) {
                  showInSnackBar('Background tapped $start is all day event $isAllDay');
                },
                eventBuilder: (event) {
                  return BasicEventWidget(
                    event,
                    onTap: () => showInSnackBar('Part-day event $event tapped'),
                  );
                },
                allDayEventBuilder: (context, event, info) => BasicAllDayEventWidget(
                  event,
                  info: info,
                  onTap: () => showInSnackBar('All-day event $event tapped'),
                ),
              ),
          ),
        ),
      );
  }

  void showInSnackBar(String value) {
    final snackbar = new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "Raleway"),
      ),
      backgroundColor: Styles.accent,
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState!.showSnackBar(snackbar);
  }

}

