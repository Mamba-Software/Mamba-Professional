import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPageClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPageTrainer.dart';

class EventPage extends StatefulWidget {
  String eventId;
  bool? onlyView;

  EventPage({Key? key, required this.eventId, this.onlyView}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {

  // init Widget state. Loading user info.
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentUser.isTrainer! && widget.onlyView == false ?
        EventPageTrainer(
          eventId: widget.eventId,
        )
          :
        EventPageClient(
          eventId: widget.eventId,
          onlyView: widget.onlyView,
        );
  }
}
