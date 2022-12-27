import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/UserEventCard.dart';
import '../../../../../Data/Models/Event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserRecentEventsWidget extends StatefulWidget {
  String userId;
  List<Event> events;

  UserRecentEventsWidget({Key? key, required this.userId, required this.events}) : super(key: key);

  @override
  _UserRecentEventsWidgetState createState() => _UserRecentEventsWidgetState();
}

class _UserRecentEventsWidgetState extends State<UserRecentEventsWidget> {

  List<Event> listEvents = [];

  @override
  void initState() {
    listEvents = List.from(widget.events.reversed);
    if (widget.events.length > 4) {
      listEvents = List.from(listEvents.sublist(0, 4));
    }
    super.initState();
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
  Widget build(BuildContext context) {
    return listEvents.isNotEmpty ? ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listEvents.length,
      itemBuilder: (context,int index) {
        Event event = listEvents[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: GestureDetector(
            onTap: () {
              navigateToEventScreen(event.id!);
            },
            child: UserEventCard(
              event: event,
              height: MediaQuery.of(context).size.height*0.15,
              width: MediaQuery.of(context).size.width*0.9,
              isMyEvent: false,
              showEmoji: false,
            ),
          ),
        );
      },
    ) : Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.02),
            Text(AppLocalizations.of(context)!.noEvents, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
            SizedBox(height: MediaQuery.of(context).size.height*0.1),
          ],
        ),
      ],
    );
  }
}
