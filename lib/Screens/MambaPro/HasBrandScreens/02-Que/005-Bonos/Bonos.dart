import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/AddEditBono.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../Globals/GlobalVars.dart';
import '../../../../../../Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
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
  // Screen Dimensions
  double safeAreaHeight = 0;
  double safeAreaWidth = 0;
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height * 0.15 - kToolbarHeight);
  }
  // Brand Service
  final _brandDataService = BrandDataService();
  // Boolean Loading
  bool isLoading = true;
  // Number Request
  int requests = 0;
  // Bonos list
  List<Bono> bonosList = [];
  final _bonosUtils = BonosUtils();
  // Boolean Loading
  bool isFirstBuild = true;
  bool isDark = false;
  // Filtrar bonos
  int filterBonosNumber = 0;
  List<bool> filterByBonos = [true, false];
  // Ordernar bonos
  int orderByBonosNumber = 0;
  int alphabeticOrder = 0;
  List<bool> orderByBonos = [true, false, true, false];



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
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    print("Device H and W: " + MediaQuery.of(context).size.height.toString() + " " + MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: " + safeAreaHeight.toString() + " " + safeAreaWidth.toString());
  }

  // Navigate to Bonos Request Screen
  void navigateToBonosRequestScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => BonosRequests(
            brandId: widget.brandId,
          ),
        )
    );
  }

  // Navigate to Add Bonos
  Future<void> navigateToAddBonosScreen(Bono bono, Brand _brand, bool edit) async {
    await Navigator.push(
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
        )).whenComplete(() => () {
      setState(() {

      });
    });
  }

  Widget returnBono(Bono _bono) {
    //return _bonosUtils.bonoObject(context, _bono, brand, _lColor);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
      child: BonoCard(
        height: MediaQuery.of(context).size.height*0.22,
        width: MediaQuery.of(context).size.width*0.9,
        bono: _bono,
        brand: currentBrand,
        canExpand: true,
        onlyView: false,
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
                          FittedBox(
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.08,
                              width: MediaQuery.of(context).size.width * 0.11,
                              child: TextButton(
                                onPressed: () async {
                                  await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setStateBottom) {
                                          return FractionallySizedBox(
                                            heightFactor: 0.45,
                                            child: SizedBox(height: MediaQuery.of(context).size.height * 0.5,
                                              width: MediaQuery.of(context).size.width,
                                              child: Padding(
                                                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
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
                                                      onTap: () {
                                                        setStateBottom(() {
                                                          filterByBonos[0] = !filterByBonos[0];
                                                        });
                                                        // Navigator Pop
                                                        Navigator.pop(context);
                                                      },
                                                      title: Text(
                                                          AppLocalizations.of(context)!.activeBono,
                                                          style: Theme.of(context).textTheme.bodyText1,
                                                          textAlign: TextAlign.left
                                                      ),
                                                      trailing: filterByBonos[0] ? SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.15,
                                                        child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                      ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        setStateBottom(() {
                                                          filterByBonos[1] = !filterByBonos[1];
                                                        });
                                                        // Navigator Pop
                                                        Navigator.pop(context);
                                                      },
                                                      title: Text(
                                                          AppLocalizations.of(context)!.desactiveBono,
                                                          style: Theme.of(context).textTheme.bodyText1,
                                                          textAlign: TextAlign.left
                                                      ),
                                                      trailing: filterByBonos[1] ? SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.15,
                                                        child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                      ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                    ),

                                                    ListTile(
                                                      title: Text(
                                                          AppLocalizations.of(context)!.orderBy,
                                                          style: Theme.of(context).textTheme.caption,
                                                          textAlign: TextAlign.left
                                                      ),
                                                      dense: true,
                                                    ),

                                                    ListTile(
                                                      onTap: () {
                                                        setStateBottom(() {
                                                          orderByBonos[0] = !orderByBonos[0];
                                                          orderByBonos[1] = !orderByBonos[1];
                                                        });
                                                        // Navigator Pop
                                                        Navigator.pop(context);
                                                      },
                                                      title: Text(
                                                          AppLocalizations.of(context)!.alphabetAtoZ,
                                                          style: Theme.of(context).textTheme.bodyText1,
                                                          textAlign: TextAlign.left
                                                      ),
                                                      trailing: orderByBonos[0] ? SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.15,
                                                        child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                      ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        setStateBottom(() {
                                                          orderByBonos[1] = !orderByBonos[1];
                                                          orderByBonos[0] = !orderByBonos[0];
                                                        });
                                                        // Navigator Pop
                                                        Navigator.pop(context);
                                                      },
                                                      title: Text(
                                                          AppLocalizations.of(context)!.alphabetZtoA,
                                                          style: Theme.of(context).textTheme.bodyText1,
                                                          textAlign: TextAlign.left
                                                      ),
                                                      trailing: orderByBonos[1] ? SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.15,
                                                        child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                      ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                    ),
                                                    /*
                                                    ListTile(
                                                      onTap: () {
                                                        setStateBottom(() {
                                                          orderByBonos[2] = !orderByBonos[2];
                                                          orderByBonos[3] = !orderByBonos[3];
                                                        });
                                                      },
                                                      title: Text(
                                                          AppLocalizations.of(context)!.activeBono+" "+AppLocalizations.of(context)!.first.toLowerCase(),
                                                          style: Theme.of(context).textTheme.bodyText1,
                                                          textAlign: TextAlign.left
                                                      ),
                                                      trailing: orderByBonos[2] ? SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.15,
                                                        child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                      ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        setStateBottom(() {
                                                          orderByBonos[3] = !orderByBonos[3];
                                                          orderByBonos[2] = !orderByBonos[2];
                                                        });
                                                      },
                                                      title: Text(
                                                          AppLocalizations.of(context)!.desactiveBono+" "+AppLocalizations.of(context)!.first.toLowerCase(),
                                                          style: Theme.of(context).textTheme.bodyText1,
                                                          textAlign: TextAlign.left
                                                      ),
                                                      trailing: orderByBonos[3] ? SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.15,
                                                        child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                      ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                    ),
                                                     */
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        } ,
                                      );
                                    },
                                  ).whenComplete(() {
                                    setState(() {
                                      // Filter By
                                      if (filterByBonos[0] && filterByBonos[1]) {
                                        // Active/Inactive Selected
                                        filterBonosNumber = 0;
                                      } else if (filterByBonos[0]) {
                                        // Active Selected
                                        filterBonosNumber = 1;
                                      } else if(filterByBonos[1]) {
                                        // Inactive Selected
                                        filterBonosNumber = 2;
                                      } else {
                                        // None Selected
                                        filterBonosNumber = 3;
                                      }
                                      // OrderBy
                                      if (orderByBonos[0]) {
                                        // A-Z
                                        alphabeticOrder = 0;
                                      } else {
                                        // Z-A
                                        alphabeticOrder = 1;
                                      }
                                      if (orderByBonos[2]) {
                                        // Active First
                                        orderByBonosNumber = 0;
                                      } else {
                                        // InActive First
                                        orderByBonosNumber = 1;
                                      }
                                    });
                                  });
                                },
                                child: Icon(
                                  Icons.filter_list,
                                  color: AppColors.white,
                                  size: MediaQuery.of(context).size.width * 0.07,
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
          SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.03),
                  GestureDetector(
                    onTap: navigateToBonosRequestScreen,
                    child: Container(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.05),
                      height: MediaQuery.of(context).size.height*0.1,
                      width: MediaQuery.of(context).size.width*0.9,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: MediaQuery.of(context).size.width*0.10,
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width*0.05),
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context)!.bonoRequestDescription,
                              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondary),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width*0.05),
                          StreamBuilder<QuerySnapshot>(
                              stream: _brandDataService.getBonosRequestsFromBrand(widget.brandId),
                              builder: (context, snapshot) {
                                if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null) {
                                  return Container(
                                    height: MediaQuery.of(context).size.width * 0.08,
                                    width: MediaQuery.of(context).size.width * 0.08,
                                    decoration: const BoxDecoration(
                                        color: AppColors.mainColor,
                                        borderRadius: BorderRadius.all(Radius.circular(20))
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          0.toString(),
                                          style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                                          textAlign: TextAlign.center
                                      ),
                                    ),
                                  );
                                } else {
                                  requests = _bonosUtils.documentsToBonosRequests(snapshot.data!.docs).length;
                                  return Container(
                                    height: MediaQuery.of(context).size.width * 0.08,
                                    width: MediaQuery.of(context).size.width * 0.08,
                                    decoration: const BoxDecoration(
                                        color: AppColors.mainColor,
                                        borderRadius: BorderRadius.all(Radius.circular(20))
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          requests.toString(),
                                          style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                                          textAlign: TextAlign.center
                                      ),
                                    ),
                                  );
                                }
                              }
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Divider(color: Theme.of(context).backgroundColor, thickness: 2, indent: MediaQuery.of(context).size.width*0.05, endIndent: MediaQuery.of(context).size.width*0.05),
                ],
              ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: _brandDataService.getAllBonosFromBrand(widget.brandId),
              builder: (context, snapshot) {
                if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null) {
                  return SliverFillRemaining(
                    hasScrollBody: true,
                    child: Center(
                        child: LoadingView(
                          hasLogo: false,
                        )
                    ),
                  );
                } else {
                  bonosList = _bonosUtils.documentsToBonos(snapshot.data!.docs, filterBonosNumber, orderByBonosNumber, alphabeticOrder);
                  if (bonosList.isNotEmpty) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          Bono bono = bonosList[index];
                          return Column(
                            children: [
                              index == 0 ? SizedBox(height: MediaQuery.of(context).size.width * 0.04) : Container(),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.04),
                                child: returnBono(bono),
                              ),
                              index == bonosList.length-1 ? SizedBox(height: MediaQuery.of(context).size.width * 0.1) : Container(),
                            ],
                          );
                        },
                        childCount: bonosList.length,
                      ),
                    );
                  } else {
                    return SliverFillRemaining(
                      hasScrollBody: false,
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
                Bono(color: "0", isActive: true, sessions: 0, opacity: 1, imageUrl: '', isDegradate: false,),
                currentBrand,
                false
              );
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.add, color: AppColors.white,),
          ),
        )
      ),
    );
  }

}
