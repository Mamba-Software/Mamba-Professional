import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/BuildAddUserButton.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/LeaveConfirmationDialogBonos.dart';

TextEditingController durationController = TextEditingController();
bool errorNoTrainerSelected = false;

Widget clientEventWidget(
    BuildContext context, List<Usuario> brandClientsSelected) {
  if (brandClientsSelected.isEmpty) {
    errorNoTrainerSelected = true;
  } else {
    errorNoTrainerSelected = false;
  }
  return Column(
    children: [
      //JMF_AddUser_BEGIN
      //widget.eventId == null && isRecurrent
      Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.005),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildAddUserButton(context, false, brandClientsSelected),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: brandClientsSelected.length,
                      itemBuilder: (context, int index) {
                        var client = brandClientsSelected[index];
                        return GestureDetector(
                          onTap: () async {
                            final state = context.read<CrudEventCubit>().state;
                            List<Bono> selectedBonos = [];
                            if (state.isLoaded) {
                              selectedBonos = state.newEvent.eventBonos!.keys
                                  .where((key) =>
                                      state.newEvent.eventBonos![key] == true)
                                  .toList();
                            }
                            if (selectedBonos.isNotEmpty &&
                                client.purchaseId != "") {
                              //JMF_AddUser_BEGIN
                              var result = await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return LeaveConfirmationDialogBonos(
                                      text: AppLocalizations.of(context)!
                                          .leaveEventConfirmation,
                                      brand: currentBrand,
                                      bonos: selectedBonos,
                                      purchaseId: client.purchaseId!,
                                      user: client,
                                    );
                                  });
                              if (result != null && result) {
                                var temp = brandClientsSelected;
                                temp.remove(client);
                                context
                                    .read<CrudEventCubit>()
                                    .editEventInfo(temp, EditEventType.clients);
                              }
                            } else {
                              var temp = brandClientsSelected;
                              temp.remove(client);
                              context
                                  .read<CrudEventCubit>()
                                  .editEventInfo(temp, EditEventType.clients);
                            }

                            //JMF_AddUser_END
                          },
                          child: Padding(
                            padding: !(index == brandClientsSelected.length - 1)
                                ? const EdgeInsets.symmetric(horizontal: 8.0)
                                : EdgeInsets.only(
                                    right: brandClientsSelected.length != 1
                                        ? MediaQuery.of(context).size.width *
                                            0.06
                                        : 8.0,
                                    left: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    CircularImage(
                                      size: MediaQuery.of(context).size.width *
                                          0.17,
                                      image: client.imageUrl,
                                      color: Theme.of(context).primaryColor,
                                      borderWidth: 1,
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: MediaQuery.of(context).size.width *
                                          0.12,
                                      child: CircleAvatar(
                                        backgroundColor: AppColors.red,
                                        radius:
                                            MediaQuery.of(context).size.width *
                                                0.025,
                                        child: Icon(
                                          Icons.clear,
                                          color: AppColors.white,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.035,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width * 0.02,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        client.firstName!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
      //JMF_AddUser_END
    ],
  );
}
