import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventFeedback.dart';
import 'package:provider/provider.dart';

class BrandEventCard extends StatefulWidget {
  Event event;
  Color? color;
  double height = 0;
  double width = 0;
  BrandEventCard({Key? key, required this.event, this.color, required this.height, required this.width}) : super(key: key);

  @override
  _BrandEventCardState createState() => _BrandEventCardState();
}

class _BrandEventCardState extends State<BrandEventCard> {


  bool isDark = false;
  DateTime now = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool isCompleted = false;
  int places = 0;

  @override
  void initState() {
    initEventCard();
    isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BrandEventCard oldWidget) {
    initEventCard();
    super.didUpdateWidget(oldWidget);
  }

  void initEventCard() {
    var hour = widget.event.duration.toString().split(".")[0];
    var min = widget.event.duration!.toStringAsFixed(2).split(".")[1];
    places = widget.event.maxMembers!-widget.event.numClients!;
    setState(() {
      startDate =  DateTime(
        int.parse(widget.event.year!),
        int.parse(widget.event.month!),
        int.parse(widget.event.day!),
        int.parse(widget.event.hour!),
        int.parse(widget.event.minute!),
      );
      endDate =  startDate.add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
      isCompleted = startDate.isBefore(now) ? true : false;
    });
  }

  // Build EventFeedback Value
  Widget buildEventFeedbackText() {
    if (widget.event.averageIntensityScore == null) {
      return Text(
          "-- ",
          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.black),
          textAlign: TextAlign.center
      );
    } else {
      return Text(
          widget.event.averageIntensityScore!.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.black),
          textAlign: TextAlign.center
      );
    }
  }

  // Build EventFeedback Value
  Widget buildEventFeedbackEntries() {
    if (widget.event.averageIntensityScore == null) {
      return Container();
    } else {
      return Row(
        children: [
          Text(
              "/ "+widget.event.feedbackEntries.toString(),
              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.black),
              textAlign: TextAlign.center
          ),
          Icon(
            Icons.person,
            size: widget.width*0.05,
            color: AppColors.black
          )
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
          builder: (context) =>
              EventFeedback(
                eventId: widget.event.id!,
              ),
        )
    );
    if (result != null) {
      mixpanel!.track('user_sesions_event_feedback_completed', properties: {
        'value' : result.toString(),
        'descriptionLength': widget.event.description != null ? widget.event.description!.length.toString() : "0",
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
              height: MediaQuery.of(context).size.height*0.15,
              width: widget.width,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                //border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15.0),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height*0.10,
                    width: widget.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      //border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height*0.05-1,
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
              height: MediaQuery.of(context).size.height*0.10,
              width: widget.width,
              padding: EdgeInsets.symmetric(horizontal: widget.width*0.05, vertical: MediaQuery.of(context).size.height*0.01),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(widget.event.imageUrl!),
                  )
              ),
              child: Container(),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.10,
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
                    ]
                ),
              ),
              child: const Center(),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.15,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: widget.height*0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.event.title!,
                          style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                        Text(
                          widget.event.isPrivate! ? AppLocalizations.of(context)!.privateEvent : AppLocalizations.of(context)!.groupEvent,
                          style: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.white),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: widget.height*0.1,),
                  isCompleted ? Padding(
                    padding: EdgeInsets.only(left: widget.height*0.1, right: widget.height*0.1, bottom: widget.height*0.08, top: widget.height*0.05),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          children: [
                            Text(
                              DateFormat('Hm', Localizations.localeOf(context).languageCode).format(startDate) + " - " + DateFormat('Hm', Localizations.localeOf(context).languageCode).format(endDate),
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.black),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(
                              width: widget.width * 0.05,
                              height: widget.height * 0.1,
                              child: const VerticalDivider(color: AppColors.black,),
                            ),
                            Text(
                              widget.event.numClients! != 1 ? widget.event.numClients!.toString()+" "+AppLocalizations.of(context)!.asistants.toLowerCase() : widget.event.numClients!.toString()+" "+AppLocalizations.of(context)!.asistants.toLowerCase().substring(0,AppLocalizations.of(context)!.asistants.length-1),
                              style: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.black),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: widget.height*0.2,
                          child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildEventFeedbackText(),
                                  SizedBox(
                                    width: widget.width*0.04,
                                    child: Image.asset(Constants.fireEmojiImage),
                                  ),
                                  buildEventFeedbackEntries(),
                                ],
                              )
                          ),
                        ),
                      ],
                    ),
                  ) : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: widget.height*0.1),
                        child: Text(
                          DateFormat('Hm', Localizations.localeOf(context).languageCode).format(startDate) + " - " + DateFormat('Hm', Localizations.localeOf(context).languageCode).format(endDate),
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.black),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        width: widget.width*0.4,
                        height: isDark ? widget.height*0.325 : widget.height*0.335,
                        margin: EdgeInsets.only(bottom: isDark ? 1 : 0),
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.event.isPrivate! ? Text(
                                  widget.event.numClients!.toString()+" "+AppLocalizations.of(context)!.asistants.toLowerCase(),
                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ) : Text(
                                  widget.event.numClients!.toString()+"/"+widget.event.maxMembers!.toString()+" "+AppLocalizations.of(context)!.asistants.toLowerCase(),
                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                        ),
                      ),
                    ],
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
