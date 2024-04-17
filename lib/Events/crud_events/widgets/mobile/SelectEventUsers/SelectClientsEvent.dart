import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/JoinConfirmationDialogBonos.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/LeaveConfirmationDialogBonos.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba/data/Models/Usuario.dart';

class SelectClientsEvent extends StatefulWidget {
  List<Usuario> selectedUsers = [];
  int? maxClients;
  List<String>? selectedBonos = [];
  List<Bono> bonos = [];

  SelectClientsEvent(
      {super.key,
      required this.selectedUsers,
      this.maxClients,
      this.selectedBonos,
      required this.bonos});

  @override
  _SelectClientsEventState createState() => _SelectClientsEventState();
}

class _SelectClientsEventState extends State<SelectClientsEvent> {
  // Brand Data Service
  final _brandDataService = BrandDataService();
  final _purchaseDataService = PurchaseDataService();
  final _eventDataService = EventDataService();
  final _userDataService = UserDataService();
  // Boolean Loading
  bool isLoading = false;
  // Search Controller
  bool searchClicked = false;
  var searchController = TextEditingController();
  // Members Page
  List<Usuario> allClients = [];
  List<Usuario> filteredClients = [];
  List<Usuario> selectedClients = [];

  Future<void> getAllClients() async {
    if (widget.selectedBonos == null) {
      allClients = await _brandDataService.getBrandClients(currentBrand.id!);
    } else if (widget.selectedBonos!.isEmpty) {
      allClients = await _brandDataService.getBrandClients(currentBrand.id!);
    } else {
      allClients = await _purchaseDataService.getUsersByBonosAndActivePurchase(
          widget.selectedBonos!, currentBrand.id!);
    }
    // Sort Clients
    allClients.sort((a, b) {
      return a.name
          .toString()
          .toLowerCase()
          .compareTo(b.name.toString().toLowerCase());
    });
    filteredClients = allClients;
    // Selected Clients
    for (var user in widget.selectedUsers) {
      String id = user.id!;
      var index = filteredClients.indexWhere((element) => element.id! == id);
      if (index >= 0) {
        filteredClients[index].purchaseId = user.purchaseId;
        selectedClients.add(filteredClients[index]);
      } else {
        Usuario userAux = await _userDataService.getUserDetails(user.id!);
        userAux.purchaseId = user.purchaseId;
        filteredClients.add(userAux);
        selectedClients.add(userAux);
      }
    }
    // Return Future Delayed
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  void filterSearchResults(String query) {
    List<Usuario> usersFiltered = [];
    if (query.isNotEmpty || query != "") {
      for (var item in allClients) {
        if (item.name!.toLowerCase().startsWith(query)) {
          usersFiltered.add(item);
        }
      }
      setState(() {
        filteredClients = usersFiltered;
      });
    } else {
      setState(() {
        filteredClients = allClients;
      });
    }
  }

  String getUsersFullName(Usuario user) {
    return "${user.firstName} ${user.lastName}";
  }

  Color getColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return Theme.of(context).colorScheme.secondary;
    } else {
      return Colors.transparent;
    }
  }

  @override
  initState() {
    isLoading = true;
    getAllClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: isLoading
          ? Center(child: LoadingView())
          : DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Scaffold(
                appBar: AppBar(
                  title: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      filterSearchResults(value);
                    },
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context).textTheme.bodySmall,
                      hintText: AppLocalizations.of(context)!.search,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.0),
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: MediaQuery.of(context).size.width * 0.06,
                    ),
                    onPressed: () {
                      Navigator.pop(context, null);
                      selectedClients = [];
                    },
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        searchController.clear();
                        filterSearchResults("");
                      },
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                resizeToAvoidBottomInset: true,
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    selectedClients.isNotEmpty
                        ? Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05,
                            ),
                            color: Theme.of(context).colorScheme.background,
                            height: MediaQuery.of(context).size.height * 0.04,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.80,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: selectedClients.length,
                                      itemBuilder: (context, index) {
                                        Usuario user = selectedClients[index];
                                        return Center(
                                          child: Text(
                                            index == 0 &&
                                                        selectedClients
                                                                .length ==
                                                            1 ||
                                                    index ==
                                                        selectedClients.length -
                                                            1
                                                ? user.name!
                                                : "${user.name!}, ",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        );
                                      }),
                                ),
                                widget.maxClients != null
                                    ? SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.09,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              "( ${selectedClients.length}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(fontSize: 8),
                                            ),
                                            Text(
                                              " / ",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(fontSize: 8),
                                            ),
                                            Text(
                                              "${widget.maxClients} )",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(fontSize: 8),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.09,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              "( ${selectedClients.length} )",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(fontSize: 8),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                    Expanded(
                      child: Container(
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: filteredClients.length,
                            itemBuilder: (context, index) {
                              Usuario user = filteredClients[index];
                              DateTime dateJoined = DateTimeUtils()
                                  .formatStringToDateTimeDDMMYY(
                                      user.dateJoined!,
                                      Localizations.localeOf(context)
                                          .languageCode);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                child: ListTile(
                                  tileColor: selectedClients.contains(user)
                                      ? Theme.of(context)
                                          .colorScheme
                                          .background
                                          .withOpacity(0.5)
                                      : Theme.of(context)
                                          .scaffoldBackgroundColor,
                                  leading: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        CircularImage(
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          image: user.imageUrl,
                                          color: Theme.of(context).primaryColor,
                                          borderWidth: 1.0,
                                        ),
                                        Positioned(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07,
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07,
                                          child: Theme(
                                            data: ThemeData(
                                                unselectedWidgetColor:
                                                    Colors.transparent),
                                            child: Checkbox(
                                              checkColor: Colors.white,
                                              tristate: false,
                                              fillColor: MaterialStateProperty
                                                  .resolveWith(getColor),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              value: selectedClients
                                                  .contains(user),
                                              shape: const CircleBorder(
                                                  side: BorderSide.none),
                                              onChanged: (bool? value) {},
                                            ),
                                          ),
                                        ),
                                      ]),
                                  title: Text(
                                    getUsersFullName(user),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            user.lastEventAt == null
                                                ? AppLocalizations.of(context)!
                                                    .lastActiveIn(DateTimeUtils()
                                                        .formatDateTimeToStringMMMYYYY(
                                                            dateJoined,
                                                            Localizations
                                                                    .localeOf(
                                                                        context)
                                                                .languageCode))
                                                : AppLocalizations.of(context)!
                                                    .lastActiveIn(DateTimeUtils()
                                                        .formatDateTimeToStringMMMYYYY(
                                                            user.lastEventAt!
                                                                .toDate(),
                                                            Localizations
                                                                    .localeOf(
                                                                        context)
                                                                .languageCode)),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    //if (widget.selectedBonos!.isEmpty ||
                                    if (user.purchaseId == "") {
                                      var selectedUsers = selectedClients;
                                      if (selectedUsers.contains(user)) {
                                        selectedUsers.remove(user);
                                        setState(() {
                                          selectedClients = selectedUsers;
                                        });
                                      } else {
                                        if (widget.maxClients != null) {
                                          if (selectedClients.length <
                                              widget.maxClients!) {
                                            if (selectedUsers.any(
                                                (obj) => obj.id == user.id)) {
                                              selectedUsers.removeWhere(
                                                  (obj) => obj.id == user.id);
                                            }
                                            selectedUsers.add(user);
                                            setState(() {
                                              selectedClients = selectedUsers;
                                            });
                                          }
                                        } else {
                                          if (selectedUsers.any(
                                              (obj) => obj.id == user.id)) {
                                            selectedUsers.removeWhere(
                                                (obj) => obj.id == user.id);
                                          }
                                          selectedUsers.add(user);
                                          setState(() {
                                            selectedClients = selectedUsers;
                                          });
                                        }
                                      }
                                    } else {
                                      var selectedUsers = selectedClients;
                                      if (selectedUsers.contains(user)) {
                                        var result = await showDialog(
                                            context: context,
                                            builder: (_) {
                                              return LeaveConfirmationDialogBonos(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .leaveEventConfirmation,
                                                brand: currentBrand,
                                                bonos: widget.bonos,
                                                purchaseId: user.purchaseId!,
                                                user: user,
                                              );
                                            });
                                        if (result != null && result) {
                                          selectedUsers.remove(user);
                                          setState(() {
                                            selectedClients = selectedUsers;
                                          });
                                        }
                                      } else {
                                        var result = await showDialog(
                                            context: context,
                                            builder: (_) {
                                              return JoinConfirmationDialogBonos(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .joinEventConfirmation,
                                                brand: currentBrand,
                                                bonos: widget.bonos,
                                                userId: user.id!,
                                              );
                                            });
                                        if (result != null && result[0]) {
                                          user.purchaseId = result[1];
                                          selectedUsers.add(user);
                                          setState(() {
                                            selectedClients = selectedUsers;
                                          });
                                        }
                                      }
                                    }
                                  },
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width * 0.17,
                    width: MediaQuery.of(context).size.width * 0.17,
                    child: FloatingActionButton(
                      heroTag: "84",
                      onPressed: () {
                        Navigator.pop(context, selectedClients);
                      },
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Icon(
                        Icons.person_add,
                        size: MediaQuery.of(context).size.width * 0.07,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
