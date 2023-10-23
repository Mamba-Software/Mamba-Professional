import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/views/mobile/EventPageTrainer.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPageClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/PayWall.dart';

class EventPage extends StatelessWidget {
  String eventId;
  bool? onlyView;

  EventPage({Key? key, required this.eventId, this.onlyView}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<CrudEventCubit>().getEventInfo(eventId, true);
    return currentUser.isTrainer! && (onlyView == false || onlyView == null)
        ? EventPageTrainer()
        : EventPageClient(
            eventId: eventId,
            onlyView: onlyView,
          );
  }
}
