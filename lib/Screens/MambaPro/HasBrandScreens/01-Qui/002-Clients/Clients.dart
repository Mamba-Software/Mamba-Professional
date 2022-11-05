import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Room/RoomDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/Chat.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/OrderFilter/OrderFilter.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:shimmer/shimmer.dart';

class Clients extends StatefulWidget {
  String brandId;
  int numClients;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;

  Clients({Key? key, required this.brandId, required this.numClients, required this.pinned, required this.pinnedChanged}) : super(key: key);

  @override
  _Clients createState() => _Clients();
}

class _Clients extends State<Clients> {

  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.15 - kToolbarHeight);
  }
  // Brand Data Service
  final _brandDataService = BrandDataService();
  final _userDataService = UserDataService();
  final _roomDataService = RoomDataService();
  // Boolean Loading
  bool isLoading = false;
  // Search Controller
  bool searchClicked = false;
  var searchController = TextEditingController();

  // Members Page
  List<Usuario> allMembers = [];
  List<Usuario> filteredMembers = [];
  List<Usuario> allClients = [];

  // Filters
  bool hasFilter = false;
  List<bool> filterByClients = [true, true];

  Future<void> getAllUsers() async {
    List<Usuario> brandUsers = await _brandDataService.getBrandClients(widget.brandId);
    allClients = [];
    Event lastEvent = Event();
    for (var i=0; i< brandUsers.length; i++) {
      Usuario user = brandUsers[i];
      /*
      lastEvent = await _userDataService.getLastUserEvent(user.id);
      if(lastEvent.id != null && DateTime.now().difference(lastEvent.doneAt!.toDate()).inDays <= 30)
        {
          user.active = true;
          activeClients.add(user);
        }
      else {
        user.active = false;
        inactiveClients.add(user);
      }
       */
      allClients.add(user);
    }

    /*
    for (var i=0; i< 10; i++) {
      Usuario user = brandUsers[0];
      allClients.add(user);
    }
    */
    // Sort Clients
    allClients.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    // Add All Members
    allMembers.addAll(allClients);
    allMembers.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    filteredMembers = allMembers;
    // Return Future Delayed
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
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

  void filterByActive() {
    // Filter By
    allMembers.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    filteredMembers = List.from(allMembers);
    int cnt = 0;
    if (filterByClients[0] == false) {
      filteredMembers.removeWhere((element) {
        DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 31));
        if (element.lastEventAt == null) {
          return false;
        } else {
          return oneMonthAgo.isBefore(element.lastEventAt!.toDate());
        }
      });
    } else {
      cnt += 1;
    }
    if (filterByClients[1] == false) {
      filteredMembers.removeWhere((element) {
        DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 31));
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
    if (cnt == 2) {
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

  String returnFilteredActiveClientsString() {
    String activeStaff = "";
    int cnt = 0;
    if (filterByClients[0]) {
      activeStaff += AppLocalizations.of(context)!.yes+", ";
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

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() => _isAppBarExpanded ?
      setState(() {
        appBarExpanded = true;
      }) :
      setState(() {
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
            expandedHeight: MediaQuery.of(context).size.height*0.15,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 4,
            floating: true,
            pinned: true,
            //snap: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                height: MediaQuery.of(context).size.height*0.2,
                width: double.infinity,
                color: AppColors.darkGrey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          searchClicked == false ? Text(
                            AppLocalizations.of(context)!.clients,
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white,),
                          ) : SizedBox(
                            width: MediaQuery.of(context).size.width*0.65,
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) {
                                filterSearchResults(value);
                              },
                              style: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.white),
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                hintStyle: Theme.of(context).textTheme.caption,
                                hintText: AppLocalizations.of(context)!.search,
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.grey),
                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                ),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.grey),
                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                ),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.grey),
                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    mixpanel!.track('brand_clients_search_clean');
                                    searchController.clear();
                                    filterSearchResults("");
                                  },
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey,),
                                ),
                                contentPadding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.04),
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.25,
                              /*
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green, width: 1.0),
                                color: Colors.transparent,
                              ),
                               */
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (searchClicked == false) {
                                        mixpanel!.track('brand_clients_search_button');
                                      } else {
                                        mixpanel!.track('brand_clients_search_close');
                                      }
                                      setState(() {
                                        searchClicked = !searchClicked;
                                        searchController.clear();
                                        filterSearchResults("");
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    alignment: Alignment.centerRight,
                                    icon: Icon(
                                      searchClicked == false ? Icons.search_outlined : Icons.close_outlined,
                                      color: AppColors.white,
                                      size: MediaQuery.of(context).size.width*0.07,
                                    ),
                                  ),
                                  ClipOval(
                                    child: Material(
                                      color: hasFilter ? AppColors.white : Colors.transparent, // Button color
                                      child: InkWell(
                                        splashColor: Theme.of(context).backgroundColor, // Splash color
                                        onTap: () async {
                                          mixpanel!.track('brand_clients_filter_button');
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
                                                                    mixpanel!.track('brand_clients_filter_clean');
                                                                    setStateBottom(() {
                                                                      searchController.clear();
                                                                      filterSearchResults("");
                                                                      filterByClients = [true, true];
                                                                      filterByActive();
                                                                    });
                                                                  }
                                                              ),
                                                              dense: true,
                                                              onTap: _currentPage == 0 ? null : () {
                                                                mixpanel!.track('brand_clients_filter_back');
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
                                                                          mixpanel!.track('brand_clients_filter_active');
                                                                          _pageController.nextPage(
                                                                            duration: const Duration(milliseconds: 500),
                                                                            curve: Curves.ease,
                                                                          );
                                                                        },
                                                                        title: Text(
                                                                            AppLocalizations.of(context)!.active+" "+AppLocalizations.of(context)!.lastNDays(30.toString()),
                                                                            style: Theme.of(context).textTheme.bodyText1,
                                                                            textAlign: TextAlign.left
                                                                        ),
                                                                        subtitle: Text(
                                                                            returnFilteredActiveClientsString(),
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
                                                                          setStateBottom(() {
                                                                            // Check if the Only True
                                                                            var filterActive = List.from(filterByClients);
                                                                            filterActive.retainWhere((element) => element == true);
                                                                            if (!(filterActive.length == 1 && filterByClients[0])) {
                                                                              searchController.clear();
                                                                              filterSearchResults("");
                                                                              filterByClients[0] = !filterByClients[0];
                                                                              mixpanel!.track('brand_clients_filter_active', properties: {'Values': [filterByClients[0] ? 'Yes' : ' ', filterByClients[1] ? 'No' : ' ' ]});
                                                                              filterByActive();
                                                                            }
                                                                          });
                                                                        },
                                                                        title: Text(
                                                                            AppLocalizations.of(context)!.yes,
                                                                            style: Theme.of(context).textTheme.bodyText1,
                                                                            textAlign: TextAlign.left
                                                                        ),
                                                                        trailing: filterByClients[0] ? SizedBox(
                                                                          width: MediaQuery.of(context).size.width * 0.15,
                                                                          child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                                        ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                                      ),
                                                                      ListTile(
                                                                        onTap: () {
                                                                          setStateBottom(() {
                                                                            // Check if the Only True
                                                                            var filterActive = List.from(filterByClients);
                                                                            filterActive.retainWhere((element) => element == true);
                                                                            if (!(filterActive.length == 1 && filterByClients[1])) {
                                                                              searchController.clear();
                                                                              filterSearchResults("");
                                                                              filterByClients[1] = !filterByClients[1];
                                                                              mixpanel!.track('brand_clients_filter_active', properties: {'Values': [filterByClients[0] ? 'Yes' : ' ', filterByClients[1] ? 'No' : ' ' ]});
                                                                              filterByActive();
                                                                            }
                                                                          });
                                                                        },
                                                                        title: Text(
                                                                            AppLocalizations.of(context)!.no,
                                                                            style: Theme.of(context).textTheme.bodyText1,
                                                                            textAlign: TextAlign.left
                                                                        ),
                                                                        trailing: filterByClients[1] ? SizedBox(
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
                                          );
                                        },
                                        child: SizedBox(width: MediaQuery.of(context).size.width*0.09, height: MediaQuery.of(context).size.width*0.09, child: Icon(
                                          Icons.filter_list,
                                          color: hasFilter ? AppColors.darkGrey :  AppColors.white,
                                          size: MediaQuery.of(context).size.width*0.07,
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
                    SizedBox(height: MediaQuery.of(context).size.height*0.02,),
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
            title: appBarExpanded || searchClicked ? Text(AppLocalizations.of(context)!.clients, style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: Colors.white),) : Container(),
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
            /*
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.1,),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height*0.08,
                  child: Padding(
                      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05,left: MediaQuery.of(context).size.width*0.05),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          filterSearchResults(value);
                        },
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          hintStyle: Theme.of(context).textTheme.caption,
                          hintText: AppLocalizations.of(context)!.search,
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: MediaQuery.of(context).size.width*0.06,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              searchController.clear();
                              filterSearchResults("");
                            },
                            icon: const Icon(Icons.delete_outline, color: Colors.grey,),
                          ),
                          contentPadding: const EdgeInsets.all(0),
                        ),
                      )
                  ),
                )
            ),
             */
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
                    if (widget.pinned == true) {
                      mixpanel!.track('brand_clients_pinned_off');
                    } else {
                      mixpanel!.track('brand_clients_pinned_on');
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
          const SliverToBoxAdapter(child: SizedBox(height: 10,)),
          isLoading ? SliverList(
            delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  dense: true,
                  leading: Shimmer.fromColors(
                    baseColor: AppColors.grey,
                    highlightColor: AppColors.grey.withOpacity(0.5),
                    child: Container(
                      height: MediaQuery.of(context).size.height*0.08,
                      width: MediaQuery.of(context).size.height*0.08,
                      decoration: const BoxDecoration(
                        color: AppColors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  title: Shimmer.fromColors(
                    baseColor: AppColors.grey,
                    highlightColor: AppColors.grey.withOpacity(0.5),
                    child: Container(
                      height: MediaQuery.of(context).size.height*0.03,
                      width: MediaQuery.of(context).size.width*0.02,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Shimmer.fromColors(
                        baseColor: AppColors.grey,
                        highlightColor: AppColors.grey.withOpacity(0.5),
                        child: Container(
                          height: MediaQuery.of(context).size.height*0.02,
                          width: MediaQuery.of(context).size.width*0.2,
                          decoration: const BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Shimmer.fromColors(
                    baseColor: AppColors.grey,
                    highlightColor: AppColors.grey.withOpacity(0.5),
                    child: Container(
                      height: MediaQuery.of(context).size.height*0.04,
                      width: MediaQuery.of(context).size.height*0.04,
                      decoration: const BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  onTap: null,
                ),
              );
            },
            childCount: widget.numClients == 0 ? 5 : widget.numClients,
            ),
          ) : filteredMembers.isNotEmpty ?
          SliverList(
            delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
              Usuario user = filteredMembers[index];
              return ListTile(
                leading: CircularImage(
                  size: MediaQuery.of(context).size.width*0.15,
                  image: user.imageUrl,
                  color: Theme.of(context).primaryColor,
                  borderWidth: 1.0,
                ),
                title: Text(
                  user.name!,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
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
                trailing: user.id! == currentUser.id ? IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.03,),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.all(0),
                  onPressed: false ? () {
                  } : null,
                ) : IconButton(
                  icon: Icon(Icons.chat_outlined, color: Theme.of(context).primaryColor,size: MediaQuery.of(context).size.height*0.03,),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.all(0),
                  onPressed: () async {
                    mixpanel!.track('brand_clients_chat_button');
                    types.User otherUser = types.User(
                      firstName: user.firstName,
                      lastName: user.lastName,
                      id: user.id!, // UID from Firebase Authentication
                      imageUrl: user.imageUrl,
                    );
                    final room = await FirebaseChatCore.instance.createRoom(otherUser,metadata: {
                      "trainer" + user.id!: user.isTrainer,
                      "trainer" + currentUser.id!: currentUser.isTrainer,
                      "active" + user.id!: false,
                      "active" + currentUser.id!: true,
                    });

                    bool? deleteRoom = await Navigator.push(
                      context,
                      CupertinoPageRoute<bool>(
                          builder: (context) => ChatPage(room: room)),).whenComplete(() async {
                      room.metadata!["active" + currentUser.id!] = false;
                      _roomDataService.updateRoom(room.id, room.metadata!);
                    });
                    if (!deleteRoom!) {
                      _roomDataService.deleteRoom(room.id);
                      mixpanel!.track('brand_clients_chat_empty');
                    }
                  },
                ),
                onTap: () async {
                  mixpanel!.track('brand_clients_profile_view');
                  var result = await Navigator.push(
                      context,
                      CupertinoPageRoute<bool?>(
                          builder: (context) => ProfileViewUser(
                            userID: user.id!,
                            viewOnly: false,
                          )
                      )
                  );
                  if (result == true) {
                    setState(() {
                      isLoading = true;
                    });
                    getAllUsers();
                  }
                },
              );
              },
              childCount: filteredMembers.length,               // 1000 list items
            ),
          ) : SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width*0.30,
                    child: Image.asset(Constants.emptyCalendar)
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.005),
                Text(AppLocalizations.of(context)!.noData, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
                SizedBox(height: MediaQuery.of(context).size.height*0.12),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8,)),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }

}