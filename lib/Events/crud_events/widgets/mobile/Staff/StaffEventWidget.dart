import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/BuildAddUserButton.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDurationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectTimeDialog.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';

TextEditingController durationController = TextEditingController();
bool errorNoTrainerSelected = false;

Widget staffEventWidget(
    BuildContext context, List<Usuario> brandTrainersSelected) {
  if (brandTrainersSelected.isEmpty) {
    errorNoTrainerSelected = true;
  } else {
    errorNoTrainerSelected = false;
  }
  return Column(
    children: [
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
                buildAddUserButton(context, true, brandTrainersSelected),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: brandTrainersSelected.length,
                      itemBuilder: (context, int index) {
                        var trainer = brandTrainersSelected[index];
                        return brandTrainersSelected.length > 1
                            ? GestureDetector(
                                onTap: () {
                                  var temp = brandTrainersSelected;
                                  temp.remove(trainer);
                                  context.read<CrudEventCubit>().editEventInfo(
                                      temp, EditEventType.trainers);
                                },
                                child: Padding(
                                  padding: !(index ==
                                          brandTrainersSelected.length - 1)
                                      ? const EdgeInsets.symmetric(
                                          horizontal: 8.0)
                                      : EdgeInsets.only(
                                          right:
                                              brandTrainersSelected.length != 1
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
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
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.17,
                                            image: trainer.imageUrl,
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderWidth: 1,
                                          ),
                                          Positioned(
                                            top: 0,
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.12,
                                            child: CircleAvatar(
                                              backgroundColor: AppColors.red,
                                              radius: MediaQuery.of(context)
                                                      .size
                                                      .width *
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
                                            MediaQuery.of(context).size.width *
                                                0.02,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              trainer.firstName!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Padding(
                                padding: !(index ==
                                        brandTrainersSelected.length - 1)
                                    ? const EdgeInsets.symmetric(
                                        horizontal: 8.0)
                                    : EdgeInsets.only(
                                        right: brandTrainersSelected.length != 1
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
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
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.17,
                                          image: trainer.imageUrl,
                                          color: Theme.of(context).primaryColor,
                                          borderWidth: 1,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.02,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            trainer.firstName!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
      errorNoTrainerSelected
          ? Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01,
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.noTrainerSelectedError,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(color: AppColors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Container(),
      Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.01,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05),
        child: Column(
          children: [],
        ),
      )
    ],
  );
}
