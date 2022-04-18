import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/ActionDialogs/CreateBonoDialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../../Globals/GlobalVars.dart';
import '../../../../../../../Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/ConfirmationDialog.dart';
import '../../../../../../../Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import '../../../Data/DataService/UserDataService.dart';
import '../../../Data/Models/BonoRequest.dart';
import '../../../Data/Models/Usuario.dart';
import '../../../Globals/Providers/ThemeProvider.dart';
import '../../../Globals/Widgets/Components/Images/CircularImage.dart';
import '../../../Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/RequestConfirmationDialog.dart';
import 'BonosRequests.dart';

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
  var _userDataService = new UserDataService();

  //Utils bonos
  var _bonosUtils = new BonosUtils();

  //boolean to filter by actives
  bool seeActives = true;

  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
  // Boolean Loading
  bool isFirstBuild = true;
  bool isDark = false;

  // Bonos list
  List<BonoRequest> bonosRequestsList = [];

  @override
  void initState() {
    getBrandBonos();
    super.initState();
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
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

  // Build your bonos
  Widget buildYourBonos() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02, ),
          child: Padding(
              padding: EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width * 0.11, ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      var result = await showDialog(
                          context: context,
                          builder: (_) {
                            return CreateBonoDialog(
                              brandId: widget.brandId,
                            );
                          });
                    },
                    child: Container(
                        width: 150,
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_shopping_cart,
                                color: Theme.of(context).primaryColor,
                                size: MediaQuery.of(context).size.width * 0.06,
                              ),
                              Text(
                                'AÑADIR BONO',
                                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                        )),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        seeActives = !seeActives;
                      });
                    },
                    child: Container(
                        width: 150,
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              !seeActives ? Icon(
                                Icons.highlight_off,
                                color: Theme.of(context).primaryColor,
                                size: MediaQuery.of(context).size.width * 0.06,
                              ) : Icon(
                                Icons.task_alt,
                                color:  Styles.mainColor,
                                size: MediaQuery.of(context).size.width * 0.06,
                              ),
                              seeActives ? Text(
                                'ACTIVADOS',
                                style:  TextStyle( color: Styles.mainColor),
                              ) : Text(
                                'DESACTIVADOS',
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ],
                          ),
                        )),
                  ),
                ],
              ),
            ),
        ),
        Container(
          height: 1,
          color: Colors.grey,
        ),
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
    );
  }

  Widget buildBonosRequest()
  {
    return Column(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.width*0.02,),
              TabBar(
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 5,
                      isScrollable: true,
                      tabs: [
                        Container(
                          width: safeAreaWidth*0.3,
                          child: Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!.yourBonos.toUpperCase(),
                                      style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).primaryColor),
                                      textAlign: TextAlign.center
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: safeAreaWidth*0.3,
                          child: Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!.solicitudesBonos.toUpperCase(),
                                      style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).primaryColor),
                                      textAlign: TextAlign.center
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: safeAreaWidth*0.4,
                          child: Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!.bonosClient.toUpperCase(),
                                      style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).primaryColor),
                                      textAlign: TextAlign.center
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      onTap: (index) {

                      },
                    ),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            buildYourBonos(),
            buildBonosRequest(),
            Container(),
          ],
        ),
      ),
    );
  }

  /*
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
              IconButton(
                icon: Icon(Icons.request_quote, size: MediaQuery.of(context).size.width*0.06,),
                onPressed: () async {
                  Navigator.push(
                      context,
                      CupertinoPageRoute<String>(
                        builder: (context) => BonosRequests(
                          brandId: widget.brandId,
                        ),
                      )
                  );
                },
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
   */


}
