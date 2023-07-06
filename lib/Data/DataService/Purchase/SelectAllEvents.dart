import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/UserEventCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';

class SelectAllEvents extends StatefulWidget {
  List<Event> selectedEvents = [];
  
  SelectAllEvents({Key? key, required this.selectedEvents}) : super(key: key);

  @override
  _SelectAllEventsState createState() => _SelectAllEventsState();
}

class _SelectAllEventsState extends State<SelectAllEvents> {

  // Brand Data Service
  final _brandDataService = BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  // Search Controller
  bool searchClicked = false;
  var searchController = TextEditingController();
  // Members Page
  List<Event> allEvents = [];
  List<Event> filteredEvents = [];
  List<Event> selectedEvents = [];

  Future<void> getAllEvents() async {
    allEvents = await _brandDataService.getAllEventsFromBrandStats(currentBrand.id!);
    // Sort Clients
    allEvents.sort((a, b) {
      if (a.doneAt != null && b.doneAt != null) {
        return b.doneAt!.compareTo(a.doneAt!);
      } else if (a.doneAt != null) {
        return -1; // a is greater (comes first) if it has doneAt value
      } else if (b.doneAt != null) {
        return 1; // b is greater (comes first) if it has doneAt value
      } else {
        return 0; // both events don't have doneAt value, so no change in order
      }
    });
    filteredEvents = allEvents;
    // Selected Clients
    for (var event in widget.selectedEvents) {
      String id = event.id!;
      var index = filteredEvents.indexWhere((element) => element.id! == id);
      selectedEvents.add(filteredEvents[index]);
    }
    // Return Future Delayed
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  Color getColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return Theme.of(context).colorScheme.secondary;
    } else {
      return Colors.transparent;
    }
  }

  void filterSearchResults(String query) {
    List<Event> eventsFiltered = [];
    if (query.isNotEmpty || query != "") {
      for (var item in allEvents) {
        if (item.title!.toLowerCase().startsWith(query)) {
          eventsFiltered.add(item);
        }
      }
      setState(() {
        filteredEvents = eventsFiltered;
      });
    } else {
      setState(() {
        filteredEvents = allEvents;
      });
    }
  }

  @override
  initState() {
    isLoading = true;
    getAllEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body:  isLoading ?
      Center(child: LoadingView())
          :
      DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: searchController,
              onChanged: (value) {
                filterSearchResults(value);
              },
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.caption,
                hintText: AppLocalizations.of(context)!.search,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.0),
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
              onPressed: () {
                Navigator.pop(context, null);
                selectedEvents = [];
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  searchController.clear();
                  filterSearchResults("");
                },
                icon: const Icon(Icons.clear, color: AppColors.grey,),
              ),
            ],
          ),
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: Column(
              children: [
                selectedEvents.length > 0 ? Container(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05,),
                  color: Theme.of(context).backgroundColor,
                  height: MediaQuery.of(context).size.height*0.04,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.80,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedEvents.length,
                            itemBuilder: (context, index) {
                              Event event = selectedEvents[index];
                              return Center(
                                child: Text(
                                  index == 0 && selectedEvents.length == 1 || index == selectedEvents.length-1 ? event.title! : event.title! + ", ",
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              );
                            }
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width*0.09,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "( "+selectedEvents.length.toString()+" )",
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 8),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ) : SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        Event event = filteredEvents[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  var selectedEventsAux = selectedEvents;
                                  if (selectedEventsAux.contains(event)) {
                                    selectedEventsAux.remove(event);
                                    setState(() {
                                      selectedEvents = selectedEventsAux;
                                    });
                                  } else {
                                    selectedEventsAux.add(event);
                                    setState(() {
                                      selectedEvents = selectedEventsAux;
                                    });
                                  }
                                },
                                child: UserEventCard(
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
                              ),
                              Positioned(
                                top: MediaQuery.of(context).size.width*0.03,
                                left: MediaQuery.of(context).size.width*0.07,
                                child: Theme(
                                  data: ThemeData(unselectedWidgetColor: Colors.transparent),
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    tristate: false,
                                    fillColor: MaterialStateProperty.resolveWith(getColor),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    value: selectedEvents.contains(event),
                                    shape: const CircleBorder(
                                        side: BorderSide.none
                                    ),
                                    onChanged: (bool? value) {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                  ),
                ),
              ],
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.05),
            child: Container(
              height: MediaQuery.of(context).size.width*0.17,
              width: MediaQuery.of(context).size.width*0.17,
              child: FloatingActionButton(
                heroTag: "64",
                onPressed: () {
                  Navigator.pop(context, selectedEvents);
                },
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Icon(
                  Icons.add,
                  size: MediaQuery.of(context).size.width*0.07,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
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

  @override
  void dispose() {
    super.dispose();
  }

}