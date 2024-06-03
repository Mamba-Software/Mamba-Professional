import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarEventWidget extends StatelessWidget {
  final Event event;
  final Appointment appointment;
  final CalendarView calendarView;
  final CalendarAppointmentDetails details;
  final Function() onTap;

  const CalendarEventWidget({
    super.key,
    required this.event,
    required this.appointment,
    required this.calendarView,
    required this.details,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: details.bounds.height,
        width: details.bounds.width,
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: appointment.color,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (calendarView == CalendarView.day) {
              return _buildDayViewContent(context, constraints);
            } else if (calendarView == CalendarView.week) {
              return _buildWeekViewContent(context);
            } else if (calendarView == CalendarView.month) {
              return _buildMonthViewContent(context);
            } else if (calendarView == CalendarView.schedule) {
              return _buildScheduleViewContent(context);
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildDayViewContent(
      BuildContext context, BoxConstraints constraints) {
    if (constraints.maxHeight > MediaQuery.of(context).size.height * 0.13) {
      return _buildDetailedContent(context);
    } else if (constraints.maxHeight >
        MediaQuery.of(context).size.height * 0.07) {
      return _buildCompactContent(context);
    } else if (constraints.maxHeight >
        MediaQuery.of(context).size.height * 0.05) {
      return _buildMinimalContent(context);
    } else {
      return _buildTinyContent(context);
    }
  }

  Widget _buildDetailedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context),
        _buildDescription(context),
        if (event.numFreeSessions != null && event.numFreeSessions != 0)
          _buildFreeSessions(context),
        _buildUsersList(context),
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context),
        _buildDescription(context),
        _buildFreeSessionsWithUsers(context),
      ],
    );
  }

  Widget _buildMinimalContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleWithDescription(context),
        _buildFreeSessionsWithUsers(context),
      ],
    );
  }

  Widget _buildTinyContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTitleWithDescription(context),
        if (event.numFreeSessions != null && event.numFreeSessions != 0)
          _buildFreeSessionsText(context),
      ],
    );
  }

  Widget _buildWeekViewContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: RichText(
            textAlign: TextAlign.start,
            softWrap: true,
            overflow: TextOverflow.clip,
            text: TextSpan(
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(text: "$event.title!\n"),
                TextSpan(
                  text: "$event.description!\n",
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
                if (event.numFreeSessions != null && event.numFreeSessions != 0)
                  TextSpan(
                    text: event.numFreeSessions == 1
                        ? "$event.numFreeSessions potential client\n"
                        : "$event.numFreeSessions potential clients\n",
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthViewContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            event.title!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.clip,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleViewContent(BuildContext context) {
    return Row(
      children: [
        Container(
          width: details.bounds.width * 0.1,
          decoration: BoxDecoration(
            color: appointment.color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(details.bounds.width * 0.04),
              bottomLeft: Radius.circular(details.bounds.width * 0.04),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: details.bounds.width * 0.04,
              vertical: details.bounds.width * 0.02,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(details.bounds.width * 0.04),
                bottomRight: Radius.circular(details.bounds.width * 0.04),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(context),
                _buildDescriptionWithTime(context),
                _buildFreeSessionsWithUsers(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Flexible(
      child: Text(
        event.title!,
        style: context.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.start,
        softWrap: true,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        child: Text(
          event.description!,
          style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }

  Widget _buildDescriptionWithTime(BuildContext context) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.only(top: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              event.description!,
              style: context.textTheme.bodyMedium,
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
            ),
            Text(
              "${DateFormat('Hm', Localizations.localeOf(context).languageCode).format(details.appointments.first.startTime)} - ${DateFormat('Hm', Localizations.localeOf(context).languageCode).format(details.appointments.first.endTime)}",
              style: context.textTheme.bodyMedium,
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeSessions(BuildContext context) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        child: Text(
          event.numFreeSessions == 1
              ? "$event.numFreeSessions potential client"
              : "$event.numFreeSessions potential clients",
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }

  Widget _buildFreeSessionsText(BuildContext context) {
    return Text(
      event.numFreeSessions == 1
          ? "$event.numFreeSessions potential client"
          : "$event.numFreeSessions potential clients",
      style: context.textTheme.bodyMedium?.copyWith(
        color: Colors.white,
        fontStyle: FontStyle.italic,
      ),
      overflow: TextOverflow.fade,
      maxLines: 1,
      softWrap: false,
    );
  }

  Widget _buildFreeSessionsWithUsers(BuildContext context) {
    return Flexible(
      child: SizedBox(
        height: MediaQuery.of(context).size.width * 0.05,
        child: Row(
          children: [
            if (event.numFreeSessions != null && event.numFreeSessions != 0)
              Text(
                event.numFreeSessions == 1
                    ? "$event.numFreeSessions potential client  -  "
                    : "$event.numFreeSessions potential clients  -  ",
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
            _buildUsersList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        shrinkWrap: false,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: event.usersList.length,
        clipBehavior: Clip.none,
        itemBuilder: (context, int index) {
          var user = event.usersList[index];
          return Container(
            margin: const EdgeInsets.only(right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircularImage(
                  size: MediaQuery.of(context).size.width * 0.05,
                  image: user.imageUrl!,
                  color: Colors.white,
                  borderWidth: 0,
                ),
                const SizedBox(width: 4),
                Text(
                  "${user.firstName!} ${user.lastName![0]}.",
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleWithDescription(BuildContext context) {
    return Flexible(
      child: RichText(
        textAlign: TextAlign.start,
        softWrap: true,
        overflow: TextOverflow.visible,
        text: TextSpan(
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(text: event.title!),
            TextSpan(
              text: "   $event.description!",
              style:
                  context.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
