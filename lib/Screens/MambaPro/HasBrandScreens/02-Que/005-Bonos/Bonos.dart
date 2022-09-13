import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/AddEditBono.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../Globals/GlobalVars.dart';
import '../../../../../../Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import '../../../../../Data/LibraryModels/lDegradate.dart';
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
  bool isLoading = true;
  final _lColor = lColor();
  var _lDegradate = new lDegradate();


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
    //getBrandBonos();
    //getAllUsers();
  }

  Future<void> getBrand() async {
    brand = await _brandDataService.getBrandDetails(widget.brandId);
    setState(() {
      isLoading = false;
    });
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
    if (_bono.isActive! == true) {
      return GestureDetector(
        onTap: () {
          setState(() {
            bonoSee = _bono.id!;
          });
        },
        child: _bonosUtils.bonoObject(context, _bono, brand, _lColor),
      );
    } else {
      return _bonosUtils.bonoObjectDesactivated(
          context, _bono, brand, _lColor, _brandDataService);
    }
  }

  Widget returnBonoOpen(Bono _bono) {
    if (_bono.isActive! == true) {
      return GestureDetector(
        onTap: () {
          setState(() {
            bonoSee = 'none';
          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.width * 0.01,
              horizontal: MediaQuery.of(context).size.width * 0.065),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                  height: MediaQuery.of(context).size.width * 1.5,
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: _bono.isDegradate!
                      ? BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(int.parse(_lDegradate.getlDegradate(_bono.color!).hexa1!)).withOpacity(_bono.opacity!),
                              Color(int.parse(_lDegradate.getlDegradate(_bono.color!).hexa2!)).withOpacity(_bono.opacity!),
                            ],
                          ),
                          image: _bono.imageUrl != null && _bono.imageUrl != ''
                              ? DecorationImage(
                                  opacity: 225,
                                  image: NetworkImage(_bono.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,

                          //color: Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)),
                          borderRadius:
                              const BorderRadius.all(const Radius.circular(15)))
                      : BoxDecoration(
                          image: _bono.imageUrl != null && _bono.imageUrl != ''
                              ? DecorationImage(
                                  opacity: 225,
                                  image: NetworkImage(_bono.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Color(int.parse(
                                  _lColor.getlColor(_bono.color!).hexa!))
                              .withOpacity(_bono.opacity!),
                          borderRadius: const BorderRadius.all(
                              const Radius.circular(15)))),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.015,
                    left: MediaQuery.of(context).size.height * 0.03),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: CircularImage(
                    size: MediaQuery.of(context).size.width * 0.10,
                    image: brand.logoUrl,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.02,
                    right: MediaQuery.of(context).size.height * 0.03),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    brand.name!.toUpperCase(),
                    style: Theme.of(context).textTheme.headline3?.copyWith(
                        fontWeight: FontWeight.normal, color: Colors.white),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.15,
                    left: MediaQuery.of(context).size.height * 0.005),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.05,
                        horizontal: MediaQuery.of(context).size.width * 0.005),
                    child: ListTile(
                        title: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.01,
                              left: MediaQuery.of(context).size.height * 0.01),
                          child: Text(
                            _bono.title!.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
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
                                    right: MediaQuery.of(context).size.height *
                                        0.02),
                                child: Text(
                                  _bono.price!.toString().toUpperCase() + '€',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.copyWith(color: Colors.white),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Text(
                                _bono.classes!.toString().toUpperCase() +
                                    ' ' +
                                    AppLocalizations.of(context)!
                                        .sessions
                                        .toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.30,
                      left: MediaQuery.of(context).size.height * 0.035,
                      right: MediaQuery.of(context).size.height * 0.04),
                  child: Text(
                    _bono.description!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.copyWith(color: Colors.white),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.60,
                      right: MediaQuery.of(context).size.height * 0.01),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_brandDataService is! String) {
                            navigateToAddBonosScreen( _bono, brand, true);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.03,
                              horizontal:
                                  MediaQuery.of(context).size.height * 0.01),
                          child: Container(
                            height: MediaQuery.of(context).size.width * 0.1,
                            width: MediaQuery.of(context).size.width * 0.32,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius: const BorderRadius.all(
                                    const Radius.circular(20))),
                            child: Align(
                              alignment: Alignment.center,
                              //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .edit
                                    .toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_brandDataService is! String) {
                            _bono.isActive = !_bono.isActive!;
                            _brandDataService.updateBonoActive(
                                brand.id!, _bono.id!, _bono.isActive!);
                          }
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
                                  color: Colors.white,
                                ),
                                borderRadius: const BorderRadius.all(
                                    const Radius.circular(20))),
                            child: Align(
                              alignment: Alignment.center,
                              //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
                              child: Text(
                                _bono.isActive!
                                    ? 'Desactivar'.toUpperCase()
                                    : 'Activar'.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        /*_bonosUtils.bonoObjectOpen(
            context, _bono, brand, _lColor, _brandDataService),*/
      );
    } else {
      return _bonosUtils.bonoObjectDesactivated(
          context, _bono, brand, _lColor, _brandDataService);
    }
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
                bonosList = _bonosUtils.documentsToBonos(snapshot.data!.docs, orderBonoSelectedNumber);
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

                        setState(() {});
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
            backgroundColor: AppColors.darkGrey,
            expandedHeight: MediaQuery.of(context).size.height*0.15,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 4,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.darkGrey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.025),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.bonos,
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white,),
                          ),
                          FittedBox(
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height*0.08,
                              width: MediaQuery.of(context).size.width*0.11,
                              child: TextButton(
                                onPressed: () async {
                                  int? result = await showModalBottomSheet<int?>(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    builder: (BuildContext context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.3,
                                        child: SizedBox(
                                          height: MediaQuery.of(context).size.height*0.4,
                                          width: MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                      AppLocalizations.of(context)!.filterBy,
                                                      style: Theme.of(context).textTheme.caption,
                                                      textAlign: TextAlign.left
                                                  ),
                                                  dense: true,
                                                ),
                                                ListTile(
                                                  title: Text(
                                                      AppLocalizations.of(context)!.mambaProActivated,
                                                      style: Theme.of(context).textTheme.bodyText1,
                                                      textAlign: TextAlign.left
                                                  ),
                                                ),
                                                ListTile(
                                                  title: Text(
                                                      AppLocalizations.of(context)!.mambaProDesactivated,
                                                      style: Theme.of(context).textTheme.bodyText1,
                                                      textAlign: TextAlign.left
                                                  ),
                                                ),
                                                ListTile(
                                                  title: Text(
                                                      AppLocalizations.of(context)!.filterBy,
                                                      style: Theme.of(context).textTheme.bodyText1,
                                                      textAlign: TextAlign.left
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Icon(
                                  Icons.filter_list,
                                  color: AppColors.white,
                                  size: MediaQuery.of(context).size.width*0.07,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01,),
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
            title: appBarExpanded ? Text(AppLocalizations.of(context)!.bonos, style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: AppColors.white,),) : Container(),
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: MediaQuery.of(context).size.height*0.04,
                    ),
                    onPressed: () => mambaProScaffoldKey.currentState?.openDrawer()
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
                child: IconButton(
                  icon: Icon(
                    widget.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: widget.pinned ? AppColors.red :  AppColors.white.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width*0.06,
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
          StreamBuilder<QuerySnapshot>(
              stream: _brandDataService.getAllBonosFromBrand(widget.brandId),
              builder: (context, snapshot) {
                if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: Center(
                          child: LoadingView()
                      )
                    ),
                  );
                } else {
                  bonosList = _bonosUtils.documentsToBonos(snapshot.data!.docs, orderBonoSelectedNumber);
                  if (bonosList.isNotEmpty) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                        Bono bono = bonosList[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                          child: returnBono(bono),
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
                                width: MediaQuery.of(context).size.width*0.30,
                                child: Image.asset(Constants.emptyCalendar)
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.005),
                            Text("NO " + AppLocalizations.of(context)!.solicitudesBonos, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
                            SizedBox(height: MediaQuery.of(context).size.height*0.12),
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
  void navigateToAddBonosScreen(Bono bono, Brand _brand, bool edit) {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => AddEditBono(
            brand: _brand,
            bono: bono,
            edit: edit,
          ),
        ));
  }
}
