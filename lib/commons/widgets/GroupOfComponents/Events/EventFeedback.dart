import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/l10n/language_manager.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class EventFeedback extends StatefulWidget {
  String eventId;
  EventFeedback({super.key, required this.eventId});

  @override
  _EventFeedbackState createState() => _EventFeedbackState();
}

class _EventFeedbackState extends State<EventFeedback> {
  // User Data Service
  final _eventDataService = EventDataService();

  // Boolean isLoading
  bool isLoading = true;
  bool isLoadingBody = false;

  // Event and Brand
  Event event = Event();
  Brand brand = Brand();

  // Dates
  var eventDate;
  var eventDateString;
  var eventHourString;

  // Event Feedback Score
  double feedbackScore = 0;

  @override
  void initState() {
    getEventInfo();
    super.initState();
  }

  void getEventInfo() async {
    event = await _eventDataService.getSingleEvent(widget.eventId);
    var listBrands = await _eventDataService.getEventBrands(widget.eventId);
    brand = listBrands[0];
    eventDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );
    eventDateString = DateFormat(
            'EEEE dd/MM/yy', Localizations.localeOf(context).languageCode)
        .format(eventDate);
    eventHourString =
        DateFormat('Hm', Localizations.localeOf(context).languageCode)
            .format(eventDate);
    setState(() {
      isLoading = false;
    });
  }

  Widget buildFeedbackWithStarIcon() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        feedbackScore != 0
            ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: buildResultEmojis())
            : Container(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
          child: Center(
            child: Column(
              children: [
                RatingBar.builder(
                    allowHalfRating: true,
                    initialRating: feedbackScore.toDouble(),
                    itemCount: 10,
                    itemSize: MediaQuery.of(context).size.height * 0.04,
                    itemBuilder: (context, index) => Container(
                          child: Image.asset(Assets.fireEmojiImage),
                        ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        feedbackScore = rating;
                      });
                    }),
                Text(
                  context.l10n.eventFeedbackIntesityText,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildResultEmojis() {
    var result = 0;
    if (feedbackScore > 8) {
      result = 4;
    } else if (feedbackScore >= 6) {
      result = 3;
    } else if (feedbackScore >= 4) {
      result = 2;
    } else {
      result = 1;
    }

    switch (result) {
      case 1:
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                feedbackScore.toString(),
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              Image.asset(Assets.relaxedEmojiImage),
              Text(
                context.l10n.relaxedFeedbackLabel,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case 2:
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                feedbackScore.toString(),
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              Image.asset(Assets.tiredEmojiImage),
              Text(
                context.l10n.tiredFeedbackLabel,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case 3:
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                feedbackScore.toString(),
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              Image.asset(Assets.exhalingEmojiImage),
              Text(
                context.l10n.veryTiredFeedbackLabel,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case 4:
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                feedbackScore.toString(),
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              Image.asset(Assets.sweatingEmojiImage),
              Text(
                context.l10n.exhaustedFeedbackLabel,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }

  Future<void> userHasAnsweredFeedback(double value) async {
    // Database
    await _eventDataService.addEventFeedback(event.id!, currentUser.id!, value);
    // Pop passing the Value;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: isLoading
            ? SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.35,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(
                                      MediaQuery.of(context).size.height *
                                          0.35),
                                  bottomRight: Radius.circular(
                                      MediaQuery.of(context).size.height *
                                          0.35)),
                              color: AppColors.lightGrey,
                              shape: BoxShape.rectangle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              color: AppColors.grey,
                              shape: BoxShape.rectangle,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              color: AppColors.grey,
                              shape: BoxShape.rectangle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              color: AppColors.grey,
                              shape: BoxShape.rectangle,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              color: AppColors.grey,
                              shape: BoxShape.rectangle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: const BoxDecoration(
                                color: AppColors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                      ],
                    ),
                  ],
                ),
              )
            : SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                    MediaQuery.of(context).size.height * 0.35),
                                bottomRight: Radius.circular(
                                    MediaQuery.of(context).size.height * 0.35)),
                            color: Theme.of(context).colorScheme.background,
                            shape: BoxShape.rectangle,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            context.l10n.eventFeedbackText,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.20,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: buildFeedbackWithStarIcon(),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            event.title!,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Row(
                            children: [
                              Icon(
                                Icons.date_range_outlined,
                                color: AppColors.grey,
                                size: MediaQuery.of(context).size.width * 0.07,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02),
                              Text(StringUtils().toCapitalized(eventDateString),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: AppColors.grey),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: AppColors.grey,
                                size: MediaQuery.of(context).size.width * 0.07,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02),
                              Text(StringUtils().toCapitalized(eventHourString),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: AppColors.grey),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: AppColors.grey,
                                size: MediaQuery.of(context).size.width * 0.07,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02),
                              Text(
                                  StringUtils()
                                      .durationToString(event.duration!),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: AppColors.grey),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Row(
                            children: [
                              CircularImage(
                                size: MediaQuery.of(context).size.width * 0.07,
                                image: brand.logoUrl,
                                color: AppColors.grey,
                                borderWidth: 1,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02),
                              Text(brand.name!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: AppColors.grey),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.width * 0.04),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (feedbackScore != 0) {
                              setState(() {
                                isLoadingBody = true;
                              });
                              userHasAnsweredFeedback(feedbackScore);
                            }
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                                color: feedbackScore != 0
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: !isLoadingBody
                                ? Center(
                                    child: Text(
                                      context.l10n.save,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                              color: feedbackScore != 0
                                                  ? Theme.of(context)
                                                      .primaryColorDark
                                                  : Theme.of(context)
                                                      .primaryColorDark
                                                      .withOpacity(0.4)),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : Center(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.06,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                      child: CircularProgressIndicator(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                      ],
                    ),
                  ],
                ),
              ));
  }
}
