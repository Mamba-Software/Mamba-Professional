import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/SelectAllEvents.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/Purchase/PurchaseEvents/cubit/PurchaseEventsCubit.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/UserEventCard.dart';
import 'package:shimmer/shimmer.dart';


class PurchaseEvents extends StatelessWidget {
  final context;
  final Purchase purchase;
  final void Function(Purchase) executeFunction;

  const PurchaseEvents({Key? key, required this.context, required this.purchase, required this.executeFunction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PurchaseEventsCubit>(
      lazy: false,
      create: (context) => PurchaseEventsCubit(purchase),
      child: PurchaseEventsBody(
        context: context,
        purchase: purchase,
        executeFunction: executeFunction
      ),
    );
  }
}

class PurchaseEventsBody extends StatelessWidget {

  final context;
  final Purchase purchase;
  final void Function(Purchase) executeFunction;

  const PurchaseEventsBody({Key? key, required this.context, required this.purchase, required this.executeFunction}) : super(key: key);

  Purchase getPurchase() {
    /*List<Event> deleteEvents = purchase.initalEvents.where((b) => !purchase.events.any((a) => a.id == b.id)).toList();
    List<Event> newEvents = purchase.events.where((b) => !purchase.initalEvents.any((a) => a.id == b.id)).toList();
    purchase.setInitialEventsData = deleteEvents;
    purchase.setPurchasedEventsData = newEvents;
    print(deleteEvents.length);
    print(newEvents.length);*/
    return purchase;
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<PurchaseEventsCubit, PurchaseEventsState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case PurchaseEventsLoaded:
            PurchaseEventsLoaded loadedState = state as PurchaseEventsLoaded;
            List<Event> events = loadedState.purchase.events;
            return Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                          /*
                          TextButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  true ? AppLocalizations.of(context)!.newerFirst : AppLocalizations.of(context)!.olderFirst,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                Icon(
                                  true ? FontAwesomeIcons.arrowDownWideShort : FontAwesomeIcons.arrowUpShortWide,
                                  color: AppColors.grey,
                                  size: MediaQuery.of(context).size.width*0.05,
                                ),
                              ],
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).backgroundColor,
                              shape: RoundedRectangleBorder(  // add this
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.only(left: 16.0, right: 10.0),
                            ),
                            onPressed: () => null,
                          ),
                           */
                          TextButton(
                            child: events.isNotEmpty ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.edit,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                Icon(
                                  Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                  size: MediaQuery.of(context).size.width*0.05,
                                ),
                              ],
                            ) : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.add,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                Icon(
                                  Icons.add,
                                  color: Theme.of(context).primaryColor,
                                  size: MediaQuery.of(context).size.width*0.05,
                                ),
                              ],
                            ) ,
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).backgroundColor,
                              shape: RoundedRectangleBorder(  // add this
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.only(left: 16.0, right: 10.0),
                            ),
                            onPressed: () async {
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
                                context.read<PurchaseEventsCubit>().updateEvents(purchase);
                                executeFunction(purchase);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                events.isNotEmpty ? Container(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        Event event = events[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: GestureDetector(
                            onTap: () => navigateToEventScreen(event.id!),
                            child: Stack(
                              children: [
                                UserEventCard(
                                  event: event,
                                  height: MediaQuery.of(context).size.height * 0.15,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  isMyEvent: true,
                                  showEmoji: false,
                                ),
                              ]
                            ),
                          ),
                        );
                      }
                  ),
                ) : Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          AppLocalizations.of(context)!.noEvents,
                          style: Theme.of(context).textTheme.bodyText2,
                          textAlign: TextAlign.center
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              ],
            );
          default:
            // Handle All other States aka Loading or Initial
            return Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                      TextButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.edit,
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.grey),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width*0.02),
                            Icon(
                              Icons.edit,
                              color: AppColors.grey,
                              size: MediaQuery.of(context).size.width*0.05,
                            ),
                          ],
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).backgroundColor,
                          shape: RoundedRectangleBorder(  // add this
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.only(left: 16.0, right: 10.0),
                        ),
                        onPressed: null,
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
                      color: Theme.of(context).backgroundColor,
                      //border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Theme.of(context).backgroundColor,
                          highlightColor: Theme.of(context).backgroundColor.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15*0.66,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
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
                            height: MediaQuery.of(context).size.height * 0.15*0.34-1,
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
        )
    );
  }
}
