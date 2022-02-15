import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/BrandDataService.dart';

import 'package:mamba_castelldefels/Data/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/RequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class MembershipRequests extends StatefulWidget {
  String brandId;
  MembershipRequests({Key? key, required this.brandId}) : super(key: key);

  @override
  _MembershipRequestsState createState() => _MembershipRequestsState();
}

class _MembershipRequestsState extends State<MembershipRequests> {

  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  var _userDataService = new UserDataService();
  // Boolean Loading
  bool isLoading = false;
  // Request List
  List<RequestToBrand> requestList = [];

  @override
  initState() {
    super.initState();
  }

  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';

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
    return Scaffold(
      appBar: null,
      body:  isLoading ?
        Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.myRequests, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Styles.accent, //change your color here
            ),
          ),
          body: LoadingViewPurple(),
        )
            :
        Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.myRequests, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.02),
                  child: ListTile(
                    onTap: () async {
                      Clipboard.setData(new ClipboardData(text: widget.brandId)).then((_){
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            icon: Container(),
                            iconRotationAngle: 0,
                            backgroundColor: Theme.of(context).accentColor,
                            message: AppLocalizations.of(context)!.copyCorrectCode,
                            textStyle: Styles.whiteTextStyle,
                          ),
                        );
                      });
                    },
                    leading: Icon(
                      Icons.qr_code_outlined,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.copyCodeMessage,
                      style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).accentColor),
                    ),
                    trailing: Icon(Icons.send_outlined, color: Theme.of(context).accentColor, size: 25,),
                  ),
              ),
              Container(
                height: 1,
                color: Theme.of(context).accentColor,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              StreamBuilder<QuerySnapshot>(
                  stream: _brandDataService.getBrandRequests(widget.brandId),
                  builder: (context, snapshot) {
                    if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
                      return Container(
                          height: MediaQuery.of(context).size.height*0.65,
                          child: Center(
                              child: LoadingViewPurple()
                          )
                      );
                    } else {
                      requestList = documentsToRequests(snapshot.data!.docs);
                      if (requestList.length != 0) {
                        return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: requestList.length,
                            itemBuilder: (context, index) {
                              RequestToBrand request = requestList[index];
                              String type;
                              if (request.isTrainer!) {
                                type = AppLocalizations.of(context)!.trainer.toLowerCase();
                              } else {
                                type = AppLocalizations.of(context)!.client.toLowerCase();
                              }
                              //if () {
                                return ListTile(
                                  leading: Icon(request.isTrainer! ? Icons.record_voice_over : Icons.directions_run, color: Theme.of(context).primaryColor, size: 25,),
                                  title: Container(
                                    child: RichText(
                                      text: TextSpan(
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16),
                                        children: [
                                          TextSpan(text: request.name!, style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),),
                                          TextSpan(text: AppLocalizations.of(context)!.requestFromUser(type)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                      Text(
                                        AppLocalizations.of(context)!.requestSent(request.dateSent!),
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: 30,),
                                  onTap: () async {
                                    var result = await showDialog(
                                        context: context,
                                        builder: (_) {
                                          return RequestConfirmationDialog(
                                            text: AppLocalizations.of(context)!.requestConfirmation,
                                            userId: request.userId!,
                                          );
                                        }
                                    );
                                    if (result) {
                                      NotificationService().userJoinsBrand(request.userId!, request.brandId!);
                                      _brandDataService.acceptRequestFromUser(request);
                                    } else if (!result) {
                                      _userDataService.deleteRequestToBrand(request);
                                    }
                                  },
                                );
                              //}

                            }
                        );
                      } else {
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                  width: MediaQuery.of(context).size.width*0.30,
                                  child: Image.asset(Constants.emptyCalendar)
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.005),
                              Text(AppLocalizations.of(context)!.noRequestsFound, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center,),
                              SizedBox(height: MediaQuery.of(context).size.height*0.12),
                            ],
                          ),
                        );
                      }
                    }
                  }
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
            ],
          ),
        ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}