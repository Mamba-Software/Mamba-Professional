import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/views/mobile/CrudEventPage.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Bonos/EventBonosBlocSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Clients/ClientEventSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateTimeEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Location/LocationBlocSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Staff/StaffEventSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/TitleDescription/TitleDescriptionBlocSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/TitleDescription/TitleDescriptionWidget.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddOrEditEvent extends StatelessWidget {
  Locale locale;
  String? eventId;
  DateTime? dateTime;
  bool isBeforeEdit;

  AddOrEditEvent(
      {Key? key,
      required this.locale,
      this.eventId,
      this.dateTime,
      required this.isBeforeEdit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
        title: eventId == null
            ? Text(AppLocalizations.of(context)!.createEvent,
                style: Theme.of(context).appBarTheme.titleTextStyle)
            : Text(
                AppLocalizations.of(context)!.editEvent,
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
        actions: [
          eventId != null
              ? IconButton(
                  onPressed: () async {},
                  icon: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outlined,
                          color: AppColors.red,
                          size: MediaQuery.of(context).size.width * 0.07,
                        )
                      ],
                    ),
                  ))
              : SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.groups,
                        color: Theme.of(context).primaryColor,
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(AppLocalizations.of(context)!.group,
                              style: Theme.of(context).textTheme.bodyText2,
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03)
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Scaffold(
        body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05),
                        child: Column(
                          children: [
                            CrudEventPage(locale: locale),
                          ],
                        ),
                      ),
                    ]),
              ],
            )),
        resizeToAvoidBottomInset: true,
      ),
      floatingActionButton: BlocBuilder<CrudEventCubit, CrudEventLoaded>(
          builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.01,
                  left: MediaQuery.of(context).size.width * 0.09),
              child: Container(
                height: 50,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01),
              child: SizedBox(
                height: 50,
                child: FloatingActionButton.extended(
                  heroTag: "48",
                  onPressed: () async {
                    if (state.isValidated.every((bool value) => value)) {
                      if (state.isNew) {
                        context
                            .read<CrudEventCubit>()
                            .addEventFunction(context, state.newEvent);
                        Navigator.pop(context);
                      }
                    }
                  },
                  backgroundColor:
                      state.isValidated.every((bool value) => value)
                          ? Colors.green
                          : Colors.grey,
                  icon: Container(),
                  label: eventId == null
                      ? Text(
                          AppLocalizations.of(context)!.createEvent,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: AppColors.white),
                        )
                      : Text(
                          AppLocalizations.of(context)!.editEvent,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: AppColors.white),
                        ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
