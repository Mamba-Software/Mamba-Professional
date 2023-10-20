import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Events/crud_events/views/InformationPage.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/Bonos/EventBonosBlocSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/Location/LocationBlocSelector.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/LocationView.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/TitleDescriptionWidget.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDateDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDurationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectMembersDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectTimeDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteRecurrentEventDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/EditRecurrentEventDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/LeaveConfirmationDialogBonos.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/SelectEventUsers/SelectClientsEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/SelectEventUsers/SelectTrainersEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LocationAutoComplete/MyLocationsSelect.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:uuid/uuid.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../Data/Models/Bono.dart';

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
                            TitleDescriptionWidget(
                              contextFrom: context,
                            ),
                            locationBlocSelector(),
                            eventBonosBlocSelector(),
                          ],
                        ),
                      ),
                    ]),
              ],
            )),
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}
