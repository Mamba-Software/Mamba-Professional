// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mamba/data/DataService/FeedBack/FeedbackDataService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:mamba/l10n/language_manager.dart';

// Report a Bug Widget.
class ReportBug extends StatefulWidget {
  const ReportBug({super.key});

  @override
  _ReportBugState createState() => _ReportBugState();
}

class _ReportBugState extends State<ReportBug> {
  // Acceso a Base de Datos
  final _feedbackDataService = FeedbackDataService();

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
        Overlay.of(context),
        CustomSnackBar.success(
          icon: Container(),
          iconRotationAngle: 0,
          backgroundColor: Colors.green,
          message: context.l10n.errorSent,
          textStyle: Theme.of(context)
              .textTheme
              .bodyLarge!
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.015,
          ),
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
        Text(context.l10n.title,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(15.0),
          child: TextFormField(
            controller: tituloController,
            validator: (val) => val!.isEmpty ? context.l10n.titleError : null,
            onChanged: (val) {
              setState(() => tituloTemp = val);
            },
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
                hintText: context.l10n.titleError,
                hintStyle: Theme.of(context).textTheme.bodySmall,
                errorStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.red),
                border: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8)),
            enabled: true,
          ),
        ),
      ],
    );
  }

  //Text to enter the description
  Widget DescWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.description,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(15.0),
          child: TextFormField(
            controller: descriptionController,
            validator: (val) =>
                val!.isEmpty ? context.l10n.descriptionError : null,
            onChanged: (val) {
              setState(() => descriptionTemp = val);
            },
            minLines: 1,
            maxLines: 6,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
                hintText: context.l10n.descriptionError,
                hintStyle: Theme.of(context).textTheme.bodySmall,
                errorStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.red),
                border: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8)),
            enabled: true,
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
        Text(context.l10n.reproducteSteps,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(15.0),
          child: TextFormField(
            controller: stepsReproduceController,
            onChanged: (val) {
              setState(() => stepsReproduceTemp = val);
            },
            minLines: 1,
            maxLines: 5,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
                hintMaxLines: 5,
                hintText: context.l10n.reproducteStepsHint,
                hintStyle: Theme.of(context).textTheme.bodySmall,
                errorStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.red),
                border: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8)),
            enabled: true,
          ),
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
          ),
          child: Container(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(30)),
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
                    child: Text(context.l10n.send,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.white)),
                  )
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
                context.l10n.reporting,
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
                context.l10n.reporting,
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
