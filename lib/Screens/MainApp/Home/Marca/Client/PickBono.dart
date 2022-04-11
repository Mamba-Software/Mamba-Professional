import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/TopSnackBar/TopSnackBar.dart';

import '../../../../../Globals/Styles/Styles.dart';
import '../../../../../Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/ConfirmationDialog.dart';
import '../../../../../Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';

class PickBono extends StatefulWidget {
  String brandId;

  PickBono({Key? key, required this.brandId}) : super(key: key);

  @override
  _PickBonoState createState() => _PickBonoState();
}

class _PickBonoState extends State<PickBono> {
  // Boolean Loading
  bool isLoading = true;

  // Bonos list
  List<Bono> bonosList = [];

  //Brand Service
  var _brandDataService = new BrandDataService();

  //User Service
  var _userDataService = new UserDataService();

  //Class to use top snack bar
  var _topSnackBar = new TopSnackBar();

  //Utils bonos
  var _bonosUtils = new BonosUtils();

  //Variable to know is user has solicited a Bono
  String bonoSol = '';

  //Variable to know is user has a Bono
  String bonoUser = '';

  @override
  void initState() {
    super.initState();
    getUserSolicitedBono();
  }

  Future<void> getUserSolicitedBono() async {
    bonoSol = await _userDataService.getBonoRequest(currentUser.id!, widget.brandId);
    bonoUser = await _userDataService.getBonoUser(currentUser.id!, widget.brandId);
    setState(() {
      isLoading = false;
    });
  }

  Widget returnBono(Bono _bono) {
    return Card(
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
                      _bono.classes!.toString(),
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
                horizontal: MediaQuery.of(context).size.width * 0.07),
            shape: CircleBorder(
              side: BorderSide(
                  width: MediaQuery.of(context).size.width * 0.005,
                  color: bonoSol != ''
                      ? bonoSol == _bono.id!
                          ? Styles.mainColor
                          : Colors.grey
                      : bonoUser == '' ? Styles.mainColor : Colors.grey),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.040),
                  Expanded(
                    flex: 5,
                    child: ListTile(
                      title: Text(
                        _bono.title!,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            fontWeight:
                                true ? FontWeight.normal : FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_bono.description.toString()),
                          Text(_bono.compras!.toString() + " persones l'han comprat"),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _bono.price!.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.copyWith(
                                  fontWeight:
                                      true ? FontWeight.w500 : FontWeight.bold),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01),
                        Icon(Icons.euro,
                            color: Theme.of(context).primaryColor,
                            size: MediaQuery.of(context).size.width * 0.04),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        bonoUser != '' ?  Text(
                              'Ya',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(
                                  fontWeight: true
                                      ? FontWeight.w500
                                      : FontWeight.bold))
                         :
                        bonoSol != ''
                            ? bonoSol == _bono.id! ? TextButton(
                          child: Text(
                              'CANCELAR',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(
                                  fontWeight: true
                                      ? FontWeight.w500
                                      : FontWeight.bold)),
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                        color: bonoSol != ''
                                            ? bonoSol == _bono.id!
                                            ? Styles.mainColor
                                            : Colors.grey
                                            : bonoUser == '' ? Styles.mainColor : Colors.grey,
                                      )))),
                          onPressed: () async {
                                var result = await showDialog(
                                    context: context,
                                    builder: (_) {
                                      return ConfirmationDialog(
                                          text:
                                          'Quieres cancelar la silicitud del bono?');
                                    });
                                if (result) {
                                  await _brandDataService.deleteBrandBonoRequest(widget.brandId, bonoSol);
                                  await _userDataService.deleteUserBonoRequest(currentUser.id!, widget.brandId, bonoSol);
                                  _topSnackBar.topsnackbar(context,
                                      'Se ha cancelado la solicitud del bono', Colors.green);
                                  setState(() {
                                    bonoSol = '';
                                  });
                                }
                          },
                        )
                        : Container() : TextButton(
                          child: Text(
                              'SOLICITAR',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(
                                  fontWeight: true
                                      ? FontWeight.w500
                                      : FontWeight.bold)),
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                        color: bonoSol != ''
                                            ? bonoSol == _bono.id!
                                            ? Styles.mainColor
                                            : Colors.grey
                                            : bonoUser == '' ? Styles.mainColor : Colors.grey,
                                      )))),
                          onPressed: () async {

                              var result = await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return ConfirmationDialog(
                                        text: 'Quieres solicitar el bono?');
                                  });
                              if (result) {
                                await _brandDataService.addBonoRequestToBrand(
                                    widget.brandId,
                                    currentUser.id!,
                                    _bono.id!,
                                    _bono.title!,
                                    _bono.price.toString(),
                                    _bono.classes.toString(),
                                    Timestamp.now()
                                );

                                await _userDataService.addBonoRequestToUser(
                                    widget.brandId, currentUser.id!, _bono.id!);

                                _topSnackBar.topsnackbar(context,
                                    'Se ha solicitado el bono', Colors.green);

                                setState(() {
                                  bonoSol = _bono.id!;
                                });

                              }

                          },
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.height * 0.01,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      elevation: 3,
      shadowColor: bonoSol != ''
          ? bonoSol == _bono.id!
              ? Styles.mainColor
              : Colors.grey
          : bonoUser == '' ? Styles.mainColor : Colors.grey,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.005,
          horizontal: MediaQuery.of(context).size.width * 0.05),
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: bonoSol != ''
                  ? bonoSol == _bono.id!
                      ? Styles.mainColor
                      : Colors.grey
                  : bonoUser == '' ? Styles.mainColor : Colors.grey,
              width: MediaQuery.of(context).size.width * 0.003)),
    );
  }



  /*
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
   */

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
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                StreamBuilder<QuerySnapshot>(
                    stream:
                    _brandDataService.getAllBonosFromBrand(widget.brandId),
                    builder: (context, snapshot) {
                      if (snapshot == null ||
                          snapshot.data == null ||
                          snapshot.data!.docs == null) {
                        return Container(
                            height: MediaQuery.of(context).size.height * 0.65,
                            child: Center(child: LoadingViewPurple()));
                      } else {
                        bonosList = _bonosUtils.documentsToBonos(
                            snapshot.data!.docs, true);
                        return ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            //controller: scrollController,
                            scrollDirection: Axis.vertical,
                            itemCount: bonosList.length,
                            itemExtent:
                            MediaQuery.of(context).size.height * 0.20,
                            itemBuilder: (context, index) {
                              Bono bono = bonosList[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                    MediaQuery.of(context).size.height *
                                        0.01),
                                child: returnBono(bono),
                              );
                            });
                      }
                    }),
                /*
                StreamBuilder<QuerySnapshot>(
                    stream:
                        _brandDataService.getAllBonosFromBrand(widget.brandId),
                    builder: (context, snapshot) {
                      if (snapshot == null ||
                          snapshot.data == null ||
                          snapshot.data!.docs == null) {
                        return Container(
                            height: MediaQuery.of(context).size.height * 0.65,
                            child: Center(child: LoadingViewPurple()));
                      } else {
                        bonosList = _bonosUtils.documentsToBonos(
                            snapshot.data!.docs, true);
                        return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: bonosList.length,
                            itemBuilder: (context, index) {
                              Bono bono = bonosList[index];
                              return returnBono(bono);
                            });
                      }
                    }),

                 */
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
