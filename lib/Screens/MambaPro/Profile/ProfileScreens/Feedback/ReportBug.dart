import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/FeedBack/FeedbackDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Report a Bug Widget.
class ReportBug extends StatefulWidget {
  const ReportBug({Key? key}) : super(key: key);

  @override
  _ReportBugState createState() => _ReportBugState();
}

class _ReportBugState extends State<ReportBug> {
  // Acceso a Base de Datos
  var _feedbackDataService = new FeedbackDataService();

  // Boolean Loading
  bool isLoading = false;
  bool errorIsSent = false;

  // Form Values
  final _formKey = GlobalKey<FormState>();
  String tituloTemp = "";
  String descriptionTemp = "";
  String stepsReproduceTemp = "";
  final tituloController = TextEditingController();
  final descriptionController = TextEditingController();
  final stepsReproduceController = TextEditingController();

  // Clears all values.
  void clearControllers() {
    tituloController.clear();
    descriptionController.clear();
    stepsReproduceController.clear();
  }

  // Sends error to the Database.
  Future<void> sendError() async {
    var result = await _feedbackDataService.addError(
        tituloTemp, descriptionTemp, stepsReproduceTemp);
    if (result) {
      setState(() {
        isLoading = false;
      });
      showTopSnackBar(
        context,
        CustomSnackBar.success(
          icon: Container(),
          iconRotationAngle: 0,
          backgroundColor: Colors.green,
          message: AppLocalizations.of(context)!.errorSent,
          textStyle: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: AppColors.white),
        ),
      );
      clearControllers();
      mixpanel!.track('user_profile_feedback_report_bug_succeeded');
    }
  }

  //Form to send the error
  Widget FormWidget() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TitleWidget(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          DescWidget(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          StepsWidget(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          SendCleanWidget(),
        ],
      ),
    );
  }

  //Text to enter the title
  Widget TitleWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.title,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        TextFormField(
          controller: tituloController,
          validator: (val) =>
              val!.isEmpty ? AppLocalizations.of(context)!.titleError : null,
          onChanged: (val) {
            setState(() => tituloTemp = val);
          },
          style: Theme.of(context).textTheme.bodyText2,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.titleHint,
            hintStyle: Theme.of(context).textTheme.caption,
          ),
          enabled: true,
        ),
      ],
    );
  }

  //Text to enter the description
  Widget DescWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.description,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        TextFormField(
          controller: descriptionController,
          validator: (val) => val!.isEmpty
              ? AppLocalizations.of(context)!.descriptionError
              : null,
          onChanged: (val) {
            setState(() => descriptionTemp = val);
          },
          minLines: 1,
          maxLines: 6,
          style: Theme.of(context).textTheme.bodyText2,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.descriptionError,
            hintStyle: Theme.of(context).textTheme.caption,
          ),
        ),
      ],
    );
  }

  //Text to enter the steps
  Widget StepsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.reproducteSteps,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        TextFormField(
          controller: stepsReproduceController,
          onChanged: (val) {
            setState(() => stepsReproduceTemp = val);
          },
          minLines: 1,
          maxLines: 3,
          style: Theme.of(context).textTheme.bodyText2,
          decoration: InputDecoration(
            hintMaxLines: 2,
            hintText: AppLocalizations.of(context)!.reproducteStepsHint,
            hintStyle: Theme.of(context).textTheme.caption,
          ),
          enabled: true,
        ),
      ],
    );
  }

  Widget SendCleanWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
          child: Container(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.30,
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_outlined,
                    color: AppColors.white,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        sendError();
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.send,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(color: AppColors.white)),
                  )
                ],
              )),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
        ),
        Material(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
          child: Container(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.30,
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.clear,
                    color: AppColors.white,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  TextButton(
                    onPressed: () async {
                      clearControllers();
                    },
                    child: Text(AppLocalizations.of(context)!.clear,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(color: AppColors.white)),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.reporting,
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
            body: LoadingView())
        : Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.reporting,
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
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.height * 0.02),
                child: FormWidget(),
              ),
            ),
          );
  }
}
