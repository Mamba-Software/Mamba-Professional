import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class TodosMiembros extends StatefulWidget {
  const TodosMiembros({Key? key}) : super(key: key);

  @override
  _TodosMiembrosState createState() => _TodosMiembrosState();
}

class _TodosMiembrosState extends State<TodosMiembros> {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // Boolean isUpdated
  bool isUpdated = false;
  // Search Controller
  var searchClientsController = TextEditingController();
  var searchTrainersController = TextEditingController();

  // Members Page
  List<Usuario> allClients = [];
  List<Usuario> filteredClients = [];
  List<Usuario> allTrainers = [];
  List<Usuario> filteredTrainers = [];

  Future<void> getAllUsers() async {
    await getAllTrainersFromBrand();
    await getAllClientsFromBrand();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getAllTrainersFromBrand() async {
    allTrainers = await _accessDatabase.getAllTrainersFromBrand(currentBrand.id!);
    filteredTrainers = allTrainers;
  }

  Future<void> getAllClientsFromBrand() async {
    allClients = await _accessDatabase.getAllClientsFromBrand(currentBrand.id!);
    filteredClients = allClients;
  }

  void filterSearchResults(String query, bool isTrainer) {
    List<Usuario> usersFiltered = [];
    if (isTrainer) {
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
    } else {
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
  }

  @override
  initState() {
    isLoading = true;
    getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body:  isLoading ?
      Center(child: LoadingViewPurple())
          :
      DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            //elevation: 0,
            title: Text(AppLocalizations.of(context)!.members, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                    onPressed: () async {
                      Clipboard.setData(new ClipboardData(text: currentBrand.id)).then((_){
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            icon: Container(),
                            iconRotationAngle: 0,
                            backgroundColor: Theme.of(context).accentColor,
                            message: AppLocalizations.of(context)!.copyCorrectCode,
                            textStyle: Styles.whiteTextStyle,
                          ),
                        );
                      });
                    },
                    icon: Icon(
                      Icons.group_add,
                      size: 30,
                    )
                ),
              )
            ],
            bottom: TabBar(
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3.0, color:Theme.of(context).accentColor, ),
              ),
              tabs: [
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_run, color: Theme.of(context).accentColor,),
                        SizedBox(width: 10,),
                        Text(AppLocalizations.of(context)!.clients, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.record_voice_over, color: Theme.of(context).accentColor,),
                        SizedBox(width: 10,),
                        Text(AppLocalizations.of(context)!.trainers, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),),
                      ],
                    ),
                  ),
                ),
              ],
          ),
          ),
          backgroundColor: Colors.transparent,
          body: TabBarView(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.04,left: MediaQuery.of(context).size.width*0.04, top: MediaQuery.of(context).size.width*0.03, bottom: MediaQuery.of(context).size.width*0.02),
                      child: TextField(
                        controller: searchClientsController,
                        onChanged: (value) {
                          // Filter trainers
                          filterSearchResults(value.toLowerCase(), false);
                        },
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.search,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              searchClientsController.clear();
                              filterSearchResults("", false);
                            },
                            icon: Icon(Icons.clear, color: Colors.grey,),
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                      )
                    ),
                    filteredClients.length != 0 ?
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(top: 0),
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: filteredClients.length,
                              itemBuilder: (context, index) {
                                Usuario user = filteredClients[index];
                                return Container(
                                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: ProfileViewUser(userID: user.id!)));
                                      },
                                      child: Container(
                                          height: MediaQuery.of(context).size.height*0.09,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.04, right:  MediaQuery.of(context).size.width*0.04),
                                                child: CircularImage(
                                                  size: MediaQuery.of(context).size.width*0.2,
                                                  image: user.imageUrl,
                                                  color: Theme.of(context).primaryColor,
                                                  borderWidth: 1.5,
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.40,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            user.name!,
                                                            style: Styles.purpleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                                                            textAlign: TextAlign.left,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.20),
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 30,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                    ),
                                  );
                              }
                          ),
                        ),
                      ) :
                      Padding(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.10,),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width*0.50,
                                child: Image.asset(Constants.emptyCalendar)
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.005),
                            Text(AppLocalizations.of(context)!.noMembersFound, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center,),
                          ],

                        ),
                      ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04, vertical: MediaQuery.of(context).size.width*0.02),
                        child: TextField(
                          controller: searchTrainersController,
                          onChanged: (value) {
                            // Filter trainers
                            filterSearchResults(value.toLowerCase(), true);
                          },
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.search,
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                searchTrainersController.clear();
                                filterSearchResults("", true);
                              },
                              icon: Icon(Icons.clear, color: Colors.grey,),
                            ),
                            contentPadding: EdgeInsets.all(0),
                          ),
                        )
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: filteredTrainers.length,
                            itemBuilder: (context, index) {
                              Usuario user = filteredTrainers[index];
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: ProfileViewUser(userID: user.id!)));
                                  },
                                  child: Container(
                                      height: MediaQuery.of(context).size.height*0.09,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.04, right:  MediaQuery.of(context).size.width*0.04),
                                            child: CircularImage(
                                              size: MediaQuery.of(context).size.width*0.2,
                                              image: user.imageUrl,
                                              color: Theme.of(context).primaryColor,
                                              borderWidth: 1.5,
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width*0.40,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        user.name!,
                                                        style: Styles.purpleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                                                        textAlign: TextAlign.left,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.20),
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              size: 30,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                              );
                            }

                        ),
                      ),
                    ),
                  ],
                ),
              ],
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