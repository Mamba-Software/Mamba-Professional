import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Events/EventFeedback.dart';

class UserEventCard extends StatefulWidget {
  Event event;
  double height = 0;
  double width = 0;
  bool isMyEvent = false;
  bool showEmoji = false;
  UserEventCard(
      {super.key,
      required this.event,
      required this.height,
      required this.width,
      required this.isMyEvent,
      required this.showEmoji});

  @override
  _UserEventCardState createState() => _UserEventCardState();
}

class _UserEventCardState extends State<UserEventCard> {
  DateTime now = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool isDoing = false;
  bool isCompleted = false;
  bool canAnswerFeedback = false;

  @override
  void initState() {
    initEventCard();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UserEventCard oldWidget) {
    initEventCard();
    super.didUpdateWidget(oldWidget);
  }

  void initEventCard() {
    var hour = widget.event.duration.toString().split(".")[0];
    var min = widget.event.duration!.toStringAsFixed(2).split(".")[1];
    setState(() {
      startDate = DateTime(
        int.parse(widget.event.year!),
        int.parse(widget.event.month!),
        int.parse(widget.event.day!),
        int.parse(widget.event.hour!),
        int.parse(widget.event.minute!),
      );
      endDate = startDate
          .add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
      isDoing = startDate.isAfter(now) && endDate.isBefore(now) ? true : false;
      isCompleted = startDate.isBefore(now) ? true : false;
      canAnswerFeedback = false;
    });
  }

  // Build EventFeedback Value
  Widget buildEventFeedbackText() {
    if (widget.event.intensityScore == null) {
      if (widget.isMyEvent && canAnswerFeedback) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("?? ",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.deepOrange),
                textAlign: TextAlign.center),
            SizedBox(
              width: widget.width * 0.05,
              child: Image.asset(Assets.fireEmojiImage),
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("-- ",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.black),
                textAlign: TextAlign.center),
            SizedBox(
              width: widget.width * 0.05,
              child: Image.asset(Assets.fireEmojiImage),
            ),
          ],
        );
      }
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("${widget.event.intensityScore!.toStringAsFixed(1)} ",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.black),
              textAlign: TextAlign.center),
          SizedBox(
            width: widget.width * 0.05,
            child: Image.asset(Assets.fireEmojiImage),
          ),
        ],
      );
    }
  }

  // Build EventFeedback Value
  Widget buildTimeLefText() {
    int minutesLeft = startDate.difference(now).inMinutes;
    double hoursLeft = minutesLeft / 60;
    return Text(
        hoursLeft < 1
            ? "En ${minutesLeft}m "
            : "En ${hoursLeft.toStringAsFixed(0)}h ",
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.black),
        textAlign: TextAlign.center);
  }

  Widget buildIconTopRight() {
    if (widget.event.freeSession!) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.03,
                horizontal: MediaQuery.of(context).size.width * 0.03),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.8),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Text(
                context.l10n.freeSession.toUpperCase().split(" ")[2],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MaterialButton(
            onPressed: null,
            minWidth: MediaQuery.of(context).size.width * 0.08,
            elevation: 0,
            color: Colors.transparent,
            disabledColor: Colors.transparent,
            textColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
            child: Icon(
              Icons.favorite,
              color: Colors.transparent,
              size: MediaQuery.of(context).size.width * 0.055,
            ),
          ),
        ],
      );
    }
  }

  // Navigate to Event Feedback Screen
  Future<void> navigateToFeedbackEventScreen() async {
    mixpanel!.track('user_sesions_event_feedback_open');
    var result = await Navigator.push(
        context,
        CupertinoPageRoute<double?>(
          builder: (context) => EventFeedback(
            eventId: widget.event.id!,
          ),
        ));
    if (result != null) {
      mixpanel!.track('user_sesions_event_feedback_completed', properties: {
        'value': result.toString(),
        'descriptionLength': widget.event.description != null
            ? widget.event.description!.length.toString()
            : "0",
        'isPrivate': widget.event.isPrivate,
        'doneAt': widget.event.doneAt!.toDate().toString(),
        'duration': widget.event.duration.toString(),
        'numClients': widget.event.numClients!.toString(),
        'numTrainers': widget.event.numTrainers!.toString(),
        'maxMembers': widget.event.maxMembers!.toString(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                //border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15.0),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: widget.height * 0.66,
                    width: widget.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      //border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                      ),
                    ),
                  ),
                  Container(
                    height: widget.height * 0.34 - 1,
                    width: widget.width,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      //border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: widget.height * 0.66,
              width: widget.width,
              padding: EdgeInsets.symmetric(
                  horizontal: widget.width * 0.05,
                  vertical: widget.width * 0.05),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(widget.event.imageUrl!),
                  )),
              child: Container(),
            ),
            Container(
              height: widget.height * 0.66,
              width: widget.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                ),
                gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.grey.withOpacity(0.0),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [
                      0.0,
                      0.92
                    ]),
              ),
              child: const Center(),
            ),
            SizedBox(
              height: widget.height,
              width: widget.width,
              child: Stack(
                children: [
                  buildIconTopRight(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.height * 0.1,
                        vertical: widget.height * 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.event.title!,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                            Text(
                              widget.event.isPrivate!
                                  ? context.l10n.privateEvent
                                  : context.l10n.groupEvent,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.white),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: widget.height * 0.15,
                        ),
                        widget.showEmoji == true
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${DateFormat('Hm', Localizations.localeOf(context).languageCode).format(startDate)} - ${DateFormat('Hm', Localizations.localeOf(context).languageCode).format(endDate)}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: AppColors.black),
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: widget.height * 0.16,
                                    child: FittedBox(
                                      fit: BoxFit.fitHeight,
                                      child: isCompleted
                                          ? buildEventFeedbackText()
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                buildTimeLefText(),
                                                SizedBox(
                                                  width: widget.width * 0.04,
                                                  child: Image.asset(
                                                      Assets.clockEmojiImage),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(
                                height: widget.height * 0.16,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          StringUtils().toCapitalized(
                                              DateFormat(
                                                      'EEEE dd, ',
                                                      Localizations.localeOf(
                                                              context)
                                                          .languageCode)
                                                  .format(startDate)),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: AppColors.black),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(
                                          StringUtils().toCapitalized(
                                              DateFormat(
                                                      'MMMM yyyy ',
                                                      Localizations.localeOf(
                                                              context)
                                                          .languageCode)
                                                  .format(startDate)),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: AppColors.black),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(
                                          "de ${DateFormat('Hm', Localizations.localeOf(context).languageCode).format(startDate)} - ${DateFormat('Hm', Localizations.localeOf(context).languageCode).format(endDate)}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: AppColors.black),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
