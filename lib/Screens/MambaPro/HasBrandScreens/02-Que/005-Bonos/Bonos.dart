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
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/AddEditBono.dart';
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
  bool isLoading = true;
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
    if(_bono.isActive! == true) {
      return GestureDetector(
        onTap: () {
          setState(() {
            bonoSee = _bono.id!;
          });
        },
        child: _bonosUtils.bonoObject(context, _bono, brand, _lColor),
      );
    }
    else
      {
       return _bonosUtils.bonoObjectDesactivated(context, _bono, brand, _lColor,_brandDataService);

      }
  }

  Widget returnBonoOpen(Bono _bono) {
    if(_bono.isActive! == true) {
      return GestureDetector(
        onTap: () {
          setState(() {
            bonoSee = 'none';
          });
        },
        child: _bonosUtils.bonoObjectOpen(
            context, _bono, brand, _lColor, _brandDataService),
      );
    }
    else
    {
      return  _bonosUtils.bonoObjectDesactivated(context, _bono, brand, _lColor,_brandDataService);

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
    return isLoading
        ? LoadingView()
        : Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.darkGrey,
                  expandedHeight: MediaQuery.of(context).size.height * 0.15,
                  elevation: 4,
                  floating: true,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: AppColors.darkGrey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: kToolbarHeight +
                                  MediaQuery.of(context).size.height * 0.051),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05),
                            child: Text(
                              AppLocalizations.of(context)!.bonos,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  ?.copyWith(
                                    color: AppColors.white,
                                  ),
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
                          style: Theme.of(context)
                              .appBarTheme
                              .titleTextStyle
                              ?.copyWith(
                                color: AppColors.white,
                              ),
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
                            color: AppColors.white,
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
                          widget.pinned
                              ? Icons.push_pin
                              : Icons.push_pin_outlined,
                          color: widget.pinned
                              ? AppColors.red
                              : AppColors.white.withOpacity(0.5),
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
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.03),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream:
                        _brandDataService.getAllBonosFromBrand(widget.brandId),
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
                                          MediaQuery.of(context).size.height *
                                              0.01),
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
                                      width: MediaQuery.of(context).size.width *
                                          0.30,
                                      child:
                                          Image.asset(Constants.emptyCalendar)),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.005),
                                  Text(
                                    "NO " +
                                        AppLocalizations.of(context)!
                                            .solicitudesBonos,
                                    style: Theme.of(context).textTheme.caption,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.12),
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
                  navigateToAddBonosScreen(new Bono(
                    color: "0",
                    isActive: true,
                    classes: 0,
                    opacity: 1,
                    imageUrl: '',
                    isDegradate: false,
                  ), brand);
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
  void navigateToAddBonosScreen(Bono bono, Brand _brand) {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => AddEditBono(
            brand: _brand,
            bono: bono,
            edit: false,
          ),
        ));
  }
}
