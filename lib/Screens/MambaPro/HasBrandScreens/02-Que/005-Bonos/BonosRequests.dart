import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Payments/PaymentDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Bonos/BonoRequestObject.dart';
import '../../../../../../Data/Models/Bono.dart';
import '../../../../../../Data/Models/Usuario.dart';
import '../../../../../../Globals/Utils/Bonos/BonosUtils.dart';
import '../../../../../../Globals/Widgets/Components/Images/CircularImage.dart';
import '../../../../../Data/Models/Purchase.dart';
import '../../../../../Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/RequestBonoConfirmationDialog.dart';
import '../../../../../../Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';


class BonosRequests extends StatefulWidget {
  String brandId;

  BonosRequests({Key? key, required this.brandId}) : super(key: key);

  @override
  _BonosRequestsState createState() => _BonosRequestsState();
}

class _BonosRequestsState extends State<BonosRequests> {
  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  final _userDataService = UserDataService();
  // Bonos list
  List<BonoRequest> bonosRequestsList = [];
  //Utils bonos
  final _bonosUtils = BonosUtils();

  @override
  initState() {
    super.initState();
  }

  Widget returnBonoRequest(BonoRequest _bonoRequest, var user, var bono) {
    Usuario _user = user;
    Bono _bono = bono;
    return BonoRequestObject(bono: _bono, user: _user, bonoRequest: _bonoRequest, brandId: widget.brandId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _brandDataService.getBonosRequestsFromBrand(widget.brandId),
        builder: (context, snapshot) {
          if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null) {
            return Center(child: LoadingView());
          } else {
            bonosRequestsList = _bonosUtils.documentsToBonosRequests(snapshot.data!.docs);
            return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
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
                      future: _userDataService.getUserDetails(bonoRequest.userId!),
                      // Run check for a single queryRow
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          Object? user = snapshot.data;
                          return FutureBuilder(
                              future: _brandDataService.getBonoInfo(widget.brandId, bonoRequest.bonoId!),
                              // Run check for a single queryRow
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                                    child: returnBonoRequest(
                                        bonoRequest, user, snapshot.data
                                    ),
                                  );
                                } else {
                                  return Center(child: LoadingView());
                                }
                              }
                          );
                        } else {
                          return Center(child: LoadingView());
                        }
                      });
                });
          }
        }
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
