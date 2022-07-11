import 'dart:collection';

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
import '../../../../../../Globals/GlobalVars.dart';
import '../../../../../../Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/ConfirmationDialog.dart';
import '../../../../../../Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import '../../../../Data/DataService/UserDataService.dart';
import '../../../../Data/Models/BonoRequest.dart';
import '../../../../Data/Models/Brand.dart';
import '../../../../Data/Models/Usuario.dart';
import '../../../../Globals/Providers/ThemeProvider.dart';
import '../../../../Globals/Widgets/Components/Images/CircularImage.dart';
import '../../../../Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/RequestConfirmationDialog.dart';
import '../../../../Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import '../../../../Globals/Widgets/MambaCoin/MambaCoin.dart';
import 'AddBono.dart';
import 'BonosRequests.dart';

class BonosPro extends StatefulWidget {
  String brandId;

  BonosPro({Key? key, required this.brandId}) : super(key: key);

  @override
  _BonosProState createState() => _BonosProState();
}

class _BonosProState extends State<BonosPro> {
  // Boolean Loading
  bool isLoading = false;

  //Mamba Coin
  MambaCoin _mambaCoin = new MambaCoin();

  // Bonos list
  List<Bono> bonosList = [];
  List<Usuario> allClients = [];

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

  //HashMap to control the bonos given
  HashMap hashMap = new HashMap<String, String>();

  //Brand
  Brand brand = new Brand();

  //Ordenar bonos
  List<String> ordenBonos = [
    'Activos',
    'Desactivados',
    'Más nuevos',
    'Más antiguos'
  ];

  String ordenBonosSelected = 'Activos';

  int orderBonoSelectedNumber = 0;

  String bonoSee = 'nadie';

  @override
  void initState() {
    getBrand();
    getBrandBonos();
    getAllUsers();
    super.initState();
  }

  Future<void> getBrand() async {
    brand = await _brandDataService.getBrandDetails(widget.brandId);
  }

  Future<void> getAllUsers() async {
    List<Usuario> brandUsers =
        await _brandDataService.getBrandUsers(currentBrand.id!);
    allClients = [];
    for (var i = 0; i < brandUsers.length; i++) {
      Usuario user = brandUsers[i];
      if (!user.isTrainer!) {
        allClients.add(user);
      }
    }
    // Sort Clients
    allClients.sort((a, b) {
      return a.name
          .toString()
          .toLowerCase()
          .compareTo(b.name.toString().toLowerCase());
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    print("Device H and W: " +
        MediaQuery.of(context).size.height.toString() +
        " " +
        MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: " +
        safeAreaHeight.toString() +
        " " +
        safeAreaWidth.toString());
  }

  String getUsersFullName(Usuario user) {
    return "${user.firstName} ${user.lastName}";
  }

  // Gets the bonos from the brand
  Future<void> getBrandBonos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  Widget returnBono(Bono _bono) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (bonoSee == _bono.id!) {
                  bonoSee = 'nadie';
                } else {
                  bonoSee = _bono.id!;
                }
              });
            },
            child: ListTile(
              leading: Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05),
                child: CircularImage(
                  size: MediaQuery.of(context).size.width * 0.15,
                  image: brand.logoUrl,
                  color: Colors.green.shade200,
                  borderWidth: 1.0,
                ),
              ),
              title: Text(
                _bono.title!,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bono.classes.toString() + " sessions",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
              trailing: Padding(
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.05),
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.1,
                  width: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Align(
                    alignment: Alignment.center,
                    //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
                    child: Text(
                      _bono.price.toString() + " €",
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ),
              ),
            ),
          ),
          bonoSee == _bono.id
              ? Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding:  EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.05),
                            child: _bono.isActive!? Text(
                              'ACTIVADO',
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                  fontWeight: FontWeight.bold, color: Colors.green),
                              textAlign: TextAlign.left,
                            ) : Text(
                              'DESACTIVADO',
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                  fontWeight: FontWeight.bold, color: Colors.red),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.01, right: _bono.isActive!? MediaQuery.of(context).size.width * 0.01 : MediaQuery.of(context).size.width * 0.01),
                            child: Text(
                              'Venciment: 07/07/2022',
                              style: Theme.of(context).textTheme.bodyText1,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.01),
                            child: IconButton(
                                icon: Icon(Icons.edit,
                                    color: Theme.of(context).primaryColor,
                                    size: safeAreaWidth * 0.06),
                                alignment: Alignment.centerRight,
                                onPressed: navigateToBonosRequestScreen),
                          ),
                        ],
                      ),
                      Text(
                          'Ha sigut comprat ' + _bono.compras!.toString() + ' cops',
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.left,
                        ),

                    ],
                  ),
                )
              : Container(
                  height: 1,
                  color: Colors.grey,
                ),
          bonoSee != _bono.id
              ? Container()
              : Container(
                  height: 1,
                  color: Colors.grey,
                ),
        ],
      ),
    );
  }

  Widget returnBonoRequest(BonoRequest _bonoRequest, var user) {
    Usuario _user = user;
    return ListTile(
        leading: CircularImage(
          size: MediaQuery.of(context).size.width * 0.15,
          image: _user.imageUrl!,
          color: Theme.of(context).primaryColor,
          borderWidth: 1,
        ),
        title: Text(
          _user.name! + ' ha solicitado ' + _bonoRequest.title!.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .bodyText1
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              _bonoRequest.classes! +
                  ' sesiones por ' +
                  _bonoRequest.price! +
                  ' euros',
              style: Theme.of(context).textTheme.caption,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              _bonoRequest.timeRequested!.toDate().toString(),
              style:
                  Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 13),
            ),
          ],
        ),
        onTap: () async {
          var result = await showDialog(
              context: context,
              builder: (_) {
                return RequestConfirmationDialog(
                  text: 'Si aceptas se le otorgaran ' +
                      _bonoRequest.classes! +
                      ' sesiones',
                  userId: _user.id!,
                );
              });
          if (result) {
            await _brandDataService.addUserToBrand(
                _bonoRequest.userId!, widget.brandId, 0);
            _userDataService.addBonoToUser(
                widget.brandId,
                _bonoRequest.userId!,
                _bonoRequest.bonoId!,
                int.parse(_bonoRequest.classes!),
                Timestamp.now());
            _userDataService.deleteUserBonoRequest(
                _bonoRequest.userId!, widget.brandId, _bonoRequest.bonoId!);
            _brandDataService.deleteBrandBonoRequest(
                widget.brandId, _bonoRequest.bonoId!);
            _brandDataService.updateBonoCompras(
                widget.brandId, _bonoRequest.bonoId!);
          }
        });
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

  Widget returnClientsBonos(var user) {
    return ListTile(
      leading: CircularImage(
        size: MediaQuery.of(context).size.width * 0.15,
        image: user.imageUrl,
        color: Theme.of(context).primaryColor,
        borderWidth: 1.0,
      ),
      title: Text(
        getUsersFullName(user),
        style: Theme.of(context)
            .textTheme
            .bodyText1
            ?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "@${user.nick!}",
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      trailing: Container(
        width: MediaQuery.of(context).size.width * 0.40,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Row(
            children: [
              Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          if (user.sessions == null)
                            user.sessions = '1';
                          else
                            user.sessions =
                                (int.parse(user.sessions!) + 1).toString();
                        });
                      },
                      child: Icon(
                        Icons.done,
                        color: Theme.of(context).primaryColor,
                        size: MediaQuery.of(context).size.height * 0.02,
                      )),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          user.sessions = hashMap[user.id];
                        });
                      },
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).primaryColor,
                        size: MediaQuery.of(context).size.height * 0.02,
                      )),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          if (user.sessions == null) {
                            if (!hashMap.containsKey(user.id))
                              hashMap.putIfAbsent(user.id, () => '0');
                            user.sessions = '1';
                          } else {
                            if (!hashMap.containsKey(user.id))
                              hashMap.putIfAbsent(user.id, () => user.sessions);
                            user.sessions =
                                (int.parse(user.sessions!) + 1).toString();
                          }
                        });
                      },
                      child: Icon(
                        Icons.add_circle_outline,
                        color: Theme.of(context).primaryColor,
                        size: MediaQuery.of(context).size.height * 0.02,
                      )),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                  user.sessions != null
                      ? _mambaCoin.mambaCoinStatic(context,
                          user.sessions!.toString(), 30, currentBrand.logoUrl)
                      : _mambaCoin.mambaCoinStatic(
                          context, '0', 30, currentBrand.logoUrl),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                  GestureDetector(
                      onTap: () {
                        if (user.sessions != null) {
                          setState(() {
                            if (!hashMap.containsKey(user.id))
                              hashMap.putIfAbsent(user.id, () => user.sessions);
                            user.sessions =
                                (int.parse(user.sessions!) + -1).toString();
                          });
                        }
                      },
                      child: Icon(
                        Icons.remove_circle_outline,
                        color: Theme.of(context).primaryColor,
                        size: MediaQuery.of(context).size.height * 0.02,
                      )),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: () async {
        var result = await Navigator.push(
            context,
            CupertinoPageRoute<bool?>(
                builder: (context) => ProfileViewUser(
                      userID: user.id!,
                      viewOnly: false,
                    )));
        /* if (result == true) {
          setState(() {
            isLoading = true;
          });
          getAllUsers();
        }

        */
      },
    );
  }

  // Build your bonos
  Widget buildYourBonos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.06),
                child: Text('Ordenar por',
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.02,
                    right: MediaQuery.of(context).size.width * 0.01),
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.10,
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                        color: Colors.grey,
                        style: BorderStyle.solid,
                        width: 0.80),
                  ),
                  child: DropdownButton<String>(
                    items: ordenBonos.map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    hint: Text(ordenBonosSelected),
                    onChanged: (newVal) {
                      ordenBonosSelected = newVal!;
                      if (ordenBonosSelected == "Activos")
                        orderBonoSelectedNumber = 0;
                      else if (ordenBonosSelected == "Desactivados")
                        orderBonoSelectedNumber = 1;
                      else if (ordenBonosSelected == "Más nuevos")
                        orderBonoSelectedNumber = 2;
                      else if (ordenBonosSelected == "Más antiguos")
                        orderBonoSelectedNumber = 3;
                      setState(() {});
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.08),
                child: IconButton(
                    icon: Icon(Icons.request_quote,
                        color: Theme.of(context).primaryColor,
                        size: safeAreaWidth * 0.06),
                    alignment: Alignment.centerRight,
                    onPressed: navigateToBonosRequestScreen),
              ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: _brandDataService.getAllBonosFromBrand(widget.brandId),
            builder: (context, snapshot) {
              if (snapshot == null ||
                  snapshot.data == null ||
                  snapshot.data!.docs == null) {
                return Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Center(child: LoadingViewPurple()));
              } else {
                bonosList = _bonosUtils.documentsToBonos(
                    snapshot.data!.docs, orderBonoSelectedNumber);
                return Expanded(
                  child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      //controller: scrollController,
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
                );
              }
            }),
      ],
    );
  }

  Widget buildBonosRequest() {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        StreamBuilder<QuerySnapshot>(
            stream: _brandDataService.getBonosRequestsFromBrand(widget.brandId),
            builder: (context, snapshot) {
              if (snapshot == null ||
                  snapshot.data == null ||
                  snapshot.data!.docs == null) {
                return Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Center(child: LoadingViewPurple()));
              } else {
                bonosRequestsList =
                    _bonosUtils.documentsToBonosRequests(snapshot.data!.docs);
                return Expanded(
                  child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      //controller: scrollController,
                      scrollDirection: Axis.vertical,
                      itemCount: bonosRequestsList.length,
                      itemExtent: MediaQuery.of(context).size.height * 0.20,
                      itemBuilder: (context, index) {
                        BonoRequest bonoRequest = bonosRequestsList[index];
                        return FutureBuilder(
                            future: _userDataService
                                .getUserDetails(bonoRequest.userId!),
                            // Run check for a single queryRow
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
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

  Widget buildClientsBonos() {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Expanded(
          child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              //controller: scrollController,
              scrollDirection: Axis.vertical,
              itemCount: allClients.length,
              itemExtent: MediaQuery.of(context).size.height * 0.20,
              itemBuilder: (context, index) {
                Usuario user = allClients[index];
                return Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.01),
                  child: returnClientsBonos(user),
                );
              }),
        ),
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
    return Scaffold(
      body: buildYourBonos(),
      floatingActionButton: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
        child: FloatingActionButton(
          onPressed: () {
            navigateToAddBonosScreen();
          },
          backgroundColor: Styles.mainColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // Navigate to Bonos Request Screen
  void navigateToBonosRequestScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => BonosRequests(
            brandId: widget.brandId,
          ),
        ));
  }

  // Navigate to Add Bonos
  void navigateToAddBonosScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => AddBono(
            brandId: widget.brandId,
          ),
        ));
  }
}
