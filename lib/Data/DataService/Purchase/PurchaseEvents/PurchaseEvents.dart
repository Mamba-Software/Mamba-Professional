import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/SelectAllEvents.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/cubit_purchase_events/PurchaseEventsCubit.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';

import '../../../../Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import '../../../../Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import '../../../../Globals/Widgets/GroupOfComponents/Events/EventPage/UserEventCard.dart';

class PurchaseEvents extends StatelessWidget {
  final Purchase purchase;
  final context;
  final void Function(Purchase) executeFunction;

  Purchase getPurchase() {
    print(purchase.events.length);
    List<Event> deleteEvents = purchase.initalEvents.where((b) => !purchase.events.any((a) => a.id == b.id)).toList();
    List<Event> newEvents = purchase.events.where((b) => !purchase.initalEvents.any((a) => a.id == b.id)).toList();
    purchase.setInitialEventsData = deleteEvents;
    purchase.setPurchasedEventsData = newEvents;
    return purchase;
  }

  const PurchaseEvents({Key? key, required this.purchase, required this.context, required this.executeFunction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocProvider<PurchaseEventsCubit>(
          create: (_) => PurchaseEventsCubit(purchase),
          lazy: false,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.03),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.sessions,
                        style: Theme.of(context).textTheme.headline1?.copyWith(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.newerFirst,
                            style: Theme
                                .of(context)
                                .textTheme
                                .caption,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_downward,
                            size: MediaQuery
                                .of(context)
                                .size
                                .width * 0.04,
                            color: AppColors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.01),
                BlocBuilder<PurchaseEventsCubit, PurchaseEventsState>(
                  builder: (context, state) {
                    List<Event> events = [];
                    if (state is PurchaseEventsLoaded) {
                      events = state.purchase.events;
                    }
                    else if(state is PurchaseEventsInitial) {
                      context.read<
                          PurchaseEventsCubit>()
                          .loadList(purchase);
                    }
                    return Column(
                      children: [
                        state is PurchaseEventsLoaded? state.purchase.events.isNotEmpty ? Container(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery
                              .of(context)
                              .size
                              .width * 0.05),
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                Event event = events[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      navigateToEventScreen(event.id!);
                                    },
                                    child: Stack(
                                        children: [
                                          UserEventCard(
                                            event: event,
                                            height: MediaQuery
                                                .of(context)
                                                .size
                                                .height * 0.15,
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width * 0.9,
                                            isMyEvent: true,
                                            showEmoji: false,
                                          ),
                                          /*
                                          Positioned(
                                            top: 0,
                                            right: 4,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 7.0),
                                              child: Container(
                                                width:
                                                MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width *
                                                    0.07,
                                                decoration: const BoxDecoration(
                                                    color: AppColors.red,
                                                    shape: BoxShape.circle),
                                                child: Center(
                                                  child: IconButton(
                                                    onPressed: () async {
                                                      var result = await showDialog(
                                                          context: context,
                                                          builder: (_) {
                                                            return DeleteConfirmationDialog(
                                                                text: AppLocalizations
                                                                    .of(context)!
                                                                    .cancelEventPurchase);
                                                          }
                                                      );

                                                      if (result) {
                                                        await _purchaseDataService
                                                            .deleteEventFromPurchase(
                                                            purchase.id!, event.id!);
                                                        //_purchaseDataService.updateUserPurchaseSessions(purchase.userId!, purchase.brandId!, purchase.id!, purchase.sessions! - 1, purchase.bonoId!)
                                                        context.read<
                                                            PurchaseEventsCubit>()
                                                            .loadList(purchase);
                                                      }
                                                    },
                                                    icon: Icon(Icons.remove,
                                                        color: AppColors.white,
                                                        size: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width *
                                                            0.03),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                           */
                                        ]
                                    ),
                                  ),
                                );
                              }
                          ),
                        ) : Padding(
                          padding: EdgeInsets.symmetric(vertical: MediaQuery
                              .of(context)
                              .size
                              .width * 0.02, horizontal: MediaQuery
                              .of(context)
                              .size
                              .width * 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                  AppLocalizations.of(context)!.noData,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyText2,
                                  textAlign: TextAlign.center
                              ),
                            ],
                          ),
                        ) : Padding(
                          padding: EdgeInsets.symmetric(vertical: MediaQuery
                              .of(context)
                              .size
                              .width * 0.30),
                          child: LoadingView(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            hasLogo: false,
                            isSmall: true,
                          ),
                        ),
                        SizedBox(height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.02),
                        GestureDetector(
                          onTap: () async {
                            if(state is PurchaseEventsLoaded) {
                              List<Event>? selectedEvents = await Navigator.push(
                                  context,
                                  CupertinoPageRoute<List<Event>>(
                                    builder: (context) =>
                                        SelectAllEvents(
                                          selectedEvents: purchase.events,
                                        ),
                                  )
                              );
                              if (selectedEvents != null) {
                                purchase.setPurchasedEventsData = selectedEvents;
                                print(purchase.events.length);
                                context.read<
                                    PurchaseEventsCubit>()
                                    .updateEvents(purchase);
                                executeFunction(purchase);
                              }
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery
                                .of(context)
                                .size
                                .width * 0.05),
                            child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(10),
                                dashPattern: const [10, 10],
                                color: AppColors.grey.withOpacity(0.5),
                                strokeWidth: 2,
                                child: Container(
                                    height: MediaQuery.of(context).size.height*0.13,
                                    width: MediaQuery.of(context).size.height*0.9,
                                    color: Colors.transparent,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                    Icons.add,
                                                    color: AppColors.grey.withOpacity(0.5),
                                                    size: MediaQuery.of(context).size.width*0.1
                                                ),
                                                //SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                Text(
                                                  AppLocalizations.of(context)!.addEventsToPurchaseText,
                                                  style: Theme.of(context).textTheme.caption,
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              AppLocalizations.of(context)!.addEventsToPurchaseSubText,
                                              style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10),
                                              textAlign: TextAlign.left,
                                            ),
                                            SizedBox(height: MediaQuery
                                                .of(context)
                                                .size
                                                .height * 0.01),
                                          ],
                                        ),
                                      ],
                                    )
                                )
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          )
        ),

      ],
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
        )
    );
  }
}
