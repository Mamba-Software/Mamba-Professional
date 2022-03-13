import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
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
  var  _bonosUtils = new BonosUtils();

  @override
  void initState() {
    super.initState();
  }

  // Gets the bonos from the brand
  Future<void> getBrandBonos() async {
    setState(() {
    });
  }

  Widget returnBono(Bono _bono) {
    return ListTile(
      title: Text(
        _bono.title!,
        style: Theme.of(context)
            .textTheme
            .bodyText1
            ?.copyWith(fontWeight: true ? FontWeight.normal : FontWeight.bold),
      ),
      trailing: Icon(_bono.isActive! ? Icons.done : Icons.close,
          color: Theme.of(context).primaryColor,
          size: MediaQuery.of(context).size.width * 0.05),
      subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _bono.classes!.toString() + ' Classes',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  ?.copyWith(fontSize: 10),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Text(
              _bono.price!.toString() + ' Euros',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  ?.copyWith(fontSize: 10),
            ),
          ],
      ),
      /*
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              _bono.description!,
              style: Theme.of(context).textTheme.caption,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.60),
          ]),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _bono.classes!.toString() + ' Classes',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    ?.copyWith(fontSize: 10),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),
              Text(
                _bono.price!.toString() + ' Euros',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    ?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),

       */
      minVerticalPadding: MediaQuery.of(context).size.width * 0.02,
      onTap: () async {
        var result = await showDialog(
            context: context,
            builder: (_) {
              return ConfirmationDialog(text: _bono.isActive!
                  ? 'Quieres desactivar el bono?'
                  : 'Quieres activar el bono?');
            }
        );
        if (result) {
          _brandDataService.updateBono(widget.brandId, _bono.id!, !_bono.isActive!);
        }
      }
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
          IconButton(
          icon: Icon(Icons.group_add, size: MediaQuery.of(context).size.width*0.07, color: Theme.of(context).primaryColor),
            onPressed: () {
            }
        ),
      ],
      ),
      body: isLoading
          ? Center(child: LoadingViewPurple())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.02),
                  child: ListTile(
                    onTap: () async {
                      var result = await showDialog(
                          context: context,
                          builder: (_) {
                            return CreateBonoDialog(
                              brandId: widget.brandId,
                            );
                          }
                      );
                    },
                    leading: Icon(
                      Icons.add_shopping_cart,
                      color: Theme.of(context).primaryColor,
                      size: MediaQuery.of(context).size.width * 0.06,
                    ),
                    title: Text(
                      'Afegeix bono',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: Theme.of(context).primaryColor,
                ),
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
