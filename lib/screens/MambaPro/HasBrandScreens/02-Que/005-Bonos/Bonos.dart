import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mamba/commons/managers/theme_manager.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/utils/Bonos/BonosUtils.dart';
import 'package:mamba/commons/widgets/Components/Badges/BetaBadge.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba/notifications/Unread/widgets/askSupport.dart';
import 'package:mamba/notifications/Unread/widgets/profileImage.dart';
import 'package:mamba/notifications/Unread/widgets/unreadChats.dart';
import 'package:mamba/notifications/Unread/widgets/unreadNotifications.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/AddEditBono.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:provider/provider.dart';
import 'package:mamba/commons/managers/language_manager.dart';

class BonosPro extends StatefulWidget {
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;

  BonosPro(
      {super.key,
      required this.brandId,
      required this.pinned,
      required this.pinnedChanged});

  @override
  _BonosProState createState() => _BonosProState();
}

class _BonosProState extends State<BonosPro> {
  // Screen Dimensions
  double safeAreaHeight = 0;
  double safeAreaWidth = 0;

  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    if (!_scrollController!.hasClients) {
      return false;
    }
    if (_scrollController!.position.userScrollDirection ==
        ScrollDirection.forward) {
      // User is down up, so AppBar should expand.
      return false;
    }
    // Use the same condition as before to check if AppBar is expanded.
    return _scrollController!.offset >
        (MediaQuery.of(context).size.height * 0.15 - kToolbarHeight);
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
  List<bool> filterByBonos = [true, true, true, true];

  int filterBonosNumber = 0;
  int filterTypeNumber = 0;
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
    safeAreaHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    isDark = context.read<ThemeManager>().isDarkMode;
    print(
        "Device H and W: ${MediaQuery.of(context).size.height} ${MediaQuery.of(context).size.width}");
    print("SafeArea H and W: $safeAreaHeight $safeAreaWidth");
  }

  // Navigate to Add Bonos
  Future<void> navigateToAddBonosScreen(
      Bono bono, Brand brand, bool edit) async {
    if (!brandIsActive) {
      await navigateToPayWall(context);
    } else {
      await Navigator.push(
          context,
          CupertinoPageRoute<void>(
            builder: (context) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              child: AddEditBono(
                brand: brand,
                bono: bono,
                edit: edit,
                duplicate: false,
                delete: false,
              ),
            ),
          )).whenComplete(() => () {
            setState(() {});
          });
    }
  }

  Widget returnBono(Bono bono) {
    //return _bonosUtils.bonoObject(context, _bono, brand, _lColor);
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: BonoCard(
        height: MediaQuery.of(context).size.height * 0.22,
        width: MediaQuery.of(context).size.width * 0.9,
        bono: bono,
        brand: currentBrand,
        canExpand: true,
        onlyView: !canEdit,
      ),
    );
  }

  String returnFilteredTypeRateString() {
    String filteredRates = "";
    int cnt = 0;
    if (filterByBonos[2]) {
      filteredRates += "${context.l10n.membership}, ";
      cnt += 1;
    }
    if (filterByBonos[3]) {
      filteredRates += "${context.l10n.bono}, ";
      cnt += 1;
    }
    if (cnt == 1) {
      return filteredRates.split(", ")[0];
    }
    if (cnt == 2) {
      return "${filteredRates.split(", ")[0]}, ${filteredRates.split(", ")[1]}";
    }
    return filteredRates;
  }

  String returnFilteredActiveBonosString() {
    String activeStaff = "";
    int cnt = 0;
    if (filterByBonos[0]) {
      activeStaff += "${context.l10n.yes}, ";
      cnt += 1;
    }
    if (filterByBonos[1]) {
      activeStaff += context.l10n.no;
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
            surfaceTintColor: AppColors.darkGrey,
            backgroundColor: AppColors.darkGrey,
            expandedHeight: MediaQuery.of(context).size.height * 0.15,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 4,
            floating: true,
            pinned: true,
            title: AnimatedOpacity(
                opacity: appBarExpanded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(context.l10n.rates,
                    style:
                        Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                              color: AppColors.white,
                            ))),
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
                            context.l10n.rates,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  color: AppColors.white,
                                ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.08,
                            width: MediaQuery.of(context).size.width * 0.40,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.09,
                            width: MediaQuery.of(context).size.width * 0.09,
                            child: ClipOval(
                              child: Material(
                                color: hasFilter
                                    ? AppColors.white
                                    : Colors.transparent, // Button color
                                child: InkWell(
                                  splashColor: Theme.of(context)
                                      .colorScheme
                                      .background, // Splash color
                                  onTap: () async {
                                    mixpanel!
                                        .track('brand_bonos_filter_button');
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
                                        final PageController pageController =
                                            PageController(initialPage: 0);
                                        int currentPage = 0;
                                        bool isTypeRate = true;
                                        // Widget
                                        return StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setStateBottom) {
                                            return FractionallySizedBox(
                                              heightFactor: 0.33,
                                              child: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.5,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
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
                                                            context
                                                                .l10n.filterBy,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall,
                                                            textAlign:
                                                                TextAlign.left),
                                                        trailing: TextButton(
                                                          child: Text(
                                                              context
                                                                  .l10n.clear,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall),
                                                          onPressed: () {
                                                            mixpanel!.track(
                                                                'brand_bonos_filter_clean');
                                                            setStateBottom(() {
                                                              filterByBonos[0] =
                                                                  true;
                                                              filterByBonos[1] =
                                                                  true;
                                                              filterByBonos[2] =
                                                                  true;
                                                              filterByBonos[3] =
                                                                  true;
                                                            });
                                                            // Navigator Pop
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        dense: true,
                                                        onTap: currentPage == 0
                                                            ? null
                                                            : () {
                                                                mixpanel!.track(
                                                                    'brand_bonos_filter_back');
                                                                pageController
                                                                    .previousPage(
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  curve: Curves
                                                                      .ease,
                                                                );
                                                              },
                                                      ),
                                                      SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.21,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: PageView(
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          controller:
                                                              pageController,
                                                          onPageChanged:
                                                              (int page) {
                                                            setStateBottom(() {
                                                              currentPage =
                                                                  page;
                                                            });
                                                          },
                                                          children: <Widget>[
                                                            Column(
                                                              children: [
                                                                ListTile(
                                                                  onTap: () {
                                                                    mixpanel!.track(
                                                                        'brand_bonos_filter_type');
                                                                    setStateBottom(
                                                                        () {
                                                                      isTypeRate =
                                                                          true;
                                                                    });
                                                                    pageController
                                                                        .nextPage(
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              500),
                                                                      curve: Curves
                                                                          .ease,
                                                                    );
                                                                  },
                                                                  title: Text(
                                                                      context
                                                                          .l10n
                                                                          .typeRate,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyLarge,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left),
                                                                  subtitle: Text(
                                                                      returnFilteredTypeRateString(),
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodySmall,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left),
                                                                  trailing:
                                                                      SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.15,
                                                                    child: Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .arrow_forward_ios,
                                                                            size: MediaQuery.of(context).size.width *
                                                                                0.04,
                                                                            color:
                                                                                AppColors.grey)),
                                                                  ),
                                                                ),
                                                                ListTile(
                                                                  onTap: () {
                                                                    mixpanel!.track(
                                                                        'brand_bonos_filter_active');
                                                                    setStateBottom(
                                                                        () {
                                                                      isTypeRate =
                                                                          false;
                                                                    });
                                                                    pageController
                                                                        .nextPage(
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              500),
                                                                      curve: Curves
                                                                          .ease,
                                                                    );
                                                                  },
                                                                  title: Text(
                                                                      "${context.l10n.rates} ${context.l10n.disponible.toLowerCase()}s",
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyLarge,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left),
                                                                  subtitle: Text(
                                                                      returnFilteredActiveBonosString(),
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodySmall,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left),
                                                                  trailing:
                                                                      SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.15,
                                                                    child: Center(
                                                                        child: Icon(
                                                                            Icons
                                                                                .arrow_forward_ios,
                                                                            size: MediaQuery.of(context).size.width *
                                                                                0.04,
                                                                            color:
                                                                                AppColors.grey)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            isTypeRate
                                                                ? Column(
                                                                    children: [
                                                                      ListTile(
                                                                        onTap:
                                                                            () {
                                                                          // Check if the Only True
                                                                          var filterActive =
                                                                              List.from(filterByBonos.sublist(2));
                                                                          filterActive.retainWhere((element) =>
                                                                              element ==
                                                                              true);
                                                                          if (!(filterActive.length == 1 &&
                                                                              filterByBonos[2])) {
                                                                            filterByBonos[2] =
                                                                                !filterByBonos[2];
                                                                            // Navigator Pop
                                                                            Navigator.pop(context);
                                                                          }
                                                                        },
                                                                        title: Text(
                                                                            context
                                                                                .l10n.membership,
                                                                            style:
                                                                                Theme.of(context).textTheme.bodyLarge,
                                                                            textAlign: TextAlign.left),
                                                                        trailing: filterByBonos[2]
                                                                            ? SizedBox(
                                                                                width: MediaQuery.of(context).size.width * 0.15,
                                                                                child: Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                              )
                                                                            : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                                      ),
                                                                      ListTile(
                                                                        onTap:
                                                                            () {
                                                                          // Check if the Only True
                                                                          var filterActive =
                                                                              List.from(filterByBonos.sublist(2));
                                                                          filterActive.retainWhere((element) =>
                                                                              element ==
                                                                              true);
                                                                          if (!(filterActive.length == 1 &&
                                                                              filterByBonos[3])) {
                                                                            filterByBonos[3] =
                                                                                !filterByBonos[3];
                                                                            // Navigator Pop
                                                                            Navigator.pop(context);
                                                                          }
                                                                        },
                                                                        title: Text(
                                                                            context
                                                                                .l10n.bono,
                                                                            style:
                                                                                Theme.of(context).textTheme.bodyLarge,
                                                                            textAlign: TextAlign.left),
                                                                        trailing: filterByBonos[3]
                                                                            ? SizedBox(
                                                                                width: MediaQuery.of(context).size.width * 0.15,
                                                                                child: Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                              )
                                                                            : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                                      ),
                                                                    ],
                                                                  )
                                                                : Column(
                                                                    children: [
                                                                      ListTile(
                                                                        onTap:
                                                                            () {
                                                                          // Check if the Only True
                                                                          var filterActive = List.from(filterByBonos.sublist(
                                                                              0,
                                                                              2));
                                                                          print(
                                                                              filterActive);
                                                                          filterActive.retainWhere((element) =>
                                                                              element ==
                                                                              true);
                                                                          if (!(filterActive.length == 1 &&
                                                                              filterByBonos[0])) {
                                                                            filterByBonos[0] =
                                                                                !filterByBonos[0];
                                                                            // Navigator Pop
                                                                            Navigator.pop(context);
                                                                          }
                                                                        },
                                                                        title: Text(
                                                                            context
                                                                                .l10n.yes,
                                                                            style:
                                                                                Theme.of(context).textTheme.bodyLarge,
                                                                            textAlign: TextAlign.left),
                                                                        trailing: filterByBonos[0]
                                                                            ? SizedBox(
                                                                                width: MediaQuery.of(context).size.width * 0.15,
                                                                                child: Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                              )
                                                                            : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                                      ),
                                                                      ListTile(
                                                                        onTap:
                                                                            () {
                                                                          // Check if the Only True
                                                                          var filterActive = List.from(filterByBonos.sublist(
                                                                              0,
                                                                              2));
                                                                          print(
                                                                              filterActive);
                                                                          filterActive.retainWhere((element) =>
                                                                              element ==
                                                                              true);
                                                                          if (!(filterActive.length == 1 &&
                                                                              filterByBonos[1])) {
                                                                            filterByBonos[1] =
                                                                                !filterByBonos[1];
                                                                            mixpanel!.track('brand_bonos_filter_active', properties: {
                                                                              'Values': [
                                                                                filterByBonos[0] ? 'Yes' : ' ',
                                                                                filterByBonos[1] ? 'No' : ' '
                                                                              ]
                                                                            });
                                                                            // Navigator Pop
                                                                            Navigator.pop(context);
                                                                          }
                                                                        },
                                                                        title: Text(
                                                                            context
                                                                                .l10n.no,
                                                                            style:
                                                                                Theme.of(context).textTheme.bodyLarge,
                                                                            textAlign: TextAlign.left),
                                                                        trailing: filterByBonos[1]
                                                                            ? SizedBox(
                                                                                width: MediaQuery.of(context).size.width * 0.15,
                                                                                child: Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                              )
                                                                            : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
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
                                          },
                                        );
                                      },
                                    ).whenComplete(() {
                                      setState(() {
                                        // Filter By Active or not Active
                                        if (filterByBonos[0] &&
                                            filterByBonos[1]) {
                                          // Active/Inactive Selected
                                          hasFilter = false;
                                          filterBonosNumber = 0;
                                        } else if (filterByBonos[0]) {
                                          // Active Selected
                                          filterBonosNumber = 1;
                                          hasFilter = true;
                                        } else if (filterByBonos[1]) {
                                          // Inactive Selected
                                          filterBonosNumber = 2;
                                          hasFilter = true;
                                        } else {
                                          // None Selected
                                          filterBonosNumber = 3;
                                        }
                                        // Filter By Type
                                        if (filterByBonos[2] &&
                                            filterByBonos[3]) {
                                          // Membresía/Bonos Selected
                                          hasFilter = false;
                                          filterTypeNumber = 0;
                                        } else if (filterByBonos[2]) {
                                          // Only Membresía Selected
                                          filterTypeNumber = 1;
                                          hasFilter = true;
                                        } else if (filterByBonos[3]) {
                                          // Only Bonos Selected
                                          filterTypeNumber = 2;
                                          hasFilter = true;
                                        } else {
                                          // None Selected
                                          filterTypeNumber = 3;
                                        }
                                      });
                                    });
                                  },
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.09,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.09,
                                      child: Icon(
                                        Icons.filter_list,
                                        color: hasFilter
                                            ? AppColors.darkGrey
                                            : AppColors.white,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.07,
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
            centerTitle: false,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  askSupport(context),
                  unreadNotifications(context),
                  unreadChats(context),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.025),
                  profileImage(context),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                ],
              ),
            ],
          ),
          /*
          canEdit
              ? SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      GestureDetector(
                        onTap: navigateToPurchaseHistoryScreen,
                        child: Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.05),
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.2),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.confirmation_number_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      size: MediaQuery.of(context).size.width *
                                          0.10,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    Flexible(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.l10n
                                                .purchaseHistory,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    fontWeight:
                                                        FontWeight.bold),
                                            textAlign: TextAlign.start,
                                          ),
                                          Text(
                                            context.l10n
                                                .bonoRequestDescription,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary),
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
                                  stream: _brandDataService
                                      .getBonosRequestsFromBrand(
                                          widget.brandId),
                                  builder: (context, snapshot) {
                                    if (snapshot.data == null) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.08,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.08,
                                        decoration: const BoxDecoration(
                                            color: context.colorScheme.secondary,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(0.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                              textAlign: TextAlign.center),
                                        ),
                                      );
                                    } else {
                                      requests = _bonosUtils
                                          .documentsToBonosRequests(
                                              snapshot.data!.docs)
                                          .length;
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.08,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.08,
                                        decoration: const BoxDecoration(
                                            color: context.colorScheme.secondary,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(requests.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                              textAlign: TextAlign.center),
                                        ),
                                      );
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Divider(
                          color: AppColors.grey,
                          thickness: 1,
                          indent: MediaQuery.of(context).size.width * 0.05,
                          endIndent: MediaQuery.of(context).size.width * 0.05),
                    ],
                  ),
                )
              : SliverToBoxAdapter(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.0),
                ),
          */
          StreamBuilder<QuerySnapshot>(
              stream: _brandDataService.getAllBonosFromBrand(widget.brandId),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return SliverFillRemaining(
                    hasScrollBody: true,
                    child: Center(
                        child: LoadingView(
                      hasLogo: false,
                    )),
                  );
                } else {
                  bonosList = _bonosUtils.documentsToBonos(
                      snapshot.data!.docs,
                      filterBonosNumber,
                      filterTypeNumber,
                      orderByBonosNumber,
                      alphabeticOrder);
                  if (bonosList.isNotEmpty) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          Bono bono = bonosList[index];
                          return Column(
                            children: [
                              index == 0
                                  ? SizedBox(
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.02)
                                  : Container(),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                child: returnBono(bono),
                              ),
                              index == bonosList.length - 1
                                  ? SizedBox(
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.1)
                                  : Container(),
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
                              child: Image.asset(Assets.emptyCalendar)),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005),
                          Text(
                            context.l10n.noData,
                            style: Theme.of(context).textTheme.bodySmall,
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
      floatingActionButton: whichFloatingActionButton(),
      /*
          Padding(
              padding: Platform.isAndroid
                  ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10)
                  : const EdgeInsets.all(10),
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.15,
                width: MediaQuery.of(context).size.width * 0.15,
                child: FloatingActionButton(
                  onPressed: () {
                    navigateToAddBonosScreen(
                        Bono(
                          color: "0",
                          isActive: true,
                          sessions: 0,
                          opacity: 1,
                          imageUrl: '',
                          isDegradate: false,
                        ),
                        currentBrand,
                        false);
                  },
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: const Icon(
                    Icons.add,
                    color: AppColors.white,
                  ),
                ),
              ))
          : Container(), */
    );
  }

  Widget whichFloatingActionButton() {
    return canEdit
        ? Padding(
            padding: Platform.isAndroid
                ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10)
                : const EdgeInsets.all(10),
            child: SizedBox(
              height: MediaQuery.of(context).size.width * 0.15,
              width: MediaQuery.of(context).size.width * 0.15,
              child: SpeedDial(
                heroTag: "46",
                activeChild: const Icon(Icons.confirmation_number_outlined),
                animationDuration: const Duration(milliseconds: 300),
                foregroundColor: AppColors.white,
                overlayColor: Theme.of(context).scaffoldBackgroundColor,
                overlayOpacity: 0.95,
                spacing: MediaQuery.of(context).size.height * 0.02,
                spaceBetweenChildren: MediaQuery.of(context).size.height * 0.02,
                openCloseDial: isDialOpen,
                children: [
                  SpeedDialChild(
                      child: const Icon(
                        Icons.repeat,
                      ),
                      elevation: 10,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      labelWidget: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.05),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const BetaBadge(),
                                Text(context.l10n.bonoRecurrent,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                    textAlign: TextAlign.right),
                              ],
                            ),
                            Text(context.l10n.bonoRecurrentText,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.right),
                          ],
                        ),
                      ),
                      onTap: () {
                        navigateToAddBonosScreen(
                            Bono(
                              color: "0",
                              isActive: true,
                              sessions: 0,
                              opacity: 1,
                              imageUrl: '',
                              isDegradate: false,
                              isRecurrent: true,
                            ),
                            currentBrand,
                            false);
                      }),
                  SpeedDialChild(
                      child: const Icon(
                        FontAwesomeIcons.one,
                        size: 20,
                      ),
                      elevation: 10,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      labelWidget: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.05),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(context.l10n.bonoSimple,
                                style: Theme.of(context).textTheme.displaySmall,
                                textAlign: TextAlign.right),
                            Text(context.l10n.bonoSimpleText,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.right),
                          ],
                        ),
                      ),
                      onTap: () {
                        navigateToAddBonosScreen(
                            Bono(
                              color: "0",
                              isActive: true,
                              sessions: 0,
                              opacity: 1,
                              imageUrl: '',
                              isDegradate: false,
                              isRecurrent: false,
                            ),
                            currentBrand,
                            false);
                      }),
                ],
                child: const Icon(Icons.add),
              ),
            ),
          )
        : Container();
  }
}
