import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Payments/PaymentDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoRequestObject.dart';
import 'package:shimmer/shimmer.dart';
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
    return BonoRequestObject(
      bono: _bono,
      user: _user,
      brand: currentBrand,
      bonoRequest: _bonoRequest,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Compras de "+AppLocalizations.of(context)!.bonos,
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
                scrollDirection: Axis.vertical,
                itemCount: bonosRequestsList.length,
                itemExtent: MediaQuery.of(context).size.height*0.11,
                itemBuilder: (context, index) {
                  BonoRequest bonoRequest = bonosRequestsList[index];
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
                                  return returnBonoRequest(
                                      bonoRequest,
                                      user,
                                      snapshot.data
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: ListTile(
                                      dense: true,
                                      leading: Shimmer.fromColors(
                                        baseColor: AppColors.grey,
                                        highlightColor: AppColors.grey.withOpacity(0.5),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height*0.08,
                                          width: MediaQuery.of(context).size.height*0.08,
                                          decoration: const BoxDecoration(
                                            color: AppColors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      title: Shimmer.fromColors(
                                        baseColor: AppColors.grey,
                                        highlightColor: AppColors.grey.withOpacity(0.5),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height*0.03,
                                          width: MediaQuery.of(context).size.width*0.02,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                          Shimmer.fromColors(
                                            baseColor: AppColors.grey,
                                            highlightColor: AppColors.grey.withOpacity(0.5),
                                            child: Container(
                                              height: MediaQuery.of(context).size.height*0.02,
                                              width: MediaQuery.of(context).size.width*0.2,
                                              decoration: const BoxDecoration(
                                                color: AppColors.grey,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Shimmer.fromColors(
                                        baseColor: AppColors.grey,
                                        highlightColor: AppColors.grey.withOpacity(0.5),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height*0.04,
                                          width: MediaQuery.of(context).size.height*0.04,
                                          decoration: const BoxDecoration(
                                            color: AppColors.grey,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: null,
                                    ),
                                  );
                                }
                              }
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              dense: true,
                              leading: Shimmer.fromColors(
                                baseColor: AppColors.grey,
                                highlightColor: AppColors.grey.withOpacity(0.5),
                                child: Container(
                                  height: MediaQuery.of(context).size.height*0.08,
                                  width: MediaQuery.of(context).size.height*0.08,
                                  decoration: const BoxDecoration(
                                    color: AppColors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              title: Shimmer.fromColors(
                                baseColor: AppColors.grey,
                                highlightColor: AppColors.grey.withOpacity(0.5),
                                child: Container(
                                  height: MediaQuery.of(context).size.height*0.03,
                                  width: MediaQuery.of(context).size.width*0.02,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                  Shimmer.fromColors(
                                    baseColor: AppColors.grey,
                                    highlightColor: AppColors.grey.withOpacity(0.5),
                                    child: Container(
                                      height: MediaQuery.of(context).size.height*0.02,
                                      width: MediaQuery.of(context).size.width*0.2,
                                      decoration: const BoxDecoration(
                                        color: AppColors.grey,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Shimmer.fromColors(
                                baseColor: AppColors.grey,
                                highlightColor: AppColors.grey.withOpacity(0.5),
                                child: Container(
                                  height: MediaQuery.of(context).size.height*0.04,
                                  width: MediaQuery.of(context).size.height*0.04,
                                  decoration: const BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                ),
                              ),
                              onTap: null,
                            ),
                          );
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
