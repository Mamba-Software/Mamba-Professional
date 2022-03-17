import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/ActionDialogs/ConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/ActionDialogs/CreateBonoDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViews/LoadingViewPurple.dart';

class Bonos extends StatefulWidget {
  String brandId;

  Bonos({Key? key, required this.brandId}) : super(key: key);

  @override
  _BonosState createState() => _BonosState();
}

class _BonosState extends State<Bonos> {
  // Boolean Loading
  bool isLoading = false;

  // Bonos list
  List<Bono> bonosList = [];

  //Brand Service
  var _brandDataService = new BrandDataService();

  //Utils bonos
  var _bonosUtils = new BonosUtils();

  //boolean to filter by actives
  bool seeActives = true;

  @override
  void initState() {
    getBrandBonos();
    super.initState();
  }

  // Gets the bonos from the brand
  Future<void> getBrandBonos() async {
    await Future.delayed(const Duration(milliseconds: 500));
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
                  color: _bono.isActive! ? Styles.mainColor : Colors.grey),
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
                          Text("50% de compra"),
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
                        TextButton(
                          child: Text(
                              _bono.isActive! ? 'DESACTIVAR' : 'ACTIVAR',
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
                                          color: _bono.isActive!
                                              ? Styles.mainColor
                                              : Colors.grey)))),
                          onPressed: () async {
                            var result = await showDialog(
                                context: context,
                                builder: (_) {
                                  return ConfirmationDialog(
                                      text: _bono.isActive!
                                          ? 'Quieres desactivar el bono?'
                                          : 'Quieres activar el bono?');
                                });
                            if (result) {
                              _brandDataService.updateBono(
                                  widget.brandId, _bono.id!, !_bono.isActive!);
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
      shadowColor: _bono.isActive! ? Styles.mainColor : Colors.grey,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.005,
          horizontal: MediaQuery.of(context).size.width * 0.05),
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: _bono.isActive! ? Styles.mainColor : Colors.grey,
              width: MediaQuery.of(context).size.width * 0.003)),
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
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              !seeActives ? TextButton(
                  onPressed: () {
                    setState(() {
                      seeActives = !seeActives;
                    });
                  },
                  child: Row(
                    children: [
                      SizedBox(
                          width:
                          MediaQuery.of(context).size.width * 0.01),
                      Text(
                        'ACTIVADOS',
                        style: seeActives ? TextStyle( color: Styles.mainColor) : Theme.of(context).textTheme.bodyText2,
                      ),
                      SizedBox(
                          width:
                          MediaQuery.of(context).size.width * 0.01),
                      Icon(
                        Icons.task_alt,
                        color: seeActives ? Styles.mainColor : Theme.of(context).primaryColor,
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                    ],
                  )) : TextButton(
                  onPressed: () {
                    setState(() {
                      seeActives = !seeActives;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        'DESACTIVADOS',
                        style: !seeActives ? TextStyle( color: Styles.mainColor) : Theme.of(context).textTheme.bodyText2,
                      ),
                      SizedBox(
                          width:
                          MediaQuery.of(context).size.width * 0.01),
                      Icon(
                        Icons.highlight_off,
                        color: !seeActives ? Styles.mainColor : Theme.of(context).primaryColor,
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                    ],
                  )
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02, horizontal: MediaQuery.of(context).size.width * 0.02, ),
            child: ListTile(
              onTap: () async {
                var result = await showDialog(
                    context: context,
                    builder: (_) {
                      return CreateBonoDialog(
                        brandId: widget.brandId,
                      );
                    });
              },
              leading: Icon(
                Icons.add_shopping_cart,
                color: Theme.of(context).accentColor,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
              title: Text(
                'Afegeix bono',
                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).accentColor),
              ),
            ),
          ),
          Container(
            height: 1,
            color: Theme.of(context).accentColor,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          StreamBuilder<QuerySnapshot>(
              stream: _brandDataService.getAllBonosFromBrand(widget.brandId),
              builder: (context, snapshot) {
                if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null) {
                  return Container(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: Center(child: LoadingViewPurple()
                      )
                  );
                } else {
                  bonosList = _bonosUtils.documentsToBonos(snapshot.data!.docs, seeActives);
                  return Expanded(
                    child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        //controller: scrollController,
                        scrollDirection: Axis.vertical,
                        itemCount: bonosList.length,
                        itemExtent: MediaQuery.of(context).size.height * 0.20,
                        itemBuilder: (context, index) {
                          Bono bono = bonosList[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.height * 0.01),
                            child: returnBono(bono),
                          );
                        }
                    ),
                  );
                }
              }
          ),
        ],
      ),
    );
  }
}
