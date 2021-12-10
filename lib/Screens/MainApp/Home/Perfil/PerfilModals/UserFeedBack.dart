import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/GroupOfQuestions.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class UserFeedBack extends StatefulWidget {
  const UserFeedBack({Key? key}) : super(key: key);

  @override
  _UserFeedBackState createState() => _UserFeedBackState();
}

class _UserFeedBackState extends State<UserFeedBack> {
  //DataBase Access
  var _accessDatabase = new DatabaseAccess();

  GroupOfQuestions? groupOfQuestions = new GroupOfQuestions();
  bool isLoading = true;
  String questionOne = "", questionTwo = "", questionThree = "", questionFour = "";

  @override
  void initState() {
    super.initState();
    isLoading = true;
    this.activeGroup();
  }

  Future<void> activeGroup() async {

    currentUser = await _accessDatabase.getCurrentUserDetails();

    this.groupOfQuestions = await this._accessDatabase.getActiveGroupOfQuestions();

    if(currentUser.idioma == "ca") {
      questionOne = (await this._accessDatabase.getOneQuestion(this.groupOfQuestions!.questionOne)).questionCat!;
      questionTwo = (await this._accessDatabase.getOneQuestion(this.groupOfQuestions!.questionTwo)).questionCat!;
      questionThree = (await this._accessDatabase.getOneQuestion(this.groupOfQuestions!.questionThree)).questionCat!;
      questionFour = (await this._accessDatabase.getOneQuestion(this.groupOfQuestions!.questionFour)).questionCat!;
    }
    else {
      questionOne = (await this._accessDatabase.getOneQuestion(this.groupOfQuestions!.questionOne)).questionSpn!;
      questionTwo = (await this._accessDatabase.getOneQuestion(this.groupOfQuestions!.questionTwo)).questionSpn!;
      questionThree = (await this._accessDatabase.getOneQuestion(this.groupOfQuestions!.questionThree)).questionSpn!;
      questionFour = (await this._accessDatabase.getOneQuestion(this.groupOfQuestions!.questionFour)).questionSpn!;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  isLoading ?
      Scaffold(
        body: LoadingViewPurple(),
      )
        :
     Scaffold(
       body: Container(
         color: Colors.white,
         child: Align(
           alignment: Alignment.center,
           child: FutureBuilder<Task>(
             future: getSampleTask(),
             builder: (context, snapshot) {
               if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                 final task = snapshot.data!;
                 return SurveyKit(
                   onResult: (SurveyResult result) {
                     if(result.finishReason.toString() == "FinishReason.COMPLETED") {
                       this._accessDatabase.addAnswers(
                         this.groupOfQuestions!.id, result.results[0]
                         .results[0].valueIdentifier, result.results[1]
                         .results[0].valueIdentifier,
                         result.results[2].results[0].valueIdentifier, result
                         .results[3].results[0].valueIdentifier
                       );
                       sendFeedback();
                     }
                     //else notSendFeedback();
                   },
                   task: task,
                   themeData: Styles.lightTheme.copyWith(
                      primaryColor: Theme.of(context).accentColor,
                      backgroundColor: Colors.white,
                      outlinedButtonTheme: OutlinedButtonThemeData(
                       style: ButtonStyle(
                         minimumSize: MaterialStateProperty.all(
                           Size(MediaQuery.of(context).size.width*0.4, MediaQuery.of(context).size.height*0.07),
                         ),
                         side: MaterialStateProperty.resolveWith(
                               (Set<MaterialState> state) {
                             if (state.contains(MaterialState.disabled)) {
                               return BorderSide(
                                 color: Colors.grey,
                               );
                             }
                             return BorderSide(
                               color: Theme.of(context).accentColor,
                             );
                           },
                         ),
                         shape: MaterialStateProperty.all(
                           RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10.0),
                           ),
                         ),
                       ),
                     ),
                   )
                 );
               } else {
                 return CircularProgressIndicator.adaptive(value: 1, backgroundColor: Theme.of(context).accentColor);
               }
             },
           ),
         ),
       ),
    );
  }
  Future<void> sendFeedback() async {
    showTopSnackBar(
        context,
        CustomSnackBar.success(
          icon: Container(),
          iconRotationAngle: 0,
          backgroundColor: Colors.green,
          message: AppLocalizations.of(context)!.feedbackSent,
          textStyle: Styles.whiteTextStyle,
        ),
      );
    }

  Future<void> notSendFeedback() async {
    showTopSnackBar(
      context,
      CustomSnackBar.success(
        icon: Container(),
        iconRotationAngle: 0,
        backgroundColor: Colors.red,
        message: AppLocalizations.of(context)!.feedbackNotSent,
        textStyle: Styles.whiteTextStyle,
      ),
    );
  }

  Future<Task> getSampleTask() {
     var task = NavigableTask(
       id: TaskIdentifier(),
       steps: [
         QuestionStep(
           title: questionOne,
           answerFormat: BooleanAnswerFormat(
             positiveAnswer: 'Si',
             negativeAnswer: 'No',
             result: BooleanResult.POSITIVE,
           ),
         ),
         QuestionStep(
           title: questionTwo,
           answerFormat: ScaleAnswerFormat(
             step: 1,
             minimumValue: 1,
             maximumValue: 10,
             defaultValue: 5,
             minimumValueDescription: '1',
             maximumValueDescription: '10',
           ),
         ),
         QuestionStep(
           title: questionThree,
           answerFormat: SingleChoiceAnswerFormat(
             defaultSelection: TextChoice(text: '\u{1F600}', value: '\u{1F600}'),
             textChoices: [
               TextChoice(text: '\u{1F600}', value: '\u{1F600}'),
               TextChoice(text: '\u{1F60A}', value: '\u{1F60A}'),
               TextChoice(text: '\u{1F610}', value: '\u{1F610}'),
               TextChoice(text: '\u{1F614}', value: '\u{1F614}'),
               TextChoice(text: '\u{1F620}', value: '\u{1F620}'),
             ],
           ),
         ),
         QuestionStep(
           title: questionFour,
           answerFormat: TextAnswerFormat(
             maxLines: 50,
             validationRegEx: "^(?!\s*\$).+",
           ),
         ),
        CompletionStep(
           stepIdentifier: StepIdentifier(id: '321'),
           text: AppLocalizations.of(context)!.finishedFeedbackSubtitle,
           title: AppLocalizations.of(context)!.finishedFeedback,
           buttonText: AppLocalizations.of(context)!.sendFeedback,
         ),
       ],
     );
     task.addNavigationRule(
       forTriggerStepIdentifier: task.steps[3].stepIdentifier,
       navigationRule: ConditionalNavigationRule(
         resultToStepIdentifierMapper: (input) {
           switch (input) {
             case "":
               return task.steps[3].stepIdentifier;
               break;
             /*case "Yes":
               return task.steps[0].stepIdentifier;
             case "No":
               return task.steps[7].stepIdentifier;*/
             default:
               return task.steps[4].stepIdentifier;
           }
         },
       ),
     );
     return Future.value(task);
  }
}