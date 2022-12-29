import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef DateCallBack = void Function(int pageIndex, DateTime? dateTime, CalendarView calendarView);

class BrandBonoRequestsWidget extends StatefulWidget {
  String brandId;
  double height = 0;
  double width = 0;
  ValueChanged<bool?> onClicked;

  BrandBonoRequestsWidget({Key? key, required this.height, required this.width, required this.brandId, required this.onClicked}) : super(key: key);

  @override
  _BrandBonoRequestsWidgetState createState() => _BrandBonoRequestsWidgetState();
}

class _BrandBonoRequestsWidgetState extends State<BrandBonoRequestsWidget> {

  // Brand Service
  final _brandDataService = BrandDataService();
  // Number Request
  int requests = 0;
  final _bonosUtils = BonosUtils();

  @override
  void initState() {
    super.initState();
  }

  List<RequestToBrand> documentsToRequests(List<DocumentSnapshot> documents) {
    List<RequestToBrand> requests = [];
    for(int i = 0; i < documents.length; i++) {
      RequestToBrand request = RequestToBrand.fromObjectAllData(documents[i].id, documents[i]);
      requests.add(request);
    }
    return requests;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _brandDataService.getBonosRequestsFromBrand(widget.brandId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          requests = _bonosUtils.documentsToBonosRequests(snapshot.data!.docs).length;
          if (requests != 0) {
            return Column(
              children: [
                Material(
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Container(
                    height: widget.height,
                    width: widget.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                    ),
                    child: Container(
                      margin: const EdgeInsetsDirectional.only(start: 1, end: 1, bottom: 1, top: 1),
                      height: widget.height,
                      width: widget.width,
                      padding: EdgeInsets.all(widget.width*0.05),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                      ),
                      child: SizedBox(
                        height: widget.height,
                        width: widget.width,
                        child: GestureDetector(
                          onTap: () {
                            widget.onClicked(true);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: widget.width*0.15,
                                child: Icon(
                                  Icons.confirmation_number_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: MediaQuery.of(context).size.width*0.10,
                                ),
                              ),
                              SizedBox(
                                width: widget.width*0.55,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        AppLocalizations.of(context)!.bonoRequestDescription,
                                        style: Theme.of(context).textTheme.bodyText2,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: widget.width*0.15,
                                child: Center(
                                  child: Container(
                                    height: MediaQuery.of(context).size.width * 0.08,
                                    width: MediaQuery.of(context).size.width * 0.08,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.all(Radius.circular(15))
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          requests.toString(),
                                          style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark,),
                                          textAlign: TextAlign.center
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
              ],
            );
          } else {
            return Container();
          }
        }
      }
    );
  }
}

