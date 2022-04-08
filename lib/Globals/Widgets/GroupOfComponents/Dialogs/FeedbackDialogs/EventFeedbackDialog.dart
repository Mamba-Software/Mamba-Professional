import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class EventFeedbackDialog extends StatefulWidget {
  final Event event;
  final String brandLogo;
  EventFeedbackDialog({Key? key, required this.event, required this.brandLogo}) : super(key: key);

  @override
  _EventFeedbackDialogState createState() => _EventFeedbackDialogState();
}

class _EventFeedbackDialogState extends State<EventFeedbackDialog> {

  // Event Date
  var eventDate;
  var eventDateString;
  var eventHourString;

  @override
  void initState() {
    eventDate =  DateTime(
      int.parse(widget.event.year!),
      int.parse(widget.event.month!),
      int.parse(widget.event.day!),
      int.parse(widget.event.hour!),
      int.parse(widget.event.minute!),
    );

    super.initState();
  }

  Widget buildFeedbackIcon() {

    return Icon(
        Icons.star,
        color: Theme.of(context).accentColor
    );

    return Icon(
      Icons.favorite,
      color: AppColors.red,
    );

  }

  @override
  Widget build(BuildContext context) {
    eventDateString = DateFormat('EEEE dd/MM/yy', Localizations.localeOf(context).languageCode).format(eventDate);
    eventHourString = DateFormat('Hm', Localizations.localeOf(context).languageCode).format(eventDate);
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          height: MediaQuery.of(context).size.height*0.4,
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
                    child: Center(
                      child: RatingBar.builder(
                        itemCount: 3,
                        itemSize: MediaQuery.of(context).size.height*0.1,
                        itemBuilder: (context, _) => buildFeedbackIcon(),
                        onRatingUpdate: (rating) {

                        }
                      )
                    ),
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