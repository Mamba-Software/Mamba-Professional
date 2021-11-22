import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/UserFeedBack.dart';
import 'package:page_transition/page_transition.dart';

import 'ReportBug.dart';

// Feedback Widget.
// Here the Users will give us Weekly Feedback.
class FeedBack extends StatefulWidget {
  const FeedBack({Key? key}) : super(key: key);

  @override
  _FeedBackState createState() => _FeedBackState();
}

class _FeedBackState extends State<FeedBack> {
  // Boolean New Feedback
  bool newFeedback = false;
  GroupOfQuestions groupOfQuestions = new GroupOfQuestions();
  var _accessDatabase = new DatabaseAccess();
  bool alreadyAnswered = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    this.checkIfAnswered();
  }

  Future<void> checkIfAnswered() async {
    this.groupOfQuestions =
        await this._accessDatabase.getActiveGroupOfQuestions();
    alreadyAnswered = await this
        ._accessDatabase
        .checkIfAnswersExist(this.groupOfQuestions.id);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.feedback,
                  style: Styles.purpleTextStyle
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 25,
                  color: Styles.accent,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: LoadingViewPurple(),
          )
        : alreadyAnswered
            ? Scaffold(
                appBar: AppBar(
                  title: Text(
                      AppLocalizations.of(context)!.feedback,
                    //AppLocalizations.of(context)!.createBrand,
                    style: Styles.purpleTextStyle
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  centerTitle: true,
                  elevation: 8,
                  iconTheme: IconThemeData(
                    color: Colors.white, //change your color here
                  ),
                  leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: 25,
                        color: Styles.accent,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.30,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        fit: StackFit.expand,
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            bottom: MediaQuery.of(context).size.height * 0.10,
                            left: MediaQuery.of(context).size.width * 0.65,
                            right: 0,
                            child: IconButton(
                              icon: Icon(
                                Icons.warning_amber,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.5),
                                size: 50,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.bottomToTop,
                                      child: ReportBug(),
                                    )).whenComplete(() {
                                  setState(() {
                                    //isLoading = true;
                                    //initProfileHome();
                                  });
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.30,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        fit: StackFit.expand,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.feedbackAnswered,
                            textAlign: TextAlign.center,
                            style: Styles.purpleTextStyle.copyWith(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  title: Text(
                    AppLocalizations.of(context)!.feedback,
                    //AppLocalizations.of(context)!.createBrand,
                    style: Styles.purpleTextStyle
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  centerTitle: true,
                  elevation: 8,
                  iconTheme: IconThemeData(
                    color: Colors.white, //change your color here
                  ),
                  leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: 25,
                        color: Styles.accent,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.30,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        fit: StackFit.expand,
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            bottom: MediaQuery.of(context).size.height * 0.10,
                            left: MediaQuery.of(context).size.width * 0.65,
                            right: 0,
                            child: IconButton(
                              icon: Icon(
                                Icons.warning_amber,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.5),
                                size: 50,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.bottomToTop,
                                      child: ReportBug(),
                                    )).whenComplete(() {
                                  setState(() {
                                    //isLoading = true;
                                    //initProfileHome();
                                  });
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.30,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        fit: StackFit.expand,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.feedbackNotAnswered,
                            textAlign: TextAlign.center,
                            style: Styles.purpleTextStyle.copyWith(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                              child: Text(AppLocalizations.of(context)!.responderFeedback),
                              style: TextButton.styleFrom(
                                  primary: Styles.mainColor),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.bottomToTop,
                                      child: UserFeedBack(
                                      ),
                                    )).whenComplete(() {
                                  setState(() {
                                    //isLoading = true;
                                    //initProfileHome();
                                  });
                                  this.checkIfAnswered();
                                });
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
  }
}
