import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lColor.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../Globals/GlobalVars.dart';
import '../../../../../../Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'AddBono.dart';
import 'BonosRequests.dart';

class BonosPro extends StatefulWidget {
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;

  BonosPro(
      {Key? key,
      required this.brandId,
      required this.pinned,
      required this.pinnedChanged})
      : super(key: key);

  @override
  _BonosProState createState() => _BonosProState();
}

class _BonosProState extends State<BonosPro> {
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;

  bool get _isAppBarExpanded {
    return _scrollController!.hasClients &&
        _scrollController!.offset >
            (MediaQuery.of(context).size.height * 0.15 - kToolbarHeight);
  }

  // Boolean Loading
  bool isLoading = false;
  final _lColor = lColor();

  // Bonos list
  List<Bono> bonosList = [];
  List<Usuario> allClients = [];

  //Brand Service
  final _brandDataService = BrandDataService();
  final _userDataService = UserDataService();

  //Utils bonos
  final _bonosUtils = BonosUtils();

  //boolean to filter by actives
  bool seeActives = true;

  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;

  // Boolean Loading
  bool isFirstBuild = true;
  bool isDark = false;

  //HashMap to control the bonos given
  HashMap hashMap = HashMap<String, String>();

  //Brand
  Brand brand = Brand();

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
    super.initState();
    _scrollController = ScrollController()
      ..addListener(
        () => _isAppBarExpanded
            ? setState(() {
                appBarExpanded = true;
              })
            : setState(() {
                appBarExpanded = false;
              }),
      );
    getBrand();
    getBrandBonos();
    getAllUsers();
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
    return GestureDetector(
      onTap: () {
        setState(() {
          bonoSee = _bono.id!;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width * 0.01,
            horizontal: MediaQuery.of(context).size.width * 0.065),
        child: Container(
          height: MediaQuery.of(context).size.width * 0.50,
          width: MediaQuery.of(context).size.width * 0.25,
          decoration: BoxDecoration(
              image: DecorationImage(
                opacity: 150,
                colorFilter: ColorFilter.mode(
                    Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)),
                    BlendMode.color),
                image: NetworkImage(currentUser.imageUrl!),
                fit: BoxFit.cover,
              ),
              //color: Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)),
              borderRadius: const BorderRadius.all(const Radius.circular(15))),
          child: Column(
            children: [
              ListTile(
                leading: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01,
                      left: MediaQuery.of(context).size.height * 0.01),
                  child: CircularImage(
                    size: MediaQuery.of(context).size.width * 0.10,
                    image: brand.logoUrl,
                    color:
                        Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)),
                    borderWidth: 1.0,
                  ),
                ),
                trailing: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01,
                      left: MediaQuery.of(context).size.height * 0.01),
                  child: Text(
                    brand.name!.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        ?.copyWith(fontWeight: FontWeight.normal),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.13,
              ),
              ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01,
                        left: MediaQuery.of(context).size.height * 0.01),
                    child: Text(
                      _bono.title!.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01,
                        left: MediaQuery.of(context).size.height * 0.01),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.height * 0.02),
                          child: Text(
                            _bono.price!.toString().toUpperCase() + '€',
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Text(
                          _bono.classes!.toString().toUpperCase() +
                              ' ' +
                              AppLocalizations.of(context)!
                                  .sessions
                                  .toUpperCase(),
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  )),
              //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget returnBonoOpen(Bono _bono) {
    return GestureDetector(
      onTap: () {
        print(bonoSee);
        setState(() {
          bonoSee = 'none';
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width * 0.01,
            horizontal: MediaQuery.of(context).size.width * 0.065),
        child: Container(
          height: MediaQuery.of(context).size.width * 1.5,
          width: MediaQuery.of(context).size.width * 0.25,
          decoration: BoxDecoration(
              image: DecorationImage(
                opacity: 150,
                colorFilter: ColorFilter.mode(
                    Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)),
                    BlendMode.color),
                image: NetworkImage(currentUser.imageUrl!),
                fit: BoxFit.cover,
              ),
              //color: Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)),
              borderRadius: const BorderRadius.all(const Radius.circular(15))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01,
                      left: MediaQuery.of(context).size.height * 0.01),
                  child: CircularImage(
                    size: MediaQuery.of(context).size.width * 0.10,
                    image: brand.logoUrl,
                    color:
                        Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)),
                    borderWidth: 1.0,
                  ),
                ),
                trailing: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01,
                      left: MediaQuery.of(context).size.height * 0.01),
                  child: Text(
                    brand.name!.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        ?.copyWith(fontWeight: FontWeight.normal),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.13,
              ),
              ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01,
                        left: MediaQuery.of(context).size.height * 0.01),
                    child: Text(
                      _bono.title!.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01,
                        left: MediaQuery.of(context).size.height * 0.01),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.height * 0.02),
                          child: Text(
                            _bono.price!.toString().toUpperCase() + '€',
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Text(
                          _bono.classes!.toString().toUpperCase() +
                              ' ' +
                              AppLocalizations.of(context)!
                                  .sessions
                                  .toUpperCase(),
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  )),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.05,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01,
                      left: MediaQuery.of(context).size.height * 0.03),
                    child: Text(
                      _bono.description!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2,
                      textAlign: TextAlign.left,
                    ),
       
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.70,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.03,
                        horizontal: MediaQuery.of(context).size.height * 0.01),
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.32,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius:
                          const BorderRadius.all(const Radius.circular(20))),
                      child: Align(
                        alignment: Alignment.center,
                        //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
                        child: Text(
                          AppLocalizations.of(context)!
                              .edit.toUpperCase(),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                    ),
                  ),
              GestureDetector(
                    onTap: () {
                      _bono.isActive = !_bono.isActive!;
                      _brandDataService.updateBonoActive(brand.id!, _bono.id!, _bono.isActive!);
                      setState(() {

                      });
                    },
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.03,
                        right: MediaQuery.of(context).size.height * 0.02),

                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.32,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius:
                            const BorderRadius.all(const Radius.circular(20))),
                        child: Align(
                          alignment: Alignment.center,
                          //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
                          child: Text(
                            _bono.isActive!? 'Desactivar'.toUpperCase() : 'Activar'.toUpperCase(),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),


              //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
            ],
          ),
        ),
      ),
    );


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
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
                  color:
                      Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)),
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
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(10))),
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
                      horizontal: MediaQuery.of(context).size.width * 0.04,
                      vertical: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                right:
                                    MediaQuery.of(context).size.width * 0.05),
                            child: _bono.isActive!
                                ? Text(
                                    'ACTIVADO',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green),
                                    textAlign: TextAlign.left,
                                  )
                                : Text(
                                    'DESACTIVADO',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                    textAlign: TextAlign.left,
                                  ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.01,
                                right: _bono.isActive!
                                    ? MediaQuery.of(context).size.width * 0.01
                                    : MediaQuery.of(context).size.width * 0.01),
                            child: Text(
                              'Venciment: 07/07/2022',
                              style: Theme.of(context).textTheme.bodyText1,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                right:
                                    MediaQuery.of(context).size.width * 0.01),
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
                        'Ha sigut comprat ' +
                            _bono.compras!.toString() +
                            ' cops',
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
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
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
                return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Center(child: LoadingView()));
              } else {
                bonosList = _bonosUtils.documentsToBonos(
                    snapshot.data!.docs, orderBonoSelectedNumber);
                return Expanded(
                  child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      //controller: scrollController,
                      scrollDirection: Axis.vertical,
                      itemCount: bonosList.length,
                      itemBuilder: (context, index) {
                        Bono bono = bonosList[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01,
                              horizontal:
                                  MediaQuery.of(context).size.width * 01),
                          child: bonoSee == bono.id
                              ? returnBonoOpen(bono)
                              : returnBono(bono),
                        );
                      }),
                );
              }
            }),
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            expandedHeight: MediaQuery.of(context).size.height * 0.15,
            elevation: 4,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).backgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: kToolbarHeight +
                            MediaQuery.of(context).size.height * 0.051),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: Text(
                        AppLocalizations.of(context)!.bonos,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.035,
                    ),
                    Container(
                      color: AppColors.grey,
                      height: 1.0,
                    ),
                  ],
                ),
              ),
              titlePadding: EdgeInsets.zero,
              //centerTitle: true,
            ),
            title: appBarExpanded
                ? Text(
                    AppLocalizations.of(context)!.bonos,
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  )
                : Container(),
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: MediaQuery.of(context).size.height * 0.04,
                    ),
                    onPressed: () =>
                        mambaProScaffoldKey.currentState?.openDrawer()),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.01),
                child: IconButton(
                  icon: Icon(
                    widget.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: widget.pinned
                        ? AppColors.red
                        : Theme.of(context).primaryColor.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.pinned = !widget.pinned;
                    });
                    widget.pinnedChanged(widget.pinned);
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              /*
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
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.02),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                            color: Colors.grey,
                            style: BorderStyle.solid,
                            width: 0.80),
                      ),
                      child: DropdownButton<String>(
                        items: ordenBonos.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
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

               */
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: _brandDataService.getAllBonosFromBrand(widget.brandId),
              builder: (context, snapshot) {
                if (snapshot == null ||
                    snapshot.data == null ||
                    snapshot.data!.docs == null) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: Center(child: LoadingView())),
                  );
                } else {
                  bonosList = _bonosUtils.documentsToBonos(
                      snapshot.data!.docs, orderBonoSelectedNumber);
                  if (bonosList.isNotEmpty) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          Bono bono = bonosList[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.01),
                            child: bonoSee == bono.id
                                ? returnBonoOpen(bono)
                                : returnBono(bono),
                          );
                        },
                        childCount: bonosList.length,
                      ),
                    );
                  } else {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: Image.asset(Constants.emptyCalendar)),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.005),
                            Text(
                              "NO " +
                                  AppLocalizations.of(context)!
                                      .solicitudesBonos,
                              style: Theme.of(context).textTheme.caption,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.12),
                          ],
                        ),
                      ),
                    );
                  }
                }
              })
        ],
      ),
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
