import 'package:flutter/material.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:mamba/data/Models/Usuario.dart';

class SelectTrainersEvent extends StatefulWidget {
  List<Usuario> selectedTrainers = [];

  SelectTrainersEvent({super.key, required this.selectedTrainers});

  @override
  _SelectTrainersEventState createState() => _SelectTrainersEventState();
}

class _SelectTrainersEventState extends State<SelectTrainersEvent> {
  // Brand Data Service
  final _brandDataService = BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  // Search Controller
  bool searchClicked = false;
  var searchController = TextEditingController();
  // Members Page
  List<Usuario> allTrainers = [];
  List<Usuario> filteredTrainers = [];
  List<Usuario> selectedTrainers = [];

  Future<void> getAllTrainers() async {
    allTrainers = await _brandDataService.getBrandTrainers(currentBrand.id!);
    // Sort Clients
    allTrainers.sort((a, b) {
      return a.name
          .toString()
          .toLowerCase()
          .compareTo(b.name.toString().toLowerCase());
    });
    filteredTrainers = allTrainers;
    // Selected Clients
    for (var user in widget.selectedTrainers) {
      String id = user.id!;
      var index = filteredTrainers.indexWhere((element) => element.id! == id);
      selectedTrainers.add(filteredTrainers[index]);
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
      for (var item in allTrainers) {
        if (item.name!.toLowerCase().startsWith(query)) {
          usersFiltered.add(item);
        }
      }
      setState(() {
        filteredTrainers = usersFiltered;
      });
    } else {
      setState(() {
        filteredTrainers = allTrainers;
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
    getAllTrainers();
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
                      hintText: context.l10n.search,
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
                      selectedTrainers = [];
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
                    selectedTrainers.isNotEmpty
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
                                      itemCount: selectedTrainers.length,
                                      itemBuilder: (context, index) {
                                        Usuario user = selectedTrainers[index];
                                        return Center(
                                          child: Text(
                                            index == 0 &&
                                                        selectedTrainers
                                                                .length ==
                                                            1 ||
                                                    index ==
                                                        selectedTrainers
                                                                .length -
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
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.09,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "( ${selectedTrainers.length} )",
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
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: filteredTrainers.length,
                          itemBuilder: (context, index) {
                            Usuario user = filteredTrainers[index];
                            DateTime dateJoined = DateTimeUtils()
                                .formatStringToDateTimeDDMMYY(
                                    user.dateJoined!,
                                    Localizations.localeOf(context)
                                        .languageCode);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: ListTile(
                                tileColor: selectedTrainers.contains(user)
                                    ? Theme.of(context)
                                        .colorScheme
                                        .background
                                        .withOpacity(0.5)
                                    : Theme.of(context).scaffoldBackgroundColor,
                                leading: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircularImage(
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        image: user.imageUrl,
                                        color: Theme.of(context).primaryColor,
                                        borderWidth: 1.0,
                                      ),
                                      Positioned(
                                        top: MediaQuery.of(context).size.width *
                                            0.07,
                                        left:
                                            MediaQuery.of(context).size.width *
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
                                            value:
                                                selectedTrainers.contains(user),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.lastEventAt == null
                                          ? context.l10n.lastActiveIn(
                                              DateTimeUtils()
                                                  .formatDateTimeToStringMMMYYYY(
                                                      dateJoined,
                                                      Localizations.localeOf(
                                                              context)
                                                          .languageCode))
                                          : context.l10n.lastActiveIn(
                                              DateTimeUtils()
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
                                onTap: () {
                                  var selectedUsers = selectedTrainers;
                                  if (selectedUsers.contains(user)) {
                                    selectedUsers.remove(user);
                                    setState(() {
                                      selectedTrainers = selectedUsers;
                                    });
                                  } else {
                                    selectedUsers.add(user);
                                    setState(() {
                                      selectedTrainers = selectedUsers;
                                    });
                                  }
                                },
                              ),
                            );
                          }),
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
                      heroTag: "64",
                      onPressed: () {
                        Navigator.pop(context, selectedTrainers);
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
