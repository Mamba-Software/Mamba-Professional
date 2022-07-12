import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Providers/FirebaseAnalyticsProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class EventFeedbackDialog extends StatefulWidget {
  final Event event;
  final int? feedbackScore;
  final String brandLogo;
  EventFeedbackDialog({Key? key, required this.event, required this.brandLogo, this.feedbackScore}) : super(key: key);

  @override
  _EventFeedbackDialogState createState() => _EventFeedbackDialogState();
}

class _EventFeedbackDialogState extends State<EventFeedbackDialog> {

  // User Data Service
  var _eventDataService = new EventDataService();
  // Event Date
  var eventDate;
  var eventDateString;
  var eventHourString;
  // Event Feedback Score
  int feedbackScore = 0;

  @override
  void initState() {
    eventDate =  DateTime(
      int.parse(widget.event.year!),
      int.parse(widget.event.month!),
      int.parse(widget.event.day!),
      int.parse(widget.event.hour!),
      int.parse(widget.event.minute!),
    );
    if (widget.feedbackScore != null) {
      feedbackScore = widget.feedbackScore!;
    }
    super.initState();
  }

  Widget buildFeedbackWithStarIcon() {
    return Container(
      height: MediaQuery.of(context).size.height*0.15,
      width: MediaQuery.of(context).size.width*0.70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height*0.1,
            width: MediaQuery.of(context).size.width*0.70,
            child: Center(
              child: RatingBar.builder(
                  initialRating: feedbackScore.toDouble(),
                  itemCount: 3,
                  itemSize: MediaQuery.of(context).size.height*0.1,
                  itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Theme.of(context).accentColor
                  ),
                  onRatingUpdate: (rating) {
                    userHasAnsweredFeedback(rating);
                  }
              ),
            ),
          ),
          buildFeedbackLabel(),
        ],
      )
    );
  }

  Widget buildFeedbackLabel() {
    return Container(
      height: MediaQuery.of(context).size.height*0.05,
      width: MediaQuery.of(context).size.width*0.70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width*0.23,
            child: Text(
              AppLocalizations.of(context)!.relaxedFeedbackLabel,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width*0.23,
            child: Text(
              AppLocalizations.of(context)!.tiredFeedbackLabel,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width*0.23,
            child: Text(
              AppLocalizations.of(context)!.exhaustedFeedbackLabel,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFeedbackWithEmjois() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () => userHasAnsweredFeedback(1),
          child: Container(
              height: MediaQuery.of(context).size.height*0.16,
              width: MediaQuery.of(context).size.width*0.18,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.02),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 4.0, color: feedbackScore == 1 ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor),
                ),
              ),
              child: Column(
                children: [
                  Image.asset(Constants.relaxedEmojiImage),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Text(
                    AppLocalizations.of(context)!.relaxedFeedbackLabel,
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                ],
              )

          ),
        ),
        GestureDetector(
          onTap: () => userHasAnsweredFeedback(2),
          child: Container(
              height: MediaQuery.of(context).size.height*0.16,
              width: MediaQuery.of(context).size.width*0.18,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.01),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 4.0, color: feedbackScore == 2 ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor),
                ),
              ),
              child: Column(
                children: [
                  Image.asset(Constants.tiredEmojiImage),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Text(
                    AppLocalizations.of(context)!.tiredFeedbackLabel,
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                ],
              )
          ),
        ),
        GestureDetector(
          onTap: () => userHasAnsweredFeedback(3),
          child: Container(
              height: MediaQuery.of(context).size.height*0.16,
              width: MediaQuery.of(context).size.width*0.18,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.02),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 4.0, color: feedbackScore == 3 ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor),
                ),
              ),
              child: Column(
                children: [
                  Image.asset(Constants.sweatingEmojiImage),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Text(
                    AppLocalizations.of(context)!.exhaustedFeedbackLabel,
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                ],
              )
          ),
        ),
      ],
    );
  }

  void userHasAnsweredFeedback(double value) {
    var limitDateToAnswer = eventDate.add(Duration(days: 7));
    print(widget.event.id!);
    if (DateTime.now().isBefore(limitDateToAnswer)) {
      // Database
      _eventDataService.updateEventFeedback(widget.event.id!, currentUser.id!, value);
      print(widget.event.id!);
      // Send Analytics
      if (currentUser.testGroup == "A") {
        // Edit Event?
        if (widget.feedbackScore != null) {
          Provider.of<FirebaseAnalyticsProvider>(context, listen: false).sendAnalyticsUserEditEventFeedbackTestA();
        } else {
          // First Answer
          Provider.of<FirebaseAnalyticsProvider>(context, listen: false).sendAnalyticsUserAnswerEventFeedbackTestA();
        }
      } else {
        // Edit Event?
        if (widget.feedbackScore != null) {
          Provider.of<FirebaseAnalyticsProvider>(context, listen: false).sendAnalyticsUserEditEventFeedbackTestB();
        } else {
          // First Answer
          Provider.of<FirebaseAnalyticsProvider>(context, listen: false).sendAnalyticsUserAnswerEventFeedbackTestB();
        }
      }
      // Pop passing the Value;
      Navigator.pop(context, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    eventDateString = DateFormat('EEEE dd/MM/yy', Localizations.localeOf(context).languageCode).format(eventDate);
    eventHourString = DateFormat('Hm', Localizations.localeOf(context).languageCode).format(eventDate);
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(MediaQuery.of(context).size.height*0.02),
        child: Container(
          height: MediaQuery.of(context).size.height*0.47,
          width: MediaQuery.of(context).size.width*0.9,
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height*0.07),
                  Text(
                    widget.event.title!,
                    style: Theme.of(context).textTheme.headline1?.copyWith(height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  Container(
                    width: MediaQuery.of(context).size.width*0.70,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.date_range_outlined, color: AppColors.grey, size: MediaQuery.of(context).size.width *0.05,),
                              SizedBox(width: MediaQuery.of(context).size.width *0.02),
                              Text(
                                  StringUtils().toCapitalized(eventDateString),
                                  style: Theme.of(context).textTheme.caption,
                                  textAlign: TextAlign.center
                              ),
                            ],
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width*0.05),
                          Row(
                            children: [
                              Icon(Icons.schedule, color: AppColors.grey, size: MediaQuery.of(context).size.width *0.05,),
                              SizedBox(width: MediaQuery.of(context).size.width *0.02),
                              Text(
                                  StringUtils().toCapitalized(eventHourString),
                                  style: Theme.of(context).textTheme.caption,
                                  textAlign: TextAlign.center
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.04),
                  Text(
                    AppLocalizations.of(context)!.eventFeedbackText,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.04),
                  Container(
                    width: MediaQuery.of(context).size.width*0.70,
                    child: currentUser.testGroup == "A" ? buildFeedbackWithEmjois() : buildFeedbackWithStarIcon(),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.04),
                ],
              ),
              Positioned(
                  bottom: 0,
                  top: -MediaQuery.of(context).size.height*0.07,
                  child: CircularImage(
                    size: MediaQuery.of(context).size.height*0.13,
                    image: widget.brandLogo,
                    color: AppColors.grey,
                    borderWidth: 1,
                  )
              ),
            ],
          ),
        ),
      );
  }
}