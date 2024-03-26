import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba/data/DataService/FeedBack/FeedbackDataService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/data/Models/Deprecated/GroupOfQuestions.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'ReportBug.dart';

// Feedback Widget.
// Here the Users will give us Weekly Feedback.
class FeedBack extends StatefulWidget {
  const FeedBack({super.key});

  @override
  _FeedBackState createState() => _FeedBackState();
}

class _FeedBackState extends State<FeedBack> {
  // Feedback Data Service
  final _feedbackDataService = FeedbackDataService();
  // Boolean New Feedback
  bool newFeedback = false;
  GroupOfQuestions? groupOfQuestions = GroupOfQuestions();
  bool alreadyAnswered = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    mixpanel!.track('user_profile_feedback_view');
    checkIfAnswered();
  }

  Future<void> checkIfAnswered() async {
    groupOfQuestions = await _feedbackDataService.getActiveGroupOfQuestions();
    if (groupOfQuestions != null) {
      alreadyAnswered =
          await _feedbackDataService.checkIfAnswersExist(groupOfQuestions!.id);
    } else {
      alreadyAnswered = true;
    }
    setState(() {});
  }

  Future<void> launchEmail() async {
    mixpanel!.track('user_help_email');
    String url = 'mailto:$contactEmail';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  Future<void> launchWhatsApp() async {
    mixpanel!.track('user_help_whatsapp');
    if (await canLaunchUrlString(whatsappUrl)) {
      await launchUrlString(
        whatsappUrl,
        mode: LaunchMode.externalNonBrowserApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.help,
            style: Theme.of(context).appBarTheme.titleTextStyle,
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
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () async {
                  mixpanel!.track('user_help_email');
                  Navigator.push(
                      context,
                      CupertinoPageRoute<String>(
                        builder: (context) => const ReportBug(),
                      ));
                },
                contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.width * 0.02),
                leading: Icon(Icons.warning_amber,
                    size: MediaQuery.of(context).size.width * 0.07,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  AppLocalizations.of(context)!.reporting,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              /*
              const Divider(color: AppColors.grey, height: 1),
              ListTile(
                onTap: () async {
                  mixpanel!.track('user_help_email');
                  Navigator.push(
                      context,
                      CupertinoPageRoute<String>(
                        builder: (context) => const ReportBug(),
                      ));
                },
                contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.width * 0.02),
                leading: Icon(Icons.help_outline_outlined,
                    size: MediaQuery.of(context).size.width * 0.07,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  AppLocalizations.of(context)!.giveFeedbackTitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              */
              const Divider(color: AppColors.grey, height: 1),
              ListTile(
                onTap: launchWhatsApp,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.width * 0.02),
                leading: Icon(Icons.chat_bubble_outline_outlined,
                    size: MediaQuery.of(context).size.width * 0.07,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  AppLocalizations.of(context)!.getInTouchChat,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(color: AppColors.grey, height: 1),
              ListTile(
                onTap: launchEmail,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.width * 0.02),
                leading: Icon(Icons.email_outlined,
                    size: MediaQuery.of(context).size.width * 0.07,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  AppLocalizations.of(context)!.getInTouchText,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(color: AppColors.grey, height: 1),
            ],
          ),
        )
        /*
            body: alreadyAnswered
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.01),
                        child: ListTile(
                          onTap: () async {
                            mixpanel!
                                .track('user_profile_feedback_report_bug_open');
                            Navigator.push(
                                context,
                                CupertinoPageRoute<String>(
                                  builder: (context) => const ReportBug(),
                                ));
                          },
                          leading: Icon(
                            Icons.warning_amber,
                            color: Theme.of(context).colorScheme.secondary,
                            size: MediaQuery.of(context).size.width * 0.05,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.reporting,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.mainColor),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).colorScheme.secondary,
                            size: MediaQuery.of(context).size.width * 0.05,
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.2),
                        child: Text(
                          AppLocalizations.of(context)!.feedbackAnswered,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.20,
                          child: Image.asset(Assets.doneFeedbackImage)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.01),
                        child: ListTile(
                          onTap: () async {
                            Navigator.push(
                                context,
                                CupertinoPageRoute<String>(
                                  builder: (context) => const ReportBug(),
                                ));
                          },
                          leading: Icon(
                            Icons.warning_amber,
                            color: Theme.of(context).colorScheme.secondary,
                            size: MediaQuery.of(context).size.width * 0.05,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.reporting,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.mainColor),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).colorScheme.secondary,
                            size: MediaQuery.of(context).size.width * 0.05,
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.15),
                        child: Text(
                          AppLocalizations.of(context)!.feedbackNotAnswered,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      GestureDetector(
                        onTap: () {
                          /*
                Navigator.push(
                  context,
                    CupertinoPageRoute<String>(
                      builder: (context) => UserFeedBack(
                    ),
                  )).whenComplete(() {
                      checkIfAnswered();
                  });
                 */
                        },
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).size.height *
                                      0.07),
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.25,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Theme.of(context).primaryColor,
                                      style: BorderStyle.solid,
                                    ),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.fitHeight,
                                      image: Image.asset(
                                              Assets.giveFeedbackImage)
                                          .image,
                                    ),
                                  )),
                            ),
                            Icon(
                              Icons.touch_app,
                              color: Theme.of(context).colorScheme.secondary,
                              size: MediaQuery.of(context).size.height * 0.15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            */
        );
  }
}
