import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:share_plus/share_plus.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../../../../../../Data/Models/Bono.dart';
import '../../../../../../../Data/Models/Usuario.dart';
import '../../../../../../../Globals/Styles/Styles.dart';
import '../../../../../../../Globals/Utils/Bonos/BonosUtils.dart';
import '../../../../../../../Globals/Widgets/Components/Images/CircularImage.dart';
import '../../../../../../../Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/RequestConfirmationDialog.dart';
import '../../../../../../../Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';


class BonosRequests extends StatefulWidget {
  String brandId;

  BonosRequests({Key? key, required this.brandId}) : super(key: key);

  @override
  _BonosRequestsState createState() => _BonosRequestsState();
}

class _BonosRequestsState extends State<BonosRequests> {
  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  var _userDataService = new UserDataService();

  // Bonos list
  List<BonoRequest> bonosRequestsList = [];

  //Utils bonos
  var _bonosUtils = new BonosUtils();

  bool isLoading = false;

  @override
  initState() {
    super.initState();
  }

  Widget returnBonoRequest(BonoRequest _bonoRequest, var user) {
    Usuario _user = user;
    return ListTile(
      leading: CircularImage(
        size: MediaQuery.of(context).size.width*0.15,
        image: _user.imageUrl!,
        color: Theme.of(context).primaryColor,
        borderWidth: 1,
      ),
      title: Text(
        _user.name! + ' ha solicitado ' + _bonoRequest.title!.toUpperCase(),
        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.01),
          Text(
            _bonoRequest.classes! + ' sesiones por ' + _bonoRequest.price! + ' euros',
            style: Theme.of(context).textTheme.caption,
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.01),
          Text(
            _bonoRequest.timeRequested!.toDate().toString(),
            style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 13),
          ),
        ],
      ),
      onTap: () async {
        var result = await showDialog(
            context: context,
            builder: (_) {
              return RequestConfirmationDialog(
                text: 'Si aceptas se le otorgaran ' + _bonoRequest.classes! + ' sesiones',
                userId: _user.id!,
              );
            }
        );
        if (result) {
          await _brandDataService.addUserToBrand( _bonoRequest.userId!, widget.brandId, 0);
          _userDataService.addBonoToUser(widget.brandId, _bonoRequest.userId!, _bonoRequest.bonoId!, int.parse(_bonoRequest.classes!), Timestamp.now());
          _userDataService.deleteUserBonoRequest(_bonoRequest.userId!, widget.brandId, _bonoRequest.bonoId!);
          _brandDataService.deleteBrandBonoRequest( widget.brandId, _bonoRequest.bonoId!);
          _brandDataService.updateBonoCompras(widget.brandId, _bonoRequest.bonoId!);
        }
      }
    );
    return ListTile(
      leading: Icon(
        Icons.record_voice_over,
        color: Theme.of(context).primaryColor,
        size: 25,
      ),
      title: Container(
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyText2,
            children: [
              TextSpan(
                text: _bonoRequest.userId!,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                  text: _bonoRequest.title,
                  style: Theme.of(context).textTheme.bodyText2),
            ],
          ),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Text(_bonoRequest.title!,
              //AppLocalizations.of(context)!.requestSent(request.dateSent!),
              style: Theme.of(context).textTheme.caption),
        ],
      ),
      trailing: Icon(
        Icons.help_outline,
        color: Theme.of(context).primaryColor,
        size: 30,
      ),
      onTap: () async {
        /*
        var result = await showDialog(
            context: context,
            builder: (_) {
              return RequestConfirmationDialog(
                text: AppLocalizations.of(context)!.requestConfirmation,
                userId: user.id!,
              );
            }
        );
        if (result) {
          NotificationService().userJoinsBrand(request.userId!, request.brandId!);
          _brandDataService.acceptRequestFromUser(request);
        } else if (!result) {
          _userDataService.deleteRequestToBrand(request);
        }
        */
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: isLoading
          ? Scaffold(
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.myRequests,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: LoadingViewPurple(),
            )
          : Scaffold(
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.myRequests,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  StreamBuilder<QuerySnapshot>(
                      stream: _brandDataService
                          .getBonosRequestsFromBrand(widget.brandId),
                      builder: (context, snapshot) {
                        if (snapshot == null ||
                            snapshot.data == null ||
                            snapshot.data!.docs == null) {
                          return Container(
                              height: MediaQuery.of(context).size.height * 0.65,
                              child: Center(child: LoadingViewPurple()));
                        } else {
                          bonosRequestsList = _bonosUtils
                              .documentsToBonosRequests(snapshot.data!.docs);
                          return Expanded(
                            child: ListView.builder(
                                physics: AlwaysScrollableScrollPhysics(),
                                shrinkWrap: true,
                                //controller: scrollController,
                                scrollDirection: Axis.vertical,
                                itemCount: bonosRequestsList.length,
                                itemExtent:
                                    MediaQuery.of(context).size.height * 0.20,
                                itemBuilder: (context, index) {
                                  BonoRequest bonoRequest =
                                      bonosRequestsList[index];
                                  return FutureBuilder(
                                      future: _userDataService
                                          .getUserDetails(bonoRequest.userId!),
                                      // Run check for a single queryRow
                                      builder: (context, snapshot) {
                                        if (snapshot.data != null) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01),
                                            child: returnBonoRequest(
                                                bonoRequest, snapshot.data),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      });
                                }),
                          );
                        }
                      }),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                ],
              ),

              /*
          StreamBuilder<QuerySnapshot>(
                  stream: _brandDataService.getAllBonosFromBrand(widget.brandId),
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

           */
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
