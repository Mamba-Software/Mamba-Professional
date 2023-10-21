import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/DividerAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final ValueNotifier<bool> isExpanded = ValueNotifier<bool>(false);

Widget eventBonosWidget(BuildContext context, Map<Bono, bool> eventBonosMap) {
  return eventBonosMap.isNotEmpty
      ? ValueListenableBuilder<bool>(
          valueListenable: isExpanded,
          builder: (context, isExpandedValue, child) {
            return Column(
              children: [
                AnimatedCrossFade(
                  firstChild: bonoFieldDescription(context, eventBonosMap,
                      false, isExpandedValue), // Widget when expanded
                  // Widget when contracted
                  secondChild: bonoFieldDescription(
                      context, eventBonosMap, true, isExpandedValue),
                  crossFadeState: isExpandedValue
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(
                      milliseconds: 700), // Duration of the animation
                ),
                dividerAddEditEvent(
                    context, AppLocalizations.of(context)!.bonos),
              ],
            );
          })
      : Container();
}

Widget bonoFieldDescription(BuildContext context, Map<Bono, bool> eventBonosMap,
    bool hasBonos, bool _isExpandedValue) {
  return Column(
    children: [
      GestureDetector(
        onTap: () {
          isExpanded.value = !isExpanded.value;
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01,
                      bottom: MediaQuery.of(context).size.height * 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.bonosDescription,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                      _isExpandedValue
                          ? Icon(Icons.keyboard_arrow_up)
                          : Icon(Icons.keyboard_arrow_down)
                    ],
                  )),
              eventBonosMap.values.every((value) => value == false)
                  ? Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.025,
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        border: Border.all(color: AppColors.red, width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outlined,
                            color: AppColors.red,
                            size: MediaQuery.of(context).size.width * 0.08,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .bonosDescriptionWarning,
                              textAlign: TextAlign.left,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(color: AppColors.red, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.025,
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outlined,
                            color: Colors.green,
                            size: MediaQuery.of(context).size.width * 0.08,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .bonosDescriptionGreat,
                              textAlign: TextAlign.left,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(color: Colors.green, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
      hasBonos
          ? eventBonosMap.isNotEmpty
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: Text(
                            AppLocalizations.of(context)!.selectAll,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          style: TextButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                          ),
                          onPressed: () async {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus &&
                                currentFocus.focusedChild != null) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            }
                            context
                                .read<CrudEventCubit>()
                                .editEventInfo('AllBonos', EditEventType.bonos);
                          },
                        ),
                      ],
                    ),
                    true
                        ? Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.01,
                                right:
                                    MediaQuery.of(context).size.width * 0.01),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .deleteClientsWithPurchasesBonos,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.copyWith(color: AppColors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Container(),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: eventBonosMap.keys.toList().length,
                        itemBuilder: (context, int index) {
                          var bono = eventBonosMap.keys.toList()[index];
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.075,
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      BonoCard(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.05,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.18,
                                        bono: bono,
                                        brand: currentBrand,
                                        canExpand: false,
                                        onlyView: true,
                                        hideActive: true,
                                      ),
                                    ]),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        bono.title!.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Flexible(
                                        child: Text(
                                          (bono.sessions! == 10000
                                                  ? AppLocalizations.of(
                                                              context)!
                                                          .sessions +
                                                      " " +
                                                      AppLocalizations.of(
                                                              context)!
                                                          .ilimitadas
                                                  : bono.sessions!.toString() +
                                                      " " +
                                                      AppLocalizations.of(
                                                              context)!
                                                          .sessions
                                                          .toLowerCase()) +
                                              " desde " +
                                              bono.price!.toStringAsFixed(2) +
                                              "€",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.034,
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  child: MaterialButton(
                                    elevation: 4,
                                    color: eventBonosMap[bono] == true
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).backgroundColor,
                                    textColor: eventBonosMap[bono] == true
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).backgroundColor,
                                    child: eventBonosMap[bono] == true
                                        ? Icon(Icons.check,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05)
                                        : SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                          ),
                                    padding: EdgeInsets.zero,
                                    shape: const CircleBorder(),
                                    onPressed: () {
                                      FocusScopeNode currentFocus =
                                          FocusScope.of(context);
                                      if (!currentFocus.hasPrimaryFocus &&
                                          currentFocus.focusedChild != null) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      }
                                      //TODO: Control de bonos de clients si tenen purchases si es treu avisar que el client s'unirà al event sense aquest purchaseId
                                      context
                                          .read<CrudEventCubit>()
                                          .editEventInfo(
                                              '', EditEventType.bonos, bono);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ],
                )
              : Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.03,
                      left: MediaQuery.of(context).size.width * 0.01,
                      right: MediaQuery.of(context).size.width * 0.01),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.noActiveBonos,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          ?.copyWith(color: AppColors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
          : Container(),
    ],
  );
}
