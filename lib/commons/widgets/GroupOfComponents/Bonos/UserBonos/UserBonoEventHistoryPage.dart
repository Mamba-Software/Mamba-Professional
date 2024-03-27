// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Events/EventListTile.dart';
import 'package:mamba/l10n/language_manager.dart';
import 'package:mamba/events/crud_events/models/Event.dart';

class UserBonoEventHistoryPage extends StatefulWidget {
  String userId;
  List<Event> bonoEvents;

  UserBonoEventHistoryPage(
      {super.key, required this.userId, required this.bonoEvents});

  @override
  _UserBonoEventHistoryPageState createState() =>
      _UserBonoEventHistoryPageState();
}

class _UserBonoEventHistoryPageState extends State<UserBonoEventHistoryPage> {
  // Screen Dimensions
  double safeAreaHeight = 0;
  double safeAreaWidth = 0;
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  // AlL Events From User
  List<Event> listEvents = [];

  @override
  void initState() {
    super.initState();
    listEvents = widget.bonoEvents;
    listEvents.sort((a, b) {
      var aDate = a.doneAt!.toDate();
      var bDate = b.doneAt!.toDate();
      return aDate.compareTo(bDate);
    });
    listEvents = List.from(listEvents.reversed);
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print(
        "Device H and W: ${MediaQuery.of(context).size.height} ${MediaQuery.of(context).size.width}");
    print("SafeArea H and W: $safeAreaHeight $safeAreaWidth");
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.mySessions,
          style: Theme.of(context).appBarTheme.titleTextStyle,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: listEvents.length,
        itemBuilder: (context, int index) {
          Event event = listEvents[index];
          return Column(
            children: [
              index == 0 ? SizedBox(height: safeAreaWidth * 0.08) : Container(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: safeAreaWidth * 0.08),
                child: EventListTile(
                  userId: widget.userId,
                  eventId: event.id!,
                  showFeedback: DateTime.now().isAfter(event.doneAt!.toDate()),
                  height: safeAreaHeight,
                  width: safeAreaWidth * 0.9,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: safeAreaHeight * 0.04,
                    horizontal: safeAreaWidth * 0.08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 1,
                      width: safeAreaWidth * 0.61,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
