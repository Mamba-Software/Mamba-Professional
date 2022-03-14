import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/ActionDialogs/ConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/TopSnackBar/TopSnackBar.dart';

class PickBono extends StatefulWidget {
  String brandId;
  PickBono({Key? key, required this.brandId}) : super(key: key);

  @override
  _PickBonoState createState() => _PickBonoState();
}

class _PickBonoState extends State<PickBono> {

  // Boolean Loading
  bool isLoading = false;

  // Bonos list
  List<Bono> bonosList = [];

  //Brand Service
  var _brandDataService = new BrandDataService();

  //User Service
  var _userDataService = new UserDataService();

  //Class to use top snack bar
  var _topSnackBar = new TopSnackBar();

  //Utils bonos
  var  _bonosUtils = new BonosUtils();

  //Variable to know is user has solicited a Bono
  String bonoSol = '';

  @override
  void initState() {
    super.initState();
    getUserSolicitedBono();
  }

  Future<void> getUserSolicitedBono() async {
    bonoSol = await _userDataService.getBonoRequest(currentUser.id!, widget.brandId);
  }

  // Gets the bonos from the brand
  Future<void> getBrandBonos() async {
    setState(() {
    });
  }

  Widget returnBono(Bono _bono) {
    if(bonoSol != '') {
      return Card(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.20,
          width: MediaQuery.of(context).size.width * 0.05,
          child: Center(
            child: ListTile(
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                      Text(
                        _bono.title!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(fontWeight: true ? FontWeight.normal : FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _bono.classes!.toString() + ' Classes',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(fontWeight: true ? FontWeight.normal : FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _bono.price!.toString() + ' Euros',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(fontWeight: true ? FontWeight.normal : FontWeight.bold),
                          ),
                        ],
                      ),
                    ]
                ),
                //minVerticalPadding: MediaQuery.of(context).size.width * 0.02,
                onTap: () async {
                  if(bonoSol != _bono.id) {
                    _topSnackBar.topsnackbar(context, 'Ya se ha solicitado un bono', Colors.red);
                  }
                  else {
                    var result = await showDialog(
                        context: context,
                        builder: (_) {
                          return ConfirmationDialog(text:'Quieres cancelar la silicitud del bono?');
                        }
                    );
                    if (result) {
                    //Cancelar solicitud
                  }
                  }
                }
            ),
          ),
        ),
        elevation: 8,
        shadowColor: Colors.green,
        margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
        shape: CircleBorder(side: BorderSide(width: MediaQuery.of(context).size.width * 0.005, color: Colors.green),
        ),
      );
    }
     else return Card(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.20,
        width: MediaQuery.of(context).size.width * 0.05,
        child: Center(
          child: ListTile(
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Text(
                    _bono.title!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(fontWeight: true ? FontWeight.normal : FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                          Text(
                            _bono.classes!.toString() + ' Classes',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(fontWeight: true ? FontWeight.normal : FontWeight.bold),
                          ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _bono.price!.toString() + ' Euros',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(fontWeight: true ? FontWeight.normal : FontWeight.bold),
                      ),
                    ],
                  ),
                ]
              ),
              //minVerticalPadding: MediaQuery.of(context).size.width * 0.02,
              onTap: () async {
                var result = await showDialog(
                    context: context,
                    builder: (_) {
                      return ConfirmationDialog(text:'Quieres solicitar el bono?');
                    }
                );
                if (result) {
                  _brandDataService.addBonoRequestToBrand(
                      widget.brandId, currentUser.id!, _bono.id!, _bono.title!, _bono.price.toString(),
                      _bono.classes.toString());

                  _userDataService.addBonoRequestToUser(
                      widget.brandId, currentUser.id!, _bono.id!);

                  _topSnackBar.topsnackbar(context, 'Se ha solicitado el bono', Colors.green);
                  bonoSol = _bono.id!;
                }
              }
          ),
        ),
      ),
      elevation: 8,
      shadowColor: Colors.green,
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
      shape: CircleBorder(side: BorderSide(width: MediaQuery.of(context).size.width * 0.005, color: Colors.green),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bonos',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: LoadingViewPurple())
          : Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.05),
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
                        bonosList = _bonosUtils.documentsToBonos(snapshot.data!.docs);
                        return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: bonosList.length,
                            itemBuilder: (context, index) {
                              Bono bono = bonosList[index];
                              return returnBono(bono);
                            }
                        );
                      }
                    }
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                /*
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: bonosList.length,
                      itemBuilder: (context, index) {
                        Bono bono = bonosList[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01),
                          child: returnBono(bono),
                        );
                      }),
                ),
                */

              ],
            ),
    );
  }
}
