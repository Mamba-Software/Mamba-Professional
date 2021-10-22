import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

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
  // Title Controller
  var titleController = TextEditingController();
  String? titleString;
  // Description Controller
  var descriptionController = TextEditingController();
  String? descriptionString;
  // Starting Date and Time
  TextEditingController startDateController = TextEditingController();
  bool errorDate = false;
  // Members Page
  List<Usuario> allClients = [];
  List<Usuario> allTrainers = [];


  Future<void> getAllUsers() async {
    await getAllTrainersFromBrand();
    await getAllClientsFromBrand();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getAllTrainersFromBrand() async {
    allTrainers = await _accessDatabase.getAllTrainersFromBrand(currentBrand.id!);
  }

  Future<void> getAllClientsFromBrand() async {
    allClients = await _accessDatabase.getAllClientsFromBrand(currentBrand.id!);
  }

  @override
  initState() {
    isLoading = true;
    getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height*0.89,
          ),
          child: Center(child: LoadingViewPurple())
      )
        :
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height*0.89,
        ),
        padding: MediaQuery.of(context).viewInsets,
        child: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                toolbarHeight: MediaQuery.of(context).size.height*0.15,
                title: Text(AppLocalizations.of(context)!.members, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
                centerTitle: true,
                iconTheme: IconThemeData(
                  color: Styles.accent, //change your color here
                ),
                bottom: TabBar(
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 3.0, color:Theme.of(context).accentColor, ),
                  ),
                  unselectedLabelColor: Colors.redAccent,
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
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: allClients.length,
                            itemBuilder: (context, index) {
                              Usuario user = allClients[index];
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.02),
                                child: GestureDetector(
                                  onTap: () {
                                    print(user.id);
                                  },
                                  child: Container(
                                      height: MediaQuery.of(context).size.height*0.10,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.07),
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
                                                width: MediaQuery.of(context).size.width*0.30,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        user.name!,
                                                        style: Styles.purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                                                        textAlign: TextAlign.center,
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
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: allTrainers.length,
                            itemBuilder: (context, index) {
                              Usuario user = allTrainers[index];
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.02),
                                child: GestureDetector(
                                  onTap: () {
                                    print(user.id);
                                  },
                                  child: Container(
                                    height: MediaQuery.of(context).size.height*0.10,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.07),
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
                                              width: MediaQuery.of(context).size.width*0.30,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user.name!,
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
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





