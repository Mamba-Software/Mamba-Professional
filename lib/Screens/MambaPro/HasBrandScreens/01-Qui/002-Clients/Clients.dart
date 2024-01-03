import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mamba_castelldefels/Data/DataService/Room/RoomDataService.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/Chat.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/BetaBadge.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/ClientSessions/cubit/ClientsSessionsCubit.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/RegisterBrandMember.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/ShareBrandLink.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mamba_castelldefels/Notifications/Unread/widgets/unreadChats.dart';
import 'package:mamba_castelldefels/Notifications/Unread/widgets/unreadNotifications.dart';

class Clients extends StatefulWidget {
  String brandId;
  int numClients;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;

  Clients(
      {super.key,
      required this.brandId,
      required this.numClients,
      required this.pinned,
      required this.pinnedChanged});

  @override
  _Clients createState() => _Clients();
}

class _Clients extends State<Clients> {
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

  // Brand Data Service
  final _roomDataService = RoomDataService();
  final _dynamicLinkUtils = DynamicLinkUtils();
  // Boolean Loading
  bool isLoading = false;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  // Search Controller
  bool searchClicked = false;
  String query = "";
  var searchController = TextEditingController();

  String brandUrlClient = "";

  // Members Page
  List<Usuario> allMembers = [];
  List<Usuario> filteredMembers = [];

  // Filters
  bool hasFilter = false;
  bool hasOrder = false;

  int it = -1;

  List<bool> filterByClients = [true, true];
  List<bool> orderBySessions = [false, false];

  Future<void> getBrandLink() async {
    Uri brandUriClient = await _dynamicLinkUtils.createDynamicLinkWithIdClient(
        currentBrand.id!, currentBrand.logoUrl!, currentBrand.name!);
    setState(() {
      brandUrlClient = brandUriClient.toString();
    });
  }

  void filterSearchResults(String value, dynamic state, bool comesFromBottom) {
    if (!orderBySessions[0] &&
        !orderBySessions[1] &&
        filterByClients[0] &&
        filterByClients[1]) {
      hasFilter = false;
      hasOrder = false;
    }
    if (state is ClientsSessionsLoaded) {
      context.read<ClientSessionsCubit>().filterSearchResults(
          value,
          filterByClients,
          orderBySessions,
          state.usersNow,
          state.allUsers,
          state.filteredUsers,
          state.searchedUsers,
          state.i,
          state.finished);
    }
    if (comesFromBottom) {
      Navigator.pop(context);
    }
  }

  void orderBySessionsFunc(bool reverse) {
    // Filter By
    if (!reverse) {
      filteredMembers.sort((a, b) {
        // Handling null cases
        if (a.sessions == null && b.sessions == null) {
          return 0; // Both are null, so they are equal
        } else if (a.sessions == null) {
          return 1; // a.sessions is null, so a should come after b
        } else if (b.sessions == null) {
          return -1; // b.sessions is null, so b should come after a
        }

        // Compare sessions as integers
        int aSessions = int.parse(a.sessions!);
        int bSessions = int.parse(b.sessions!);
        return bSessions.compareTo(aSessions);
      });
    } else {
      filteredMembers.sort((a, b) {
        // Handling null cases
        if (a.sessions == null && b.sessions == null) {
          return 0; // Both are null, so they are equal
        } else if (b.sessions == null) {
          return 1; // a.sessions is null, so a should come after b
        } else if (a.sessions == null) {
          return -1; // b.sessions is null, so b should come after a
        }

        // Compare sessions as integers
        int aSessions = int.parse(a.sessions!);
        int bSessions = int.parse(b.sessions!);
        return aSessions.compareTo(bSessions);
      });
    }
    setState(() {
      hasOrder = true;
    });
    // Navigator Pop
    Navigator.pop(context);
  }

  String returnFilteredActiveClientsString() {
    String activeStaff = "";
    int cnt = 0;
    if (filterByClients[0]) {
      activeStaff += "${AppLocalizations.of(context)!.yes}, ";
      cnt += 1;
    }
    if (filterByClients[1]) {
      activeStaff += AppLocalizations.of(context)!.no;
      cnt += 1;
    }
    if (cnt == 1) {
      return activeStaff.split(", ")[0];
    }
    return activeStaff;
  }

  String returnFilteredOrderClientsString() {
    String activeStaff = "";
    if (orderBySessions[0]) {
      activeStaff += AppLocalizations.of(context)!.orderBySessionsMoreToLess;
    }
    if (orderBySessions[1]) {
      activeStaff += AppLocalizations.of(context)!.orderBySessionsLessToMore;
    }
    return activeStaff;
  }

  @override
  initState() {
    context.read<ClientSessionsCubit>().loadList();
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
    isLoading = true;
    getBrandLink();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientSessionsCubit, ClientsSessionsState>(
        builder: (context, state) {
      if (state is ClientsSessionsLoaded) {
        if (!state.finished) {
          if (state.i != it) {
            context.read<ClientSessionsCubit>().updateClientSessions(
                query,
                filterByClients,
                orderBySessions,
                state.usersNow,
                state.allUsers,
                state.filteredUsers,
                state.searchedUsers,
                state.i,
                state.finished);
            it = state.i;
          }
        }
      }
      return Scaffold(
        backgroundColor: Colors.transparent,
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
              snap: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: double.infinity,
                  color: AppColors.darkGrey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05,
                            right: MediaQuery.of(context).size.width * 0.03),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            searchClicked == false
                                ? Text(
                                    AppLocalizations.of(context)!.clients,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          color: AppColors.white,
                                        ),
                                  )
                                : SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.65,
                                    child: TextField(
                                      autofocus: true,
                                      controller: searchController,
                                      onChanged: (value) {
                                        query = value;
                                        filterSearchResults(
                                            query, state, false);
                                      },
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColors.white),
                                      textAlign: TextAlign.left,
                                      decoration: InputDecoration(
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        hintText: AppLocalizations.of(context)!
                                            .search,
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.grey),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.grey),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.grey),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            mixpanel!.track(
                                                'brand_clients_search_clean');
                                            searchController.clear();
                                            query = "";
                                            filterSearchResults(
                                                query, state, false);
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04),
                                      ),
                                    ),
                                  ),
                            FittedBox(
                              fit: BoxFit.fitWidth,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.23,
                                /*
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green, width: 1.0),
                                color: Colors.transparent,
                              ),
                               */
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Material(
                                      color: Colors.transparent,
                                      child: IconButton(
                                        onPressed: () {
                                          if (searchClicked == false) {
                                            mixpanel!.track(
                                                'brand_clients_search_button');
                                          } else {
                                            mixpanel!.track(
                                                'brand_clients_search_close');
                                          }
                                          setState(() {
                                            searchClicked = !searchClicked;
                                            if (searchClicked == false) {
                                              searchController.clear();
                                              query = "";
                                              filterSearchResults(
                                                  query, state, false);
                                            }
                                          });
                                        },
                                        splashRadius: 20,
                                        splashColor: Theme.of(context)
                                            .colorScheme
                                            .background, // Splash color
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.center,
                                        icon: Icon(
                                          searchClicked == false
                                              ? Icons.search_outlined
                                              : Icons.close_outlined,
                                          color: AppColors.white,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07,
                                        ),
                                      ),
                                    ),
                                    ClipOval(
                                      child: Material(
                                        color: hasOrder || hasFilter
                                            ? AppColors.white
                                            : Colors
                                                .transparent, // Button color
                                        child: InkWell(
                                          splashColor: Theme.of(context)
                                              .colorScheme
                                              .background, // Splash color
                                          onTap: () async {
                                            mixpanel!.track(
                                                'brand_clients_filter_button');
                                            await showModalBottomSheet<int?>(
                                              context: context,
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                ),
                                              ),
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              builder: (BuildContext context) {
                                                // Page View Controller
                                                final PageController
                                                    pageController =
                                                    PageController(
                                                        initialPage: 0);
                                                int currentPage = 0;
                                                bool isFilterBy = true;
                                                // Widget
                                                return StatefulBuilder(
                                                  builder:
                                                      (BuildContext context,
                                                          StateSetter
                                                              setStateBottom) {
                                                    return FractionallySizedBox(
                                                      heightFactor: 0.4,
                                                      child: SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .all(MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.02),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              ListTile(
                                                                title: Text(
                                                                    isFilterBy ==
                                                                            false
                                                                        ? AppLocalizations.of(context)!
                                                                            .orderBy
                                                                        : AppLocalizations.of(context)!
                                                                            .filterBy,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodySmall,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left),
                                                                trailing:
                                                                    TextButton(
                                                                        child: Text(
                                                                            AppLocalizations.of(context)!
                                                                                .clear,
                                                                            style: Theme.of(context)
                                                                                .textTheme
                                                                                .bodySmall),
                                                                        onPressed:
                                                                            () {
                                                                          mixpanel!
                                                                              .track('brand_clients_filter_clean');
                                                                          setStateBottom(
                                                                              () {
                                                                            //searchController.clear();
                                                                            filterByClients =
                                                                                [
                                                                              true,
                                                                              true
                                                                            ];
                                                                            orderBySessions =
                                                                                [
                                                                              false,
                                                                              false
                                                                            ];
                                                                            hasOrder =
                                                                                false;
                                                                            hasFilter =
                                                                                false;
                                                                            filterSearchResults(
                                                                                query,
                                                                                state,
                                                                                true);
                                                                          });
                                                                        }),
                                                                dense: true,
                                                                onTap:
                                                                    currentPage ==
                                                                            0
                                                                        ? null
                                                                        : () {
                                                                            mixpanel!.track('brand_clients_filter_back');
                                                                            pageController.previousPage(
                                                                              duration: const Duration(milliseconds: 500),
                                                                              curve: Curves.ease,
                                                                            );
                                                                          },
                                                              ),
                                                              SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.25,
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
                                                                      (int
                                                                          page) {
                                                                    setStateBottom(
                                                                        () {
                                                                      currentPage =
                                                                          page;
                                                                    });
                                                                  },
                                                                  children: <Widget>[
                                                                    Column(
                                                                      children: [
                                                                        ListTile(
                                                                          onTap:
                                                                              () {
                                                                            setStateBottom(() {
                                                                              isFilterBy = true;
                                                                            });
                                                                            mixpanel!.track('brand_clients_filter_active');
                                                                            pageController.nextPage(
                                                                              duration: const Duration(milliseconds: 500),
                                                                              curve: Curves.ease,
                                                                            );
                                                                          },
                                                                          title: Text(
                                                                              "${AppLocalizations.of(context)!.active} ${AppLocalizations.of(context)!.lastNDays(30.toString())}",
                                                                              style: Theme.of(context).textTheme.bodyLarge,
                                                                              textAlign: TextAlign.left),
                                                                          subtitle: Text(
                                                                              returnFilteredActiveClientsString(),
                                                                              style: Theme.of(context).textTheme.bodySmall,
                                                                              textAlign: TextAlign.left),
                                                                          trailing:
                                                                              SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.15,
                                                                            child:
                                                                                Center(child: Icon(Icons.arrow_forward_ios, size: MediaQuery.of(context).size.width * 0.04, color: AppColors.grey)),
                                                                          ),
                                                                        ),
                                                                        state is ClientsSessionsLoaded &&
                                                                                state.finished
                                                                            ? ListTile(
                                                                                title: Text(AppLocalizations.of(context)!.orderBy, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.left),
                                                                                dense: true,
                                                                                onTap: currentPage == 0
                                                                                    ? null
                                                                                    : () {
                                                                                        mixpanel!.track('brand_clients_filter_back');
                                                                                        pageController.previousPage(
                                                                                          duration: const Duration(milliseconds: 500),
                                                                                          curve: Curves.ease,
                                                                                        );
                                                                                      },
                                                                              )
                                                                            : Container(),
                                                                        state is ClientsSessionsLoaded &&
                                                                                state.finished
                                                                            ? ListTile(
                                                                                onTap: () {
                                                                                  setStateBottom(() {
                                                                                    isFilterBy = false;
                                                                                  });
                                                                                  mixpanel!.track('brand_clients_order_active');
                                                                                  pageController.nextPage(
                                                                                    duration: const Duration(milliseconds: 500),
                                                                                    curve: Curves.ease,
                                                                                  );
                                                                                },
                                                                                title: Text(AppLocalizations.of(context)!.orderBySessions, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                                subtitle: Text(returnFilteredOrderClientsString(), style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.left),
                                                                                trailing: SizedBox(
                                                                                  width: MediaQuery.of(context).size.width * 0.15,
                                                                                  child: Center(child: Icon(Icons.arrow_forward_ios, size: MediaQuery.of(context).size.width * 0.04, color: AppColors.grey)),
                                                                                ),
                                                                              )
                                                                            : Container(),
                                                                      ],
                                                                    ),
                                                                    isFilterBy
                                                                        ? Column(
                                                                            children: [
                                                                              ListTile(
                                                                                onTap: () {
                                                                                  setStateBottom(() {
                                                                                    // Check if the Only True
                                                                                    var filterActive = List.from(filterByClients);
                                                                                    filterActive.retainWhere((element) => element == true);
                                                                                    if (!(filterActive.length == 1 && filterByClients[0])) {
                                                                                      //searchController.clear();
                                                                                      filterByClients[0] = !filterByClients[0];
                                                                                      mixpanel!.track('brand_clients_filter_active', properties: {
                                                                                        'Values': [
                                                                                          filterByClients[0] ? 'Yes' : ' ',
                                                                                          filterByClients[1] ? 'No' : ' '
                                                                                        ]
                                                                                      });
                                                                                      hasFilter = true;
                                                                                      filterSearchResults(query, state, true);
                                                                                    }
                                                                                  });
                                                                                },
                                                                                title: Text(AppLocalizations.of(context)!.yes, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                                trailing: filterByClients[0]
                                                                                    ? SizedBox(
                                                                                        width: MediaQuery.of(context).size.width * 0.15,
                                                                                        child: Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                                      )
                                                                                    : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                                              ),
                                                                              ListTile(
                                                                                onTap: () {
                                                                                  setStateBottom(() {
                                                                                    // Check if the Only True
                                                                                    var filterActive = List.from(filterByClients);
                                                                                    filterActive.retainWhere((element) => element == true);
                                                                                    if (!(filterActive.length == 1 && filterByClients[1])) {
                                                                                      //searchController.clear();
                                                                                      filterByClients[1] = !filterByClients[1];
                                                                                      hasFilter = true;
                                                                                      mixpanel!.track('brand_clients_filter_active', properties: {
                                                                                        'Values': [
                                                                                          filterByClients[0] ? 'Yes' : ' ',
                                                                                          filterByClients[1] ? 'No' : ' '
                                                                                        ]
                                                                                      });
                                                                                      filterSearchResults(query, state, true);
                                                                                    }
                                                                                  });
                                                                                },
                                                                                title: Text(AppLocalizations.of(context)!.no, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                                trailing: filterByClients[1]
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
                                                                                onTap: () {
                                                                                  setStateBottom(() {
                                                                                    //searchController.clear();
                                                                                    orderBySessions[0] = !orderBySessions[0];
                                                                                    orderBySessions[1] = false;
                                                                                    hasOrder = true;
                                                                                    filterSearchResults(query, state, true);
                                                                                  });
                                                                                },
                                                                                title: Text(AppLocalizations.of(context)!.orderBySessionsMoreToLess, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                                trailing: orderBySessions[0]
                                                                                    ? SizedBox(
                                                                                        width: MediaQuery.of(context).size.width * 0.15,
                                                                                        child: Center(child: Icon(Icons.check, size: MediaQuery.of(context).size.width * 0.08, color: Theme.of(context).colorScheme.secondary)),
                                                                                      )
                                                                                    : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                                              ),
                                                                              ListTile(
                                                                                onTap: () {
                                                                                  setStateBottom(() {
                                                                                    orderBySessions[1] = !orderBySessions[1];
                                                                                    orderBySessions[0] = false;
                                                                                    hasOrder = true;
                                                                                    filterSearchResults(query, state, true);
                                                                                  });
                                                                                },
                                                                                title: Text(AppLocalizations.of(context)!.orderBySessionsLessToMore, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                                trailing: orderBySessions[1]
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
                                            );
                                          },
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.09,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.09,
                                              child: Icon(
                                                Icons.filter_list,
                                                color: hasOrder || hasFilter
                                                    ? AppColors.darkGrey
                                                    : AppColors.white,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.07,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
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
              title: AnimatedOpacity(
                  opacity: appBarExpanded || searchClicked ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(AppLocalizations.of(context)!.clients,
                      style: Theme.of(context)
                          .appBarTheme
                          .titleTextStyle
                          ?.copyWith(
                            color: AppColors.white,
                          ))),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    unreadNotifiactions(context),
                    unreadChats(context),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                    GestureDetector(
                      onTap: () => navigateToProfileScreen(context),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.08,
                        child: Center(
                          child: CircularImage(
                            size: MediaQuery.of(context).size.width * 0.08,
                            image: currentUser.imageUrl,
                            color: AppColors.grey,
                            borderWidth: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.03),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            state is ClientsSessionsLoaded
                ? state.allUsers.isNotEmpty
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            Usuario user = state.usersNow[index];
                            String dateTimeNow = DateTimeUtils()
                                .formatDateTimeToStringDDMMYYYY(
                                    DateTime.now(),
                                    Localizations.localeOf(context)
                                        .languageCode);
                            DateTime dateJoined = DateTimeUtils()
                                .formatStringToDateTimeDDMMYY(
                                    user.dateJoined ?? dateTimeNow,
                                    Localizations.localeOf(context)
                                        .languageCode);
                            if (state.allUsers.isNotEmpty) {
                              return ListTile(
                                leading: CircularImage(
                                  size:
                                      MediaQuery.of(context).size.width * 0.15,
                                  image: user.imageUrl,
                                  color: Theme.of(context).primaryColor,
                                  borderWidth: 1.0,
                                ),
                                title: Text(
                                  user.name!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.lastEventAt == null
                                          ? AppLocalizations.of(context)!
                                              .lastActiveIn(DateTimeUtils()
                                                  .formatDateTimeToStringMMMYYYY(
                                                      dateJoined,
                                                      Localizations.localeOf(
                                                              context)
                                                          .languageCode))
                                          : AppLocalizations.of(context)!
                                              .lastActiveIn(DateTimeUtils()
                                                  .formatDateTimeToStringMMMYYYY(
                                                      user.lastEventAt!
                                                          .toDate(),
                                                      Localizations.localeOf(
                                                              context)
                                                          .languageCode)),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                trailing: user.id! == currentUser.id
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Theme.of(context).primaryColor,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.03,
                                        ),
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.all(0),
                                        onPressed: false ? () {} : null,
                                      )
                                    : user.sessions == null
                                        ? Padding(
                                            padding: const EdgeInsets.all(0),
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              margin: EdgeInsets.only(
                                                  right: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor,
                                                  shape: BoxShape.circle),
                                              child: CircularProgressIndicator(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                strokeWidth: 1.5,
                                              ),
                                            ),
                                          )
                                        : user.sessions == '-1'
                                            ? IconButton(
                                                icon: Icon(
                                                  Icons.chat_outlined,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.03,
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                onPressed: () async {
                                                  mixpanel!.track(
                                                      'brand_clients_chat_button');
                                                  types.User otherUser =
                                                      types.User(
                                                    firstName: user.firstName,
                                                    lastName: user.lastName,
                                                    id: user.id!,
                                                    // UID from Firebase Authentication
                                                    imageUrl: user.imageUrl,
                                                  );
                                                  final room =
                                                      await FirebaseChatCore
                                                          .instance
                                                          .createRoom(otherUser,
                                                              metadata: {
                                                        "trainer${user.id!}":
                                                            user.isTrainer,
                                                        "trainer${currentUser.id!}":
                                                            currentUser
                                                                .isTrainer,
                                                        "active${user.id!}":
                                                            false,
                                                        "active${currentUser.id!}":
                                                            true,
                                                      });

                                                  bool? deleteRoom =
                                                      await Navigator.push(
                                                    context,
                                                    CupertinoPageRoute<bool>(
                                                        builder: (context) =>
                                                            ChatPage(
                                                                room: room)),
                                                  ).whenComplete(() async {
                                                    room.metadata![
                                                            "active${currentUser.id!}"] =
                                                        false;
                                                    _roomDataService.updateRoom(
                                                        room.id,
                                                        room.metadata!);
                                                  });
                                                  if (!deleteRoom!) {
                                                    _roomDataService
                                                        .deleteRoom(room.id);
                                                    mixpanel!.track(
                                                        'brand_clients_chat_empty');
                                                  }
                                                },
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.12,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.08,
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .scaffoldBackgroundColor,
                                                      shape: BoxShape.circle),
                                                  child: buildPlacesLeftWidget(
                                                      int.parse(
                                                          user.sessions!)),
                                                ),
                                              ),
                                onTap: () async {
                                  mixpanel!.track('brand_clients_profile_view');
                                  var result = await Navigator.push(
                                      context,
                                      CupertinoPageRoute<bool?>(
                                          builder: (context) => ProfileViewUser(
                                                userID: user.id!,
                                                viewOnly: false,
                                              )));
                                  if (result != null && result) {
                                    context
                                        .read<ClientSessionsCubit>()
                                        .loadList();
                                  } else {
                                    context
                                        .read<ClientSessionsCubit>()
                                        .updateUser(
                                            user.id!,
                                            state.usersNow,
                                            state.allUsers,
                                            state.filteredUsers,
                                            state.searchedUsers,
                                            state.i,
                                            state.finished);
                                  }
                                },
                              );
                            } else {}
                          },
                          childCount: state.usersNow.length, // 1000 list items
                        ),
                      )
                    : SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.25),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Image.asset(Constants.emptyCalendar)),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.005),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "${AppLocalizations.of(context)!.noData.split(" ")[0]} ${AppLocalizations.of(context)!.clients.toLowerCase()}",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.04,
                              vertical:
                                  MediaQuery.of(context).size.width * 0.02),
                          child: Row(
                            children: [
                              Shimmer.fromColors(
                                baseColor: AppColors.grey,
                                highlightColor: AppColors.grey.withOpacity(0.5),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.14,
                                  width:
                                      MediaQuery.of(context).size.width * 0.14,
                                  decoration: const BoxDecoration(
                                    color: AppColors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.04), // adjust this value as needed
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// USER
                                    Shimmer.fromColors(
                                      baseColor: AppColors.grey,
                                      highlightColor:
                                          AppColors.grey.withOpacity(0.5),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.007),

                                    /// BONO
                                    Shimmer.fromColors(
                                      baseColor: AppColors.grey,
                                      highlightColor:
                                          AppColors.grey.withOpacity(0.5),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.015,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.007),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.04),
                              Shimmer.fromColors(
                                baseColor: AppColors.grey,
                                highlightColor: AppColors.grey.withOpacity(0.5),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Theme.of(context).primaryColor,
                                  size:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount:
                          widget.numClients == 0 ? 5 : widget.numClients,
                    ),
                  ),
            const SliverToBoxAdapter(
                child: SizedBox(
              height: 8,
            )),
          ],
        ),
        floatingActionButton: whichFloatingActionButton(),
      );
    });
  }

  Widget whichFloatingActionButton() {
    return currentUser.brandRole < 3
        ? Padding(
            padding: Platform.isAndroid
                ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10)
                : const EdgeInsets.all(10),
            child: SizedBox(
              height: MediaQuery.of(context).size.width * 0.15,
              width: MediaQuery.of(context).size.width * 0.15,
              child: SpeedDial(
                heroTag: "96",
                activeChild: const Icon(Icons.group_add_outlined),
                animationDuration: const Duration(milliseconds: 100),
                foregroundColor: AppColors.white,
                overlayColor: Theme.of(context).scaffoldBackgroundColor,
                overlayOpacity: 0.95,
                spacing: MediaQuery.of(context).size.height * 0.02,
                spaceBetweenChildren: MediaQuery.of(context).size.height * 0.02,
                openCloseDial: isDialOpen,
                children: [
                  SpeedDialChild(
                      child: const Icon(
                        Icons.edit_note_outlined,
                        size: 30,
                      ),
                      elevation: 10,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      labelWidget: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.05),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      TopSnackBarDef().showSnackBarBottom(
                                          context,
                                          AppLocalizations.of(context)!
                                              .betaFeature,
                                          5);
                                    },
                                    child: const BetaBadge()),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02,
                                ),
                                Text(
                                    "${AppLocalizations.of(context)!.add} ${AppLocalizations.of(context)!.client}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                    textAlign: TextAlign.right),
                              ],
                            ),
                            Text(
                                AppLocalizations.of(context)!
                                    .addClientsManually,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.right),
                          ],
                        ),
                      ),
                      onTap: () {
                        navigateToAddMember();
                      }),
                  SpeedDialChild(
                      child: const Padding(
                        padding: EdgeInsets.only(right: 5.0),
                        child: Icon(
                          Icons.share,
                        ),
                      ),
                      elevation: 10,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      labelWidget: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.05),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                "${AppLocalizations.of(context)!.invite} ${AppLocalizations.of(context)!.client}",
                                style: Theme.of(context).textTheme.displaySmall,
                                textAlign: TextAlign.right),
                            Text(AppLocalizations.of(context)!.copyCodeMessage,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.right),
                          ],
                        ),
                      ),
                      onTap: () {
                        navigateShareBrandLink();
                      }),
                ],
                child: const Icon(Icons.add),
              ),
            ),
          )
        : Container();
  }

  Future<void> navigateToAddMember() async {
    var result = await Navigator.push(
        context,
        CupertinoPageRoute<bool?>(
          builder: (context) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: const RegisterBrandMember(
              isTrainer: false,
            ),
          ),
        ));
    if (result != null && result) {
      context.read<ClientSessionsCubit>().loadList();
    }
  }

  Future<void> navigateShareBrandLink() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 0.8,
          child: ShareBrandLink(
            addStaff: false,
          ),
        );
      },
    );
  }

  // Build Places Left Event
  Widget buildPlacesLeftWidget(int places) {
    dynamic color = Colors.red;
    if (places == 0) {
      color = Colors.red;
    } else {
      double bookedCapacity = places / 10;
      if (bookedCapacity <= 0.20) {
        color = Colors.red;
      } else if (bookedCapacity > 0.20 && bookedCapacity <= 0.40) {
        color = Colors.deepOrangeAccent;
      } else if (bookedCapacity > 0.40 && bookedCapacity <= 0.60) {
        color = Colors.orangeAccent;
      } else if (bookedCapacity > 0.60 && bookedCapacity <= 0.80) {
        color = const Color(0xFFffd966);
      } else if (bookedCapacity > 0.80 && bookedCapacity < 1) {
        color = const Color(0xFFA8C76C);
      } else if (bookedCapacity >= 1) {
        color = Colors.green;
      }
    }

    return FittedBox(
        fit: BoxFit.fitHeight,
        child: SizedBox(
            height: MediaQuery.of(context).size.width * 0.1,
            //padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  places == 10 ? '+9' : places.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: color),
                  textAlign: TextAlign.center,
                ),
                Text(
                  places == 1
                      ? AppLocalizations.of(context)!.session.toLowerCase()
                      : AppLocalizations.of(context)!.sessions.toLowerCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 5, color: color),
                  textAlign: TextAlign.center,
                ),
              ],
            )));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
