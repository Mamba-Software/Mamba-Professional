import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';

class AdminTool extends StatefulWidget {
  final String title;

  const AdminTool({Key? key, required this.title}) : super(key: key);

  @override
  _AdminToolState createState() => _AdminToolState();
}

class _AdminToolState extends State<AdminTool> {
  List<Usuario> usersListTrainer = [];
  List<Usuario> usersListClient = [];
  List<Usuario> usersList = [];
  List<Usuario> fullusersListTrainer = [];
  List<Usuario> fullusersListClient = [];
  bool isLoading = true;
  bool filteredBySearcher = false;
  bool filtredByTrainerClient = false;
  var editingController = TextEditingController();
  var tabViewController;

  @override
  void initState() {
    super.initState();
    isLoading = true;
  }

  /*
  Future<void> getUsersList() async {
    Stream<QuerySnapshot> snapshot = await _accessDatabase.getAllUsers();
    await snapshot.forEach((field) async {
      field.docs.asMap().forEach((index, value) {
        var user = Usuario.fromObjectAllData(field.docs[index], field.docs[index].id);
        if (user.isTrainer!) {
          usersListTrainer.add(user);
        } else {
          usersListClient.add(user);
        }
        fullusersListTrainer = usersListTrainer;
        fullusersListClient = usersListClient;
        //usersList.add(field.docs[index]["name"]);
        //fullusersList.add(Usuario.fromObjectAllData(field.docs[index], field.docs[index].id));
        //usersList.add(Usuario.fromObjectAllData(field.docs[index], field.docs[index].id));
      });
      setState(() {
        isLoading = false;
      });
      print(usersListClient);
      print(usersListTrainer);
    });
  }
   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: Styles.whiteTextStyle
                .copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        elevation: 10,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.70,
              ),
              padding: MediaQuery.of(context).viewInsets,
              child: DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    title: SizedBox(
                      height: 43,
                      child: TextFormField(
                        controller: editingController,
                        onChanged: (value) {
                          filterSearchResults(value);
                        },
                        decoration: InputDecoration(
                            labelText: "Look for people!",
                            hintText: "Search",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)))),
                      ),
                    ),
                    centerTitle: true,
                    bottom: TabBar(
                      onTap: (val) {
                        //filterClientTrainer(val);
                      },
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.record_voice_over,
                                  color: Styles.accent,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.trainer,
                                  style: Styles.purpleTextStyle
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
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
                                Icon(
                                  Icons.directions_run,
                                  color: Styles.accent,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.client,
                                  style: Styles.purpleTextStyle
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  body: TabBarView(
                    controller: tabViewController,
                    children: [
                      isLoading
                          ? LoadingView()
                          : Column(
                              children: [
                                ListView.builder(
                                  itemCount: usersListTrainer.length,
                                  itemBuilder: (context, int index) {
                                    //filterClientTrainer(true);
                                    return UserTile(usersListTrainer[index]);
                                  },
                                  shrinkWrap: true,
                                ),
                              ],
                            ),
                      isLoading
                          ? LoadingView()
                          : Column(
                              children: [
                                ListView.builder(
                                  itemCount: usersListClient.length,
                                  itemBuilder: (context, int index) {
                                    //filterClientTrainer(false);
                                    return UserTile(usersListClient[index]);
                                  },
                                  shrinkWrap: true,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
    );
  }

  /*
  Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextButton(
                child: Text('Refresh', style: TextStyle(fontSize: 20.0),),
                onPressed: (){
                  refresh();
                },
              ),
            ),

  Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: InkResponse(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_run,
                          size: 45,
                          color: Styles.accent,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0.0),
                          child: Text(
                              "Client",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Styles.accent
                              )
                          ),
                        ),
                      ],
                    ),
                    onTap: () => {
                      setState(() {
                        filterClientTrainer(false);
                      }),
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: InkResponse(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.record_voice_over,
                          size: 45,
                          color: Styles.accent,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0.0),
                          child: Text(
                              "Trainer",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Styles.accent
                              )
                          ),
                        ),
                      ],
                    ),
                    onTap: () => {
                      setState(() {
                          filterClientTrainer(true);
                      }),
                    },
                  ),
                ),
              ],
            ),
            isLoading ?
            LoadingView()
                :
            Column(
              children: [
                ListView.builder(
                  itemBuilder: (context, int index) => UserTile(usersList[index]),
                  itemCount: usersList.length,
                  shrinkWrap: true,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextButton(
                child: Text('Refresh', style: TextStyle(fontSize: 20.0),),
                onPressed: (){
                  refresh();
                },
              ),
            ),
   */

  List<Usuario> documentsToUsers(List<DocumentSnapshot> documents) {
    List<Usuario> users = [];
    for (int i = 0; i < documents.length; i++) {
      //users.add(Usuario.fromObjectAllData(documents[i].id, documents[i]));
    }
    return users;
  }

  /*void filterClientTrainer(int TrainerFilter) {

    List<Usuario> usersFiltered = [];
    List<Usuario> usersToAnalyze = [];

    if(filteredBySearcher == true) usersToAnalyze = usersList;
    else usersToAnalyze = fullusersList;

    if (TrainerFilter == 0) {
      for (var item in usersToAnalyze) {
        if (item.isTrainer == true) {
            usersFiltered.add(item);
        }
      }
    }

    else {
      for (var item in usersToAnalyze) {
        if (item.isTrainer == false) {
          usersFiltered.add(item);
        }
      }
    }

    usersList.clear();
    usersList.addAll(usersFiltered);

    filtredByTrainerClient = true;
    return;

  }*/

  void filterSearchResults(String query) {
    List<Usuario> usersFiltered = [];
    List<Usuario> usersToAnalyze = [];

    if (filtredByTrainerClient == false)
      usersToAnalyze = usersListTrainer;
    else
      usersToAnalyze = usersListTrainer;

    if (query.isNotEmpty) {
      for (var item in usersToAnalyze) {
        if (item.name!.startsWith(query)) {
          usersFiltered.add(item);
        }
      }

      filteredBySearcher = true;
      usersListClient.clear();
      usersListClient.addAll(usersFiltered);

      return;
    } else {
      filteredBySearcher = false;
      usersListClient.clear();
      usersListClient.addAll(fullusersListTrainer);
    }
  }

  void refresh() {
    setState(() {
      filteredBySearcher = false;
      usersList.clear();
      usersList.addAll(fullusersListClient);
      editingController.text = "";
    });
  }
}

class UserTile extends StatelessWidget {
  final Usuario user;

  UserTile(this.user);

  @override
  Widget build(BuildContext context) {
    return new Card(
      margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: ListTile(
        leading: CircularImage(
            size: MediaQuery.of(context).size.width * 0.15,
            image: user.imageUrl,
            borderWidth: 3,
            color: Colors.red),
        trailing: Icon(Icons.east),
        title: Text(
          user.name!,
          style: TextStyle(fontSize: 20.0),
        ),
        subtitle: Text("Admin Tool"),
        onTap: () {},
      ),
    );
  }
}

/*
 StreamBuilder<QuerySnapshot>(
                stream: _accessDatabase.getAllUsers(),
                builder: (context, snapshot) {
                  //if(snapshot == null || snapshot.data == null || snapshot.data.documents == null ) return EmptyView();
                  //else if(snapshot.hasError) return ErrorView();
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingView();
                  } else {
                    usersList = documentsToUsers(snapshot.data!.docs);
                    return Column(
                      children: [
                        ListView.builder(
                          itemBuilder: (context, int index) => UserTile(usersList[index]),
                          itemCount: usersList.length,
                          shrinkWrap: true,
                        ),
                      ],
                    );
                  }
                }
            ),
 */
