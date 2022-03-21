import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';

class EventListTile extends StatefulWidget {
  Event event;

  EventListTile({Key? key, required this.event}) : super(key: key);

  @override
  _EventListTileState createState() => _EventListTileState();
}

class _EventListTileState extends State<EventListTile> {
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.grey,
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.005, horizontal: MediaQuery.of(context).size.width * 0.05),
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey, width: MediaQuery.of(context).size.width * 0.003)
      ),
      child: Container(
        child: Row(
          children: [
            Card(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.20,
                width: MediaQuery.of(context).size.width * 0.20,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "4",
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            fontWeight:
                            true ? FontWeight.normal : FontWeight.bold),
                      ),
                      Text(
                        'Sessions',
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            fontWeight:
                            true ? FontWeight.normal : FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.01,
                horizontal: MediaQuery.of(context).size.width * 0.07
              ),
              shape: CircleBorder(
                side: BorderSide(
                  width: MediaQuery.of(context).size.width * 0.005,
                  color: Colors.grey
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
