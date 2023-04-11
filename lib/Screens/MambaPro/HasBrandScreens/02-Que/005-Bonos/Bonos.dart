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
  bool canEdit = false;
  // Number Request
  int requests = 0;
  // Bonos list
  List<Bono> bonosList = [];
  final _bonosUtils = BonosUtils();
  // Boolean Loading
  bool isFirstBuild = true;
  bool isDark = false;

  // Filtrar bonos
  bool hasFilter = false;
  List<bool> filterByBonos = [true, true];

  int filterBonosNumber = 0;
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
    canEdit = currentUser.brandRole < 3 ? true : false;
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
    mixpanel!.track('brand_bonos_confirmation_requests');
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
        onlyView: !canEdit,
      ),
    );
  }

  String returnFilteredActiveBonosString() {
    String activeStaff = "";
    int cnt = 0;
    if (filterByBonos[0]) {
      activeStaff += AppLocalizations.of(context)!.yes+", ";
      cnt += 1;
    }
    if (filterByBonos[1]) {
      activeStaff += AppLocalizations.of(context)!.no;
      cnt += 1;
    }
    if (cnt == 1) {
      return activeStaff.split(", ")[0];
    }
    return activeStaff;
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
            floating: false,
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
                          SizedBox(
                            height: MediaQuery.of(context).size.width*0.09,
                            width: MediaQuery.of(context).size.width*0.09,
                            child: ClipOval(
                              child: Material(
                                color: hasFilter ? AppColors.white : Colors.transparent, // Button color
                                child: InkWell(
                                  splashColor: Theme.of(context).backgroundColor, // Splash color
                                  onTap: () async {
                                    mixpanel!.track('brand_bonos_filter_button');
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
                                        // Page View Controller
                                        final PageController _pageController = PageController(initialPage: 0);
                                        int _currentPage = 0;
                                        // Widget
                                        return StatefulBuilder(
                                          builder: (BuildContext context, StateSetter setStateBottom) {
                                            return FractionallySizedBox(
                                              heightFactor: 0.25,
                                              child: SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.5,
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
                                                        trailing: TextButton(
                                                          child: Text(
                                                              AppLocalizations.of(context)!.clear,
                                                              style: Theme.of(context).textTheme.caption
                                                          ),
                                                          onPressed: () {
                                                            mixpanel!.track('brand_bonos_filter_clean');
                                                            setStateBottom(() {
                                                              filterByBonos[0] = true;
                                                              filterByBonos[1] = true;
                                                            });
                                                            // Navigator Pop
                                                            Navigator.pop(context);
                                                          },
                                                        ),
                                                        dense: true,
                                                        onTap: _currentPage == 0 ? null : () {
                                                          mixpanel!.track('brand_bonos_filter_back');
                                                          _pageController.previousPage(
                                                            duration: const Duration(milliseconds: 500),
                                                            curve: Curves.ease,
                                                          );
                                                        },
                                                      ),
                                                      SizedBox(
                                                        height: MediaQuery.of(context).size.height * 0.15,
                                                        width: MediaQuery.of(context).size.width,
                                                        child: PageView(
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          controller: _pageController,
                                                          onPageChanged: (int page) {
                                                            setStateBottom(() {
                                                              _currentPage = page;
                                                            });
                                                          },
                                                          children: <Widget>[
                                                            Column(
                                                              children: [
                                                                ListTile(
                                                                  onTap: () {
                                                                    mixpanel!.track('brand_bonos_filter_active');
                                                                    _pageController.nextPage(
                                                                      duration: const Duration(milliseconds: 500),
                                                                      curve: Curves.ease,
                                                                    );
                                                                  },
                                                                  title: Text(
                                                                      AppLocalizations.of(context)!.bono+" "+AppLocalizations.of(context)!.active+"s",
                                                                      style: Theme.of(context).textTheme.bodyText1,
                                                                      textAlign: TextAlign.left
                                                                  ),
                                                                  subtitle: Text(
                                                                      returnFilteredActiveBonosString(),
                                                                      style: Theme.of(context).textTheme.caption,
                                                                      textAlign: TextAlign.left
                                                                  ),
                                                                  trailing: SizedBox(
                                                                    width: MediaQuery.of(context).size.width * 0.15,
                                                                    child: Center(
                                                                        child: Icon(Icons.arrow_forward_ios, size:MediaQuery.of(context).size.width * 0.04,color: AppColors.grey)
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                ListTile(
                                                                  onTap: () {
                                                                    // Check if the Only True
                                                                    var filterActive = List.from(filterByBonos);
                                                                    filterActive.retainWhere((element) => element == true);
                                                                    if (!(filterActive.length == 1 && filterByBonos[0])) {
                                                                      filterByBonos[0] = !filterByBonos[0];
                                                                      mixpanel!.track('brand_bonos_filter_active', properties: {'Values': [filterByBonos[0] ? 'Yes' : ' ', filterByBonos[1] ? 'No' : ' ' ]});
                                                                      // Navigator Pop
                                                                      Navigator.pop(context);
                                                                    }
                                                                  },
                                                                  title: Text(
                                                                      AppLocalizations.of(context)!.yes,
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
                                                                    // Check if the Only True
                                                                    var filterActive = List.from(filterByBonos);
                                                                    filterActive.retainWhere((element) => element == true);
                                                                    if (!(filterActive.length == 1 && filterByBonos[1])) {
                                                                      filterByBonos[1] = !filterByBonos[1];
                                                                      mixpanel!.track('brand_bonos_filter_active', properties: {'Values': [filterByBonos[0] ? 'Yes' : ' ', filterByBonos[1] ? 'No' : ' ' ]});
                                                                      // Navigator Pop
                                                                      Navigator.pop(context);
                                                                    }

                                                                  },
                                                                  title: Text(
                                                                      AppLocalizations.of(context)!.no,
                                                                      style: Theme.of(context).textTheme.bodyText1,
                                                                      textAlign: TextAlign.left
                                                                  ),
                                                                  trailing: filterByBonos[1] ? SizedBox(
                                                                    width: MediaQuery.of(context).size.width * 0.15,
                                                                    child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                                  ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
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
                                          hasFilter = false;
                                          filterBonosNumber = 0;
                                        } else if (filterByBonos[0]) {
                                          // Active Selected
                                          filterBonosNumber = 1;
                                          hasFilter = true;
                                        } else if(filterByBonos[1]) {
                                          // Inactive Selected
                                          filterBonosNumber = 2;
                                          hasFilter = true;
                                        } else {
                                          // None Selected
                                          filterBonosNumber = 3;
                                        }
                                      });
                                    });
                                  },
                                  child: SizedBox(width: MediaQuery.of(context).size.width*0.09, height: MediaQuery.of(context).size.width*0.09, child: Icon(
                                    Icons.filter_list,
                                    color: hasFilter ? AppColors.darkGrey :  AppColors.white,
                                    size: MediaQuery.of(context).size.width*0.07,
                                  )),
                                ),
                              ),
                            ),
                          ),
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
                    if (widget.pinned == true) {
                      mixpanel!.track('brand_bonos_pinned_off');
                    } else {
                      mixpanel!.track('brand_bonos_pinned_on');
                    }
                    setState(() {
                      widget.pinned = !widget.pinned;
                    });
                    widget.pinnedChanged(widget.pinned);
                  },
                ),
              ),
            ],
          ),
          canEdit ? SliverToBoxAdapter(
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
                          Flexible(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.confirmation_number_outlined,
                                  color: Theme.of(context).colorScheme.secondary,
                                  size: MediaQuery.of(context).size.width*0.10,
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width*0.05),
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.purchaseHistory,
                                        style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.start,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.bonoRequestDescription,
                                        style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondary),
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
          ) : SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).size.height*0.0),
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
      floatingActionButton: canEdit ? Padding(
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
      ) : Container(),
    );
  }

}
