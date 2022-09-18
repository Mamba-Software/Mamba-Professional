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
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Bonos/BonoCard.dart';
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

  int requests = 0;

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
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    print("Device H and W: " + MediaQuery.of(context).size.height.toString() + " " + MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: " + safeAreaHeight.toString() + " " + safeAreaWidth.toString());
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
    //return _bonosUtils.bonoObject(context, _bono, brand, _lColor);
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
      child: BonoCard(
        height: MediaQuery.of(context).size.height*0.22,
        width: MediaQuery.of(context).size.width*0.84,
        bono: _bono,
        brand: brand,
        canExpand: true,
        onlyView: false,
        condition: Condition(),
      ),
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
            expandedHeight: MediaQuery.of(context).size.height * 0.15,
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
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.05,
                          right: MediaQuery.of(context).size.width * 0.025),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.bonos,
                            style:
                                Theme.of(context).textTheme.headline1?.copyWith(
                                      color: AppColors.white,
                                    ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.08,
                            width: MediaQuery.of(context).size.width * 0.40,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.width *
                                0.1,
                            width: MediaQuery.of(context).size.width *
                                0.1,
                            child: Stack(
                              children: [
                                StreamBuilder<QuerySnapshot>(
                                    stream: _brandDataService
                                        .getBonosRequestsFromBrand(widget.brandId),
                                    builder: (context, snapshot) {
                                      if (snapshot == null ||
                                          snapshot.data == null ||
                                          snapshot.data!.docs == null) {
                                        return Container();
                                      } else {
                                        requests = _bonosUtils.documentsToBonosRequests(snapshot.data!.docs).length;
                                        if(requests != 0) {
                                          return Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              height: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width *
                                                  0.03,
                                              width: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width *
                                                  0.03,
                                              decoration: BoxDecoration(
                                                  color: AppColors.mainColor,
                                                  borderRadius: const BorderRadius
                                                      .all(
                                                      const Radius.circular(
                                                          20))),
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(1.0),
                                                  child: Text(
                                                      requests.toString(),
                                                     style: Theme.of(context)
                                                      .textTheme
                                                      .headline3
                                                      ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10),
                                                      textAlign:
                                                      TextAlign.center
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        else return Container();
                                      }
                                      return Container();
                                    }),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      navigateToBonosRequestScreen();
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerRight,
                                  icon: Icon(
                                    Icons.person_outline_rounded,
                                    color: AppColors.white,
                                    size: MediaQuery.of(context).size.width *
                                        0.07,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.08,
                              width: MediaQuery.of(context).size.width * 0.11,
                              child: TextButton(
                                onPressed: () async {
                                  int? result =
                                      await showModalBottomSheet<int?>(
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .filterBy,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .caption,
                                                      textAlign:
                                                          TextAlign.left),
                                                  dense: true,
                                                ),
                                                ListTile(
                                                  title: Text(
                                                       'Activados',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                      textAlign:
                                                          TextAlign.left),
                                                ),
                                                ListTile(
                                                  title: Text(
                                                      'Desactivados',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                      textAlign:
                                                          TextAlign.left),
                                                ),
                                                ListTile(
                                                  title: Text(
                                                      'Nombre',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                      textAlign:
                                                          TextAlign.left),
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
                                  size:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
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
                    style:
                        Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
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
                    widget.pinned ? Icons.push_pin : Icons.push_pin_outlined,
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
          StreamBuilder<QuerySnapshot>(
              stream: _brandDataService.getAllBonosFromBrand(widget.brandId),
              builder: (context, snapshot) {
                if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null) {
                  return SliverFillRemaining(
                    hasScrollBody: true,
                    child: Center(
                        child: LoadingView()
                    ),
                  );
                } else {
                  bonosList = _bonosUtils.documentsToBonos(snapshot.data!.docs, orderBonoSelectedNumber);
                  if (bonosList.isNotEmpty) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          Bono bono = bonosList[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.width * 0.04),
                            child: returnBono(bono),
                          );
                        },
                        childCount: bonosList.length,
                      ),
                    );
                  } else {
                    return SliverFillRemaining(
                      hasScrollBody: true,
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
                            AppLocalizations.of(context)!.noData,
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.12),
                        ],
                      ),
                    );
                  }
                }
              })
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: MediaQuery.of(context).size.width*0.15,
          width: MediaQuery.of(context).size.width*0.15,
          child: FloatingActionButton(
            onPressed: () {
              navigateToAddBonosScreen(
                Bono(color: "0", isActive: true, classes: 0, opacity: 1, imageUrl: '', isDegradate: false,),
                brand,
                false
              );
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.add, color: AppColors.white),
          ),
        )
      ),
    );
  }

  // Navigate to Bonos Request Screen
  void navigateToBonosRequestScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => BonosRequests(
            brandId: widget.brandId,
          ),
        ));
  }

  // Navigate to Add Bonos
  void navigateToAddBonosScreen(Bono bono, Brand _brand, bool edit) {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: AddEditBono(
              brand: _brand,
              bono: bono,
              edit: edit,
            ),
          ),
        ));
  }
}
