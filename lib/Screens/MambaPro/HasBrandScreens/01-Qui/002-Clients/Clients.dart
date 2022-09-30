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

  List<Usuario> activeClients = [];
  List<Usuario> inactiveClients = [];

  var _orderFilter = OrderFilter();
  int filterClientsNumber = 0;
  int orderByClientsNumber = 0;
  int alphabeticOrder = 0;
  List<bool> filterByClients = [true, true];
  List<bool> orderByClients = [true, false, true, false];

  var chatUsers = [];

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

  String getUsersFullName(Usuario user) {
    return "${user.firstName} ${user.lastName}";
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
                                  IconButton(
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
                                          return StatefulBuilder(
                                            builder: (BuildContext context, StateSetter setStateBottom) {
                                              return FractionallySizedBox(
                                                heightFactor: 0.25,
                                                child: SizedBox(height: MediaQuery.of(context).size.height * 0.5,
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        /*
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
                                                                searchController.clear();
                                                                filterSearchResults("");
                                                                filterByClients[0] = !filterByClients[0];
                                                                setFilters();
                                                                filteredMembers = _orderFilter.orderFilter(filteredMembers, allClients, activeClients, inactiveClients, filterClientsNumber, orderByClientsNumber, alphabeticOrder);
                                                                allMembers = filteredMembers;
                                                              });
                                                              setState(() {

                                                              });

                                                          },
                                                          title: Text(
                                                              AppLocalizations.of(context)!.activeClients,
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
                                                               searchController.clear();
                                                               filterSearchResults("");
                                                               filterByClients[1] = !filterByClients[1];
                                                               setFilters();
                                                               filteredMembers = _orderFilter.orderFilter(filteredMembers, allClients, activeClients, inactiveClients, filterClientsNumber, orderByClientsNumber, alphabeticOrder);
                                                               allMembers = filteredMembers;
                                                             });
                                                             setState(() {

                                                             });

                                                          },
                                                          title: Text(
                                                              AppLocalizations.of(context)!.desactiveClient,
                                                              style: Theme.of(context).textTheme.bodyText1,
                                                              textAlign: TextAlign.left
                                                          ),
                                                          trailing: filterByClients[1] ? SizedBox(
                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                            child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                          ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                        ),
                                                        ListTile(
                                                          onTap: () {
                                                            setStateBottom(() {
                                                              searchController.clear();
                                                              filterSearchResults("");
                                                              orderByClients[2] = !orderByClients[2];
                                                              orderByClients[3] = !orderByClients[3];
                                                              setFilters();
                                                              filteredMembers = _orderFilter.orderFilter(filteredMembers, allClients, activeClients, inactiveClients, filterClientsNumber, orderByClientsNumber, alphabeticOrder);
                                                              allMembers = filteredMembers;
                                                            });
                                                            setState(() {

                                                            });
                                                          },
                                                          title: Text(
                                                              AppLocalizations.of(context)!.activeClients+" "+AppLocalizations.of(context)!.first.toLowerCase(),
                                                              style: Theme.of(context).textTheme.bodyText1,
                                                              textAlign: TextAlign.left
                                                          ),
                                                          trailing: orderByClients[2] ? SizedBox(
                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                            child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                          ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                        ),
                                                        ListTile(
                                                          onTap: () {
                                                            setStateBottom(() {
                                                              searchController.clear();
                                                              filterSearchResults("");
                                                              orderByClients[3] = !orderByClients[3];
                                                              orderByClients[2] = !orderByClients[2];
                                                              setFilters();
                                                              filteredMembers = _orderFilter.orderFilter(filteredMembers, allClients, activeClients, inactiveClients, filterClientsNumber, orderByClientsNumber, alphabeticOrder);
                                                              allMembers = filteredMembers;
                                                            });
                                                            setState(() {

                                                            });

                                                          },
                                                          title: Text(
                                                              AppLocalizations.of(context)!.desactiveClient+" "+AppLocalizations.of(context)!.first.toLowerCase(),
                                                              style: Theme.of(context).textTheme.bodyText1,
                                                              textAlign: TextAlign.left
                                                          ),
                                                          trailing: orderByClients[3] ? SizedBox(
                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                            child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                          ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                        ),
                                                        */

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
                                                              /*
                                                              searchController.clear();
                                                              filterSearchResults("");

                                                              setFilters();
                                                              filteredMembers = _orderFilter.orderFilter(filteredMembers, allTrainers, activeClients, inactiveClients, filterClientsNumber, orderByClientsNumber, alphabeticOrder);
                                                               */
                                                              orderByClients[0] = !orderByClients[0];
                                                              orderByClients[1] = !orderByClients[1];
                                                            });
                                                            setState(() {
                                                              // Sort Trainers Alphabetically
                                                              allMembers.sort((a, b) {
                                                                return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
                                                              });
                                                              // Sort Trainers Alphabetically
                                                              filteredMembers.sort((a, b) {
                                                                return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
                                                              });
                                                            });
                                                          },
                                                          title: Text(
                                                              AppLocalizations.of(context)!.alphabetAtoZ,
                                                              style: Theme.of(context).textTheme.bodyText1,
                                                              textAlign: TextAlign.left
                                                          ),
                                                          trailing: orderByClients[0] ? SizedBox(
                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                            child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                          ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                                                        ),
                                                        ListTile(
                                                          onTap: () {
                                                            setStateBottom(() {
                                                              orderByClients[0] = !orderByClients[0];
                                                              orderByClients[1] = !orderByClients[1];
                                                              /*
                                                              orderByClients[1] = !orderByClients[1];
                                                              orderByClients[0] = !orderByClients[0];
                                                              setFilters();
                                                              filteredMembers = _orderFilter.orderFilter(filteredMembers, allTrainers, activeClients, inactiveClients, filterClientsNumber, orderByClientsNumber, alphabeticOrder);
                                                               */
                                                            });
                                                            // Sort Trainers Alphabetically
                                                            allMembers.sort((a, b) {
                                                              return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
                                                            });
                                                            // Sort Trainers Alphabetically
                                                            filteredMembers.sort((a, b) {
                                                              return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
                                                            });
                                                            setState(() {
                                                              allMembers = List.from(allMembers.reversed);
                                                              filteredMembers = List.from(filteredMembers.reversed);
                                                            });
                                                          },
                                                          title: Text(
                                                              AppLocalizations.of(context)!.alphabetZtoA,
                                                              style: Theme.of(context).textTheme.bodyText1,
                                                              textAlign: TextAlign.left
                                                          ),
                                                          trailing: orderByClients[1] ? SizedBox(
                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                            child: Center(child: Icon(Icons.check, size:MediaQuery.of(context).size.width * 0.08,color: Theme.of(context).colorScheme.secondary)),
                                                          ) : SizedBox(width: MediaQuery.of(context).size.width * 0.15),
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
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.filter_list,
                                      color: AppColors.white,
                                      size: MediaQuery.of(context).size.width*0.07,
                                    ),
                                  ),
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
                  getUsersFullName(user),
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
                    }
                  },
                ),
                onTap: () async {
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

  void setFilters()
  {
    if (filterByClients[0] && filterByClients[1]) {
      // Active/Inactive Selected
      filterClientsNumber = 0;
    } else if (filterByClients[0]) {
      // Active Selected
      filterClientsNumber = 1;
    } else if(filterByClients[1]) {
      // Inactive Selected
      filterClientsNumber = 2;
    } else {
      // None Selected
      filterClientsNumber = 3;
    }
    // OrderBy
    if (orderByClients[0]) {
      // A-Z
      alphabeticOrder = 0;
    } else {
      // Z-A
      alphabeticOrder = 1;
    }
    if (orderByClients[2]) {
      // Active First
      orderByClientsNumber = 0;
    } else {
      // InActive First
      orderByClientsNumber = 1;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

}