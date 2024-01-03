import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Room/RoomDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/Chat.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/BetaBadge.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/001-Trainers/BrandRoles.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/RegisterBrandMember.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/ShareBrandLink.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mamba_castelldefels/Notifications/Unread/widgets/unreadChats.dart';
import 'package:mamba_castelldefels/Notifications/Unread/widgets/unreadNotifications.dart';

class Trainers extends StatefulWidget {
  String brandId;
  int numTrainers;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;

  Trainers(
      {super.key,
      required this.brandId,
      required this.numTrainers,
      required this.pinned,
      required this.pinnedChanged});

  @override
  _Trainers createState() => _Trainers();
}

class _Trainers extends State<Trainers> {
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
  final _brandDataService = BrandDataService();
  final _roomDataService = RoomDataService();
  final _userDataService = UserDataService();

  // Boolean Loading
  bool isLoading = false;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  // Boolean isUpdated
  bool isUpdated = false;
  // Search Controller
  bool searchClicked = false;
  var searchController = TextEditingController();

  // Members Page
  List<Usuario> allMembers = [];
  List<Usuario> filteredMembers = [];
  // Trainers Roles
  List<Usuario> allOwners = [];
  List<Usuario> allAdmins = [];
  List<Usuario> allTrainers = [];

  // Filters
  bool hasFilter = false;
  List<bool> filterByTrainers = [true, true, true, true, true];

  var chatUsers = [];

  Future<void> getAllUsers() async {
    List<Usuario> brandUsers =
        await _brandDataService.getBrandTrainers(widget.brandId);
    allMembers = [];
    for (var i = 0; i < brandUsers.length; i++) {
      Usuario user = brandUsers[i];
      allMembers.add(user);
      if (user.brandRole == 1) {
        allOwners.add(user);
      } else if (user.brandRole == 2) {
        allAdmins.add(user);
      } else {
        allTrainers.add(user);
      }
    }
    /*
    for (var i=0; i< 10; i++) {
      Usuario user = brandUsers[0];
      allTrainers.add(user);
    }
    */
    // Add All Members
    allMembers.sort((a, b) {
      return a.name
          .toString()
          .toLowerCase()
          .compareTo(b.name.toString().toLowerCase());
    });
    filteredMembers = allMembers;
    // Return Future Delayed
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      allMembers = filteredMembers;
      isLoading = false;
    });
  }

  void filterSearchResults(String query) {
    List<Usuario> usersFiltered = [];
    if (query.isNotEmpty || query != "") {
      for (var item in allMembers) {
        if (item.name!.toLowerCase().startsWith(query)) {
          usersFiltered.add(item);
        }
      }
      setState(() {
        filteredMembers = usersFiltered;
      });
    } else {
      setState(() {
        filteredMembers = allMembers;
      });
    }
  }

  void filterByRolesAndActive() {
    // Filter By
    allMembers.sort((a, b) {
      return a.name
          .toString()
          .toLowerCase()
          .compareTo(b.name.toString().toLowerCase());
    });
    filteredMembers = List.from(allMembers);
    int cnt = 0;
    if (filterByTrainers[0] == false) {
      filteredMembers.removeWhere((element) => element.brandRole == 1);
    } else {
      cnt += 1;
    }
    if (filterByTrainers[1] == false) {
      filteredMembers.removeWhere((element) => element.brandRole == 2);
    } else {
      cnt += 1;
    }
    if (filterByTrainers[2] == false) {
      filteredMembers.removeWhere((element) => element.brandRole == 3);
    } else {
      cnt += 1;
    }
    if (filterByTrainers[3] == false) {
      filteredMembers.removeWhere((element) {
        DateTime oneMonthAgo =
            DateTime.now().subtract(const Duration(days: 31));
        if (element.lastEventAt == null) {
          return false;
        } else {
          return oneMonthAgo.isBefore(element.lastEventAt!.toDate());
        }
      });
    } else {
      cnt += 1;
    }
    if (filterByTrainers[4] == false) {
      filteredMembers.removeWhere((element) {
        DateTime oneMonthAgo =
            DateTime.now().subtract(const Duration(days: 31));
        if (element.lastEventAt == null) {
          return true;
        } else {
          return oneMonthAgo.isAfter(element.lastEventAt!.toDate());
        }
      });
    } else {
      cnt += 1;
    }
    // Has Filter Update
    if (cnt == 5) {
      setState(() {
        hasFilter = false;
      });
    } else {
      setState(() {
        hasFilter = true;
      });
    }

    // Navigator Pop
    Navigator.pop(context);
  }

  String returnBrandRoleString(Usuario user) {
    switch (user.brandRole) {
      case 1:
        return AppLocalizations.of(context)!.owner;
      case 2:
        return AppLocalizations.of(context)!.administrador;
      case 3:
        return AppLocalizations.of(context)!.trainer;
      default:
        return AppLocalizations.of(context)!.trainer;
    }
  }

  String returnFilteredRolesString() {
    String filteredRoles = "";
    int cnt = 0;
    if (filterByTrainers[0]) {
      filteredRoles += "${AppLocalizations.of(context)!.owner}, ";
      cnt += 1;
    }
    if (filterByTrainers[1]) {
      filteredRoles += "${AppLocalizations.of(context)!.administrador}, ";
      cnt += 1;
    }
    if (filterByTrainers[2]) {
      filteredRoles += AppLocalizations.of(context)!.trainer;
      cnt += 1;
    }
    if (cnt == 1) {
      return filteredRoles.split(", ")[0];
    }
    if (cnt == 2 && filterByTrainers[2] == false) {
      return "${filteredRoles.split(", ")[0]}, ${filteredRoles.split(", ")[1]}";
    }
    return filteredRoles;
  }

  String returnFilteredActiveStaffString() {
    String activeStaff = "";
    int cnt = 0;
    if (filterByTrainers[3]) {
      activeStaff += "${AppLocalizations.of(context)!.yes}, ";
      cnt += 1;
    }
    if (filterByTrainers[4]) {
      activeStaff += AppLocalizations.of(context)!.no;
      cnt += 1;
    }
    if (cnt == 1) {
      return activeStaff.split(", ")[0];
    }
    return activeStaff;
  }

  @override
  initState() {
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
    getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
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
                                  AppLocalizations.of(context)!.staff,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        color: AppColors.white,
                                      ),
                                )
                              : SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  child: TextField(
                                    autofocus: true,
                                    controller: searchController,
                                    onChanged: (value) {
                                      filterSearchResults(value);
                                    },
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.white),
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                      hintStyle:
                                          Theme.of(context).textTheme.bodySmall,
                                      hintText:
                                          AppLocalizations.of(context)!.search,
                                      enabledBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: AppColors.grey),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: AppColors.grey),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                      border: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: AppColors.grey),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          mixpanel!.track(
                                              'brand_trainers_search_clean');
                                          searchController.clear();
                                          filterSearchResults("");
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
                                              'brand_trainers_search_button');
                                        } else {
                                          mixpanel!.track(
                                              'brand_trainers_search_close');
                                        }
                                        setState(() {
                                          searchController.clear();
                                          filterSearchResults("");
                                          searchClicked = !searchClicked;
                                        });
                                      },
                                      splashRadius: 20,
                                      splashColor: Theme.of(context)
                                          .colorScheme.background, // Splash color
                                      padding: EdgeInsets.zero,
                                      alignment: Alignment.center,
                                      icon: Icon(
                                        searchClicked == false
                                            ? Icons.search_outlined
                                            : Icons.close_outlined,
                                        color: AppColors.white,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.07,
                                      ),
                                    ),
                                  ),
                                  ClipOval(
                                    child: Material(
                                      color: hasFilter
                                          ? AppColors.white
                                          : Colors.transparent, // Button color
                                      child: InkWell(
                                        splashColor: Theme.of(context)
                                            .colorScheme.background, // Splash color
                                        onTap: () async {
                                          mixpanel!.track(
                                              'brand_trainers_filter_button');
                                          await showModalBottomSheet<int?>(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
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
                                              bool isRoles = true;
                                              // Widget
                                              return StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter
                                                        setStateBottom) {
                                                  return FractionallySizedBox(
                                                    heightFactor: 0.33,
                                                    child: SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.5,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            MediaQuery.of(
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
                                                                  AppLocalizations.of(
                                                                          context)!
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
                                                                            .track('brand_trainers_filter_clean');
                                                                        setStateBottom(
                                                                            () {
                                                                          searchController
                                                                              .clear();
                                                                          filterSearchResults(
                                                                              "");
                                                                          filterByTrainers =
                                                                              [
                                                                            true,
                                                                            true,
                                                                            true,
                                                                            true,
                                                                            true
                                                                          ];
                                                                          filterByRolesAndActive();
                                                                        });
                                                                      }),
                                                              dense: true,
                                                              onTap:
                                                                  currentPage ==
                                                                          0
                                                                      ? null
                                                                      : () {
                                                                          mixpanel!
                                                                              .track('brand_trainers_filter_back');
                                                                          pageController
                                                                              .previousPage(
                                                                            duration:
                                                                                const Duration(milliseconds: 500),
                                                                            curve:
                                                                                Curves.ease,
                                                                          );
                                                                        },
                                                            ),
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.21,
                                                              width:
                                                                  MediaQuery.of(
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
                                                                          setStateBottom(
                                                                              () {
                                                                            isRoles =
                                                                                true;
                                                                          });
                                                                          mixpanel!
                                                                              .track('brand_trainers_filter_roles');
                                                                          pageController
                                                                              .nextPage(
                                                                            duration:
                                                                                const Duration(milliseconds: 500),
                                                                            curve:
                                                                                Curves.ease,
                                                                          );
                                                                        },
                                                                        title: Text(
                                                                            AppLocalizations.of(context)!
                                                                                .roles,
                                                                            style:
                                                                                Theme.of(context).textTheme.bodyLarge,
                                                                            textAlign: TextAlign.left),
                                                                        subtitle: Text(
                                                                            returnFilteredRolesString(),
                                                                            style:
                                                                                Theme.of(context).textTheme.bodySmall,
                                                                            textAlign: TextAlign.left),
                                                                        trailing:
                                                                            SizedBox(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.15,
                                                                          child:
                                                                              Center(child: Icon(Icons.arrow_forward_ios, size: MediaQuery.of(context).size.width * 0.04, color: AppColors.grey)),
                                                                        ),
                                                                      ),
                                                                      ListTile(
                                                                        onTap:
                                                                            () {
                                                                          setStateBottom(
                                                                              () {
                                                                            isRoles =
                                                                                false;
                                                                          });
                                                                          mixpanel!
                                                                              .track('brand_trainers_filter_active');
                                                                          pageController
                                                                              .nextPage(
                                                                            duration:
                                                                                const Duration(milliseconds: 500),
                                                                            curve:
                                                                                Curves.ease,
                                                                          );
                                                                        },
                                                                        title: Text(
                                                                            "${AppLocalizations.of(context)!.active} ${AppLocalizations.of(context)!.lastNDays(30.toString())}",
                                                                            style: Theme.of(context).textTheme.bodyLarge,
                                                                            textAlign: TextAlign.left),
                                                                        subtitle: Text(
                                                                            returnFilteredActiveStaffString(),
                                                                            style:
                                                                                Theme.of(context).textTheme.bodySmall,
                                                                            textAlign: TextAlign.left),
                                                                        trailing:
                                                                            SizedBox(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.15,
                                                                          child:
                                                                              Center(child: Icon(Icons.arrow_forward_ios, size: MediaQuery.of(context).size.width * 0.04, color: AppColors.grey)),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  isRoles
                                                                      ? Column(
                                                                          children: [
                                                                            ListTile(
                                                                              onTap: () {
                                                                                setStateBottom(() {
                                                                                  // Check if the Only True
                                                                                  var filterRoles = filterByTrainers.sublist(0, 3);
                                                                                  filterRoles.retainWhere((element) => element == true);
                                                                                  if (!(filterRoles.length == 1 && filterByTrainers[0])) {
                                                                                    searchController.clear();
                                                                                    filterSearchResults("");
                                                                                    filterByTrainers[0] = !filterByTrainers[0];
                                                                                    mixpanel!.track('brand_trainers_filter_roles', properties: {
                                                                                      'Values': [
                                                                                        filterByTrainers[0] ? 'Owner' : ' ',
                                                                                        filterByTrainers[1] ? 'Admin' : ' ',
                                                                                        filterByTrainers[2] ? 'Coach' : ' '
                                                                                      ]
                                                                                    });
                                                                                    filterByRolesAndActive();
                                                                                  }
                                                                                });
                                                                              },
                                                                              title: Text(AppLocalizations.of(context)!.owner, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                              trailing: filterByTrainers[0]
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
                                                                                  var filterRoles = filterByTrainers.sublist(0, 3);
                                                                                  filterRoles.retainWhere((element) => element == true);
                                                                                  if (!(filterRoles.length == 1 && filterByTrainers[1])) {
                                                                                    searchController.clear();
                                                                                    filterSearchResults("");
                                                                                    filterByTrainers[1] = !filterByTrainers[1];
                                                                                    mixpanel!.track('brand_trainers_filter_roles', properties: {
                                                                                      'Values': [
                                                                                        filterByTrainers[0] ? 'Owner' : ' ',
                                                                                        filterByTrainers[1] ? 'Admin' : ' ',
                                                                                        filterByTrainers[2] ? 'Coach' : ' '
                                                                                      ]
                                                                                    });
                                                                                    filterByRolesAndActive();
                                                                                  }
                                                                                });
                                                                              },
                                                                              title: Text(AppLocalizations.of(context)!.administrador, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                              trailing: filterByTrainers[1]
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
                                                                                  var filterRoles = filterByTrainers.sublist(0, 3);
                                                                                  filterRoles.retainWhere((element) => element == true);
                                                                                  if (!(filterRoles.length == 1 && filterByTrainers[2])) {
                                                                                    searchController.clear();
                                                                                    filterSearchResults("");
                                                                                    filterByTrainers[2] = !filterByTrainers[2];
                                                                                    mixpanel!.track('brand_trainers_filter_roles', properties: {
                                                                                      'Values': [
                                                                                        filterByTrainers[0] ? 'Owner' : ' ',
                                                                                        filterByTrainers[1] ? 'Admin' : ' ',
                                                                                        filterByTrainers[2] ? 'Coach' : ' '
                                                                                      ]
                                                                                    });
                                                                                    filterByRolesAndActive();
                                                                                  }
                                                                                });
                                                                              },
                                                                              title: Text(AppLocalizations.of(context)!.trainer, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                              trailing: filterByTrainers[2]
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
                                                                                  // Check if the Only True
                                                                                  var filterActive = filterByTrainers.sublist(3);
                                                                                  filterActive.retainWhere((element) => element == true);
                                                                                  if (!(filterActive.length == 1 && filterByTrainers[3])) {
                                                                                    searchController.clear();
                                                                                    filterSearchResults("");
                                                                                    filterByTrainers[3] = !filterByTrainers[3];
                                                                                    mixpanel!.track('brand_trainers_filter_active', properties: {
                                                                                      'Values': [
                                                                                        filterByTrainers[3] ? 'Yes' : ' ',
                                                                                        filterByTrainers[4] ? 'No' : ' '
                                                                                      ]
                                                                                    });
                                                                                    filterByRolesAndActive();
                                                                                  }
                                                                                });
                                                                              },
                                                                              title: Text(AppLocalizations.of(context)!.yes, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                              trailing: filterByTrainers[3]
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
                                                                                  var filterActive = filterByTrainers.sublist(3);
                                                                                  filterActive.retainWhere((element) => element == true);
                                                                                  if (!(filterActive.length == 1 && filterByTrainers[4])) {
                                                                                    searchController.clear();
                                                                                    filterSearchResults("");
                                                                                    filterByTrainers[4] = !filterByTrainers[4];
                                                                                    mixpanel!.track('brand_trainers_filter_active', properties: {
                                                                                      'Values': [
                                                                                        filterByTrainers[3] ? 'Yes' : ' ',
                                                                                        filterByTrainers[4] ? 'No' : ' '
                                                                                      ]
                                                                                    });
                                                                                    filterByRolesAndActive();
                                                                                  }
                                                                                });
                                                                              },
                                                                              title: Text(AppLocalizations.of(context)!.no, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.left),
                                                                              trailing: filterByTrainers[4]
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
                                              color: hasFilter
                                                  ? AppColors.darkGrey
                                                  : AppColors.white,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.07,
                                            )),
                                      ),
                                    ),
                                  )
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
                child: Text(AppLocalizations.of(context)!.staff,
                    style:
                        Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
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
          currentUser.brandRole < 2
              ? SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      GestureDetector(
                        onTap: navigateToRolesScreen,
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.manage_accounts_outlined,
                                color: Theme.of(context).colorScheme.secondary,
                                size: MediaQuery.of(context).size.width * 0.10,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.05),
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.edit} ${AppLocalizations.of(context)!
                                              .staff
                                              .toLowerCase()}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .rolesDescription,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  ],
                                ),
                              ),
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
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01)
                    ],
                  ),
                )
              : const SliverToBoxAdapter(
                  child: SizedBox(
                  height: 10,
                )),
          isLoading
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.04,
                            vertical: MediaQuery.of(context).size.width * 0.02),
                        child: Row(
                          children: [
                            Shimmer.fromColors(
                              baseColor: AppColors.grey,
                              highlightColor: AppColors.grey.withOpacity(0.5),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.14,
                                width: MediaQuery.of(context).size.width * 0.14,
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
                                      width: MediaQuery.of(context).size.width *
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
                                      width: MediaQuery.of(context).size.width *
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
                                size: MediaQuery.of(context).size.height * 0.03,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: widget.numTrainers,
                  ),
                )
              : filteredMembers.isNotEmpty
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          Usuario user = filteredMembers[index];
                          return ListTile(
                            leading: CircularImage(
                              size: MediaQuery.of(context).size.width * 0.15,
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
                                  returnBrandRoleString(user),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            trailing: user.id! == currentUser.id
                                ? IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Theme.of(context).primaryColor,
                                      size: MediaQuery.of(context).size.height *
                                          0.03,
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.all(0),
                                    onPressed: false ? () {} : null,
                                  )
                                : IconButton(
                                    icon: Icon(
                                      Icons.chat_outlined,
                                      color: Theme.of(context).primaryColor,
                                      size: MediaQuery.of(context).size.height *
                                          0.03,
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () async {
                                      mixpanel!
                                          .track('brand_trainers_chat_button');
                                      types.User otherUser = types.User(
                                        firstName: user.firstName,
                                        lastName: user.lastName,
                                        id: user
                                            .id!, // UID from Firebase Authentication
                                        imageUrl: user.imageUrl,
                                      );
                                      final room = await FirebaseChatCore
                                          .instance
                                          .createRoom(otherUser, metadata: {
                                        "trainer${user.id!}": user.isTrainer,
                                        "trainer${currentUser.id!}":
                                            currentUser.isTrainer,
                                        "active${user.id!}": false,
                                        "active${currentUser.id!}": true,
                                      });

                                      bool? deleteRoom = await Navigator.push(
                                        context,
                                        CupertinoPageRoute<bool>(
                                            builder: (context) =>
                                                ChatPage(room: room)),
                                      ).whenComplete(() async {
                                        room.metadata![
                                            "active${currentUser.id!}"] = false;
                                        _roomDataService.updateRoom(
                                            room.id, room.metadata!);
                                      });
                                      if (!deleteRoom!) {
                                        _roomDataService.deleteRoom(room.id);
                                        mixpanel!
                                            .track('brand_trainers_chat_empty');
                                      }
                                    },
                                  ),
                            onTap: () async {
                              mixpanel!.track('brand_trainers_profile_view');
                              var result = await Navigator.push(
                                  context,
                                  CupertinoPageRoute<bool?>(
                                      builder: (context) => ProfileViewUser(
                                            userID: user.id!,
                                            viewOnly: false,
                                          )));
                              if (result == true) {
                                await getAllUsers();
                              }
                            },
                          );
                        },
                        childCount: filteredMembers.length, // 1000 list items
                      ),
                    )
                  : SliverFillRemaining(
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
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.12),
                        ],
                      ),
                    ),
          const SliverToBoxAdapter(
              child: SizedBox(
            height: 10,
          )),
        ],
      ),
      floatingActionButton: whichFloatingActionButton(),
    );
  }

  Widget whichFloatingActionButton() {
    return currentUser.brandRole < 2
        ? Padding(
            padding: Platform.isAndroid
                ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10)
                : const EdgeInsets.all(10),
            child: SizedBox(
              height: MediaQuery.of(context).size.width * 0.15,
              width: MediaQuery.of(context).size.width * 0.15,
              child: SpeedDial(
                heroTag: "106",
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
                                    "${AppLocalizations.of(context)!.add} ${AppLocalizations.of(context)!.staff}",
                                    style:
                                        Theme.of(context).textTheme.displaySmall,
                                    textAlign: TextAlign.right),
                              ],
                            ),
                            Text(
                                AppLocalizations.of(context)!
                                        .addClientsManually
                                        .split(AppLocalizations.of(context)!
                                            .client
                                            .toLowerCase())[0] +
                                    AppLocalizations.of(context)!
                                        .staff
                                        .toLowerCase() +
                                    AppLocalizations.of(context)!
                                        .addClientsManually
                                        .split(AppLocalizations.of(context)!
                                            .client
                                            .toLowerCase())[1],
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
                                "${AppLocalizations.of(context)!.invite} ${AppLocalizations.of(context)!.staff}",
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

  // Navigate to Roles Screen
  Future<void> navigateToRolesScreen() async {
    mixpanel!.track('brand_trainers_roles_view');
    var result = await Navigator.push(
        context,
        CupertinoPageRoute<bool?>(
          builder: (context) => BrandRoles(
            brandId: widget.brandId,
            trainers: allMembers,
          ),
        ));
    if (result == null || result == true) {
      setState(() {
        isLoading = true;
      });
      getAllUsers();
    }
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
              isTrainer: true,
            ),
          ),
        ));
    if (result == true) {
      await getAllUsers();
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
            onlyStaff: true,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
