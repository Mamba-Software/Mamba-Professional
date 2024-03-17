import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/RecurrentEvent/RecurrentEventObjectSelector.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecurrentEventSelector extends StatelessWidget {
  final Locale locale;
  const RecurrentEventSelector({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, bool>(
        selector: (state) {
      return state.newEvent.isRecurrent!;
    }, builder: (context, isRecurrent) {
      return // Recurrent Event
          context.read<CrudEventCubit>().state.isNew
              ? Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.recurrentEvent,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            context
                                    .read<CrudEventCubit>()
                                    .state
                                    .newEvent
                                    .joinedMembersList!
                                    .isEmpty
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.035,
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    child: CupertinoSwitch(
                                      value: isRecurrent,
                                      onChanged: (bool newVal) {
                                        context
                                            .read<CrudEventCubit>()
                                            .editEventInfo(newVal,
                                                EditEventType.recurrent);
                                      },
                                      trackColor: Colors.green.withOpacity(0.4),
                                      thumbColor: AppColors.white,
                                      activeColor: Colors.green,
                                    ),
                                  )
                                : SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.035,
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    child: CupertinoSwitch(
                                      value: false,
                                      onChanged: null,
                                      trackColor: Colors.green.withOpacity(0.4),
                                      thumbColor: AppColors.white,
                                      activeColor: Colors.grey,
                                    ),
                                  )
                          ],
                        )),
                    AnimatedCrossFade(
                      firstChild: Container(), // Widget when expanded
                      // Widget when contracted
                      secondChild: RecurrentEventObjectSelector(locale: locale),
                      crossFadeState: isRecurrent
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(
                          milliseconds: 700), // Duration of the animation
                    ),
                  ],
                )
              : isRecurrent
                  ? Padding(
                      padding: const EdgeInsets.only(
                        top: 15,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.recurrentEvent,
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.035,
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: CupertinoSwitch(
                              value: true,
                              onChanged: null,
                              trackColor: Colors.green.withOpacity(0.4),
                              thumbColor: AppColors.white,
                              activeColor: Colors.grey,
                            ),
                          ),
                        ],
                      ))
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.recurrentEvent,
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.035,
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: CupertinoSwitch(
                              value: false,
                              onChanged: null,
                              trackColor: Colors.green.withOpacity(0.4),
                              thumbColor: AppColors.white,
                              activeColor: Colors.grey,
                            ),
                          ),
                        ],
                      ));
    });
  }
}
