import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DatabaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
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
  GroupOfQuestions? groupOfQuestions = new GroupOfQuestions();
  var _accessDatabase = new DatabaseAccess();
  bool alreadyAnswered = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    this.checkIfAnswered();
  }

  Future<void> checkIfAnswered() async {
    this.groupOfQuestions = await this._accessDatabase.getActiveGroupOfQuestions();
    if (groupOfQuestions != null) {
      alreadyAnswered = await this ._accessDatabase.checkIfAnswersExist(this.groupOfQuestions!.id);
    } else {
      alreadyAnswered = true;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.feedback, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 25,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: LoadingViewPurple(),
      )
        :
      Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.feedback, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22),),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 25,
            ),
            onPressed: () {
              Navigator.pop(context);
            }
          ),
        ),
        body: alreadyAnswered ?
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
              child: ListTile(
                onTap: () async {
                  Navigator.push(
                    context,
                      CupertinoPageRoute<String>(
                        builder: (context) => ReportBug(),
                    )
                  );
                },
                leading: Icon(
                  Icons.warning_amber,
                  color: Theme.of(context).accentColor,
                  size: 30,
                ),
                title: Text(
                  AppLocalizations.of(context)!.reporting,
                  style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).accentColor),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).accentColor,
                  size: 25,
                ),
              ),
            ),
            Container(
              height: 1,
              color: Theme.of(context).accentColor,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.10,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.15),
              child: Text(
                AppLocalizations.of(context)!.feedbackAnswered,
                textAlign: TextAlign.center,
                style: Styles.purpleTextStyle.copyWith(fontSize: 18),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.05,),
            Container(
                height: MediaQuery.of(context).size.height*0.25,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Theme.of(context).primaryColor,
                    style: BorderStyle.solid,
                  ),
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: Image.asset(Constants.doneFeedbackImage).image,
                  ),
                )
            ),
          ],
        ) :
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.02),
              child: ListTile(
                onTap: () async {
                  Navigator.push(
                      context,
                      CupertinoPageRoute<String>(
                        builder: (context) => ReportBug(),
                      )
                  );
                },
                leading: Icon(
                  Icons.warning_amber,
                  color: Theme.of(context).accentColor,
                  size: 30,
                ),
                title: Text(
                  AppLocalizations.of(context)!.reporting,
                  style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).accentColor),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).accentColor,
                  size: 25,
                ),
              ),
            ),
            Container(
              height: 1,
              color: Theme.of(context).accentColor,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.10,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.15),
              child: Text(
                AppLocalizations.of(context)!.feedbackNotAnswered,
                textAlign: TextAlign.center,
                style: Styles.purpleTextStyle.copyWith(fontSize: 18),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.05,),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                    CupertinoPageRoute<String>(
                      builder: (context) => UserFeedBack(
                    ),
                  )).whenComplete(() {
                      this.checkIfAnswered();
                  });
              },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.07),
                    child: Container(
                        height: MediaQuery.of(context).size.height*0.25,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Theme.of(context).primaryColor,
                            style: BorderStyle.solid,
                          ),
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.fitHeight,
                            image: Image.asset(Constants.giveFeedbackImage).image,
                          ),
                        )
                    ),
                  ),
                  Icon(Icons.touch_app, color: Theme.of(context).accentColor, size: MediaQuery.of(context).size.height*0.15,),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
