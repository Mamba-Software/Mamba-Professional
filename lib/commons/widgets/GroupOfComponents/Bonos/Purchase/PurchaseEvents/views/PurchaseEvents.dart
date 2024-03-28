import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/events/crud_events/read_event/views/mobile/ReadEventPage.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/BonoEvents/cubit/BonoEventsCubit.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/BonoEvents/views/SelectAllEvents.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/data/Models/Purchase.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/Purchase/PurchaseEvents/cubit/PurchaseEventsCubit.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Events/EventPage/UserEventCard.dart';
import 'package:shimmer/shimmer.dart';

class PurchaseEvents extends StatelessWidget {
  final context;
  final Purchase purchase;
  final void Function(Purchase) executeFunction;

  const PurchaseEvents(
      {super.key,
      required this.context,
      required this.purchase,
      required this.executeFunction});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PurchaseEventsCubit>(
      lazy: false,
      create: (context) => PurchaseEventsCubit(purchase),
      child: PurchaseEventsBody(
        context: context,
        executeFunction: executeFunction,
        purchase: purchase,
      ),
    );
  }
}

class PurchaseEventsBody extends StatelessWidget {
  final Purchase purchase;
  final context;
  final void Function(Purchase) executeFunction;

  const PurchaseEventsBody(
      {super.key,
      required this.context,
      required this.executeFunction,
      required this.purchase});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseEventsCubit, PurchaseEventsState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case PurchaseEventsLoaded:
            PurchaseEventsLoaded loadedState = state as PurchaseEventsLoaded;
            List<Event> events = loadedState.purchase.events;
            events.sort((a, b) => a.doneAt!.compareTo(b.doneAt!));
            return BlocProvider<BonoEventsCubit>(
              lazy: false,
              create: (context) =>
                  BonoEventsCubit(purchase, currentBrand.id!, events, [], true),
              child: BlocBuilder<BonoEventsCubit, BonoEventsState>(
                  builder: (context, state) {
                return Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.sessions,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(fontSize: 22),
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
                                  shape: RoundedRectangleBorder(
                                    // add this
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 10.0),
                                ),
                                onPressed: () async {
                                  if (state is BonoEventsLoaded) {
                                    List<Event>? selectedEvents =
                                        await Navigator.push(
                                            context,
                                            CupertinoPageRoute<List<Event>>(
                                              builder: (context) =>
                                                  SelectAllEvents(
                                                parentContext: context,
                                                purchase: purchase,
                                                brandId: currentBrand.id!,
                                                selectedEvents: events,
                                                allEvents: state.allEvents,
                                              ),
                                            ));
                                    if (selectedEvents != null) {
                                      loadedState
                                              .purchase.setPurchasedEventsData =
                                          selectedEvents;
                                      context
                                          .read<PurchaseEventsCubit>()
                                          .updateEvents(loadedState.purchase);
                                      executeFunction(loadedState.purchase);
                                    }
                                  }
                                },
                                child: events.isNotEmpty
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          state is BonoEventsLoaded
                                              ? Text(
                                                  context.l10n.edit,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                )
                                              : Text(
                                                  context.l10n.chargingEvents,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          state is BonoEventsLoaded
                                              ? Icon(
                                                  Icons.edit,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.05,
                                                )
                                              : Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.04,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.04,
                                                  margin: EdgeInsets.only(
                                                      right:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.02),
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    strokeWidth: 1.5,
                                                  ),
                                                )
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          state is BonoEventsLoaded
                                              ? Text(
                                                  context.l10n.add,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                )
                                              : Text(
                                                  context.l10n.chargingEvents,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          state is BonoEventsLoaded
                                              ? Icon(
                                                  Icons.add,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.05,
                                                )
                                              : Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.04,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.04,
                                                  margin: EdgeInsets.only(
                                                      right:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.02),
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    strokeWidth: 1.5,
                                                  ),
                                                )
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
                    events.isNotEmpty
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05),
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  Event event = events[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: GestureDetector(
                                      onTap: () =>
                                          navigateToEventScreen(event.id!),
                                      child: Stack(children: [
                                        UserEventCard(
                                          event: event,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.15,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          isMyEvent: true,
                                          showEmoji: false,
                                        ),
                                        Positioned(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01,
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7.0),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Theme.of(context)
                                                          .scaffoldBackgroundColor, //New
                                                      blurRadius: 1.0,
                                                      offset:
                                                          const Offset(0, 0))
                                                ],
                                              ),
                                              child: Center(
                                                child: IconButton(
                                                  onPressed: () async {
                                                    events.removeWhere(
                                                        (element) =>
                                                            element.id ==
                                                            event.id);
                                                    loadedState.purchase
                                                            .setPurchasedEventsData =
                                                        events;
                                                    context
                                                        .read<
                                                            PurchaseEventsCubit>()
                                                        .updateEvents(
                                                            loadedState
                                                                .purchase);
                                                    executeFunction(
                                                        loadedState.purchase);
                                                  },
                                                  icon: Icon(
                                                      Icons.delete_outline,
                                                      color: AppColors.red,
                                                      size:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.06),
                                                  alignment: Alignment.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  );
                                }),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              /*
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Image.asset(Assets.emptyCalendar)),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                          */
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.05),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        context.l10n.noEvents,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ],
                );
              }),
            );
          default:
            // Handle All other States aka Loading or Initial
            return Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.sessions,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.background,
                          shape: RoundedRectangleBorder(
                            // add this
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding:
                              const EdgeInsets.only(left: 16.0, right: 10.0),
                        ),
                        onPressed: null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.edit,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppColors.grey),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.04,
                              height: MediaQuery.of(context).size.width * 0.04,
                              margin: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).size.width * 0.02),
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                                strokeWidth: 1.5,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                Material(
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      //border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Theme.of(context).colorScheme.background,
                          highlightColor: Theme.of(context)
                              .colorScheme
                              .background
                              .withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height *
                                0.15 *
                                0.66,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              //border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(15),
                                topLeft: Radius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height *
                                    0.15 *
                                    0.34 -
                                1,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              //border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              ],
            );
        }
      },
    );
  }

  // Navigate to Event Screen on Tap
  Future<void> navigateToEventScreen(String eventId) async {
    await Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => EventPage(
            eventId: eventId,
          ),
        ));
  }
}
