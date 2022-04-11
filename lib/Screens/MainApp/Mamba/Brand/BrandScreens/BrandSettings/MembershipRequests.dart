import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/RequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:share_plus/share_plus.dart';
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

  var _dynamicLinkUtils = new DynamicLinkUtils();
  String? brandId = '';

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
            title: Text(AppLocalizations.of(context)!.myRequests, style: Theme.of(context).appBarTheme.titleTextStyle,),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: LoadingViewPurple(),
        )
            :
        Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.myRequests, style: Theme.of(context).appBarTheme.titleTextStyle,),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.02),
                  child: ListTile(
                    onTap: () async {
                      final Uri uri = await _dynamicLinkUtils.createDynamicLinkWithId(currentBrand.id!, currentBrand.logoUrl!, currentBrand.name!);
                      await Share.share(uri.toString(), subject: currentBrand.logoUrl!);
                    },
                    leading: Icon(
                      Icons.share,
                      color: Theme.of(context).accentColor,
                      size: MediaQuery.of(context).size.width*0.06,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.copyCodeMessage,
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).accentColor),
                    ),
                    trailing: Icon(Icons.send_outlined, color: Theme.of(context).accentColor, size: MediaQuery.of(context).size.width*0.06,),
                  ),
              ),
              Container(
                height: 1,
                color: Theme.of(context).accentColor,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              StreamBuilder<QuerySnapshot>(
                  stream: _brandDataService.getBrandRequestsStream(widget.brandId),
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
                                        style: Theme.of(context).textTheme.bodyText2,
                                        children: [
                                          TextSpan(text: request.name!, style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold),),
                                          TextSpan(text: AppLocalizations.of(context)!.requestFromUser(type), style: Theme.of(context).textTheme.bodyText2),
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
                                        style: Theme.of(context).textTheme.caption
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
                              Text(AppLocalizations.of(context)!.noRequestsFound, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
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