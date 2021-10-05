import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';


class AdminTool extends StatefulWidget {
  final String title;
  const AdminTool({Key? key,required this.title}) : super(key: key);

  @override
  _AdminToolState createState() => _AdminToolState();
}

class _AdminToolState extends State<AdminTool> {

  //DataBase Access
  var _accessDatabase = new DatabaseAccess();
  List<Usuario> usersList = [];
  List<Usuario> fullusersList = [];
  bool isLoading = true;
  bool filteredBySearcher = false;
  bool filtredByTrainerClient = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getUsersList();
  }

  Future<void> getUsersList() async {
    Stream<QuerySnapshot> snapshot = await _accessDatabase.getAllUsers();
     await snapshot.forEach((field) async {
      field.docs.asMap().forEach((index, value) {
        //usersList.add(field.docs[index]["name"]);
        fullusersList.add(Usuario.fromObject(field.docs[index], field.docs[index].id));
        usersList.add(Usuario.fromObject(field.docs[index], field.docs[index].id));
      });
      setState(() {
        isLoading = false;
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
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
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                  //controller: editingController,
                  decoration: InputDecoration(
                      labelText: "Look for people!",
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)))),
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
          ]
        ),
    );

  }

  List<Usuario> documentsToUsers(List<DocumentSnapshot> documents) {
    List<Usuario> users = [];
    for(int i = 0; i < documents.length; i++) {
      users.add(Usuario.fromObject(documents[i], documents[i].id));
    }
    return users;
  }

  void filterClientTrainer(bool TrainerFilter) {

    List<Usuario> usersFiltered = [];

    if(filteredBySearcher == true) {
      if (TrainerFilter) {
        for (var item in usersList) {
          if (item.isTrainer == true) {
            usersFiltered.add(item);
          }
        }
      }

      else {
        for (var item in usersList) {
          if (item.isTrainer == false) {
            usersFiltered.add(item);
          }
        }
      }
    }

    else {
      if (TrainerFilter) {
        for (var item in fullusersList) {
          if (item.isTrainer == true) {
            usersFiltered.add(item);
          }
        }
      }

      else {
        for (var item in fullusersList) {
          if (item.isTrainer == false) {
            usersFiltered.add(item);
          }
        }
      }
    }



    setState(() {
      usersList.clear();
      usersList.addAll(usersFiltered);
      //print(usersList[1].name);
    });

      filtredByTrainerClient = true;
      return;
    }

  void filterSearchResults(String query) {
    List<Usuario> usersFiltered = [];
    if(filtredByTrainerClient == false) {
      if (query.isNotEmpty) {
        for (var item in fullusersList) {
          if (item.name!.startsWith(query)) {
            usersFiltered.add(item);
          }
        }

        filteredBySearcher = true;

        setState(() {
          usersList.clear();
          usersList.addAll(usersFiltered);
          //print(usersList[1].name);
        });

        return;
      } else {
        filteredBySearcher = false;
        setState(() {
          usersList.clear();
          usersList.addAll(fullusersList);
        });
      }
    }
    else {
      if (query.isNotEmpty) {
        for (var item in usersList) {
          if (item.name!.startsWith(query)) {
            usersFiltered.add(item);
          }
        }

        filteredBySearcher = true;

        setState(() {
          usersList.clear();
          usersList.addAll(usersFiltered);
          //print(usersList[1].name);
        });

        return;
      } else {
        filteredBySearcher = false;
        setState(() {
          usersList.clear();
          usersList.addAll(fullusersList);
        });
      }
    }
    return;
  }

  void refresh() {
    setState(() {
      filteredBySearcher = false;
      usersList.clear();
      usersList.addAll(fullusersList);
    });
  }

}



class UserTile extends StatelessWidget{
  final Usuario user;
  UserTile(this.user);
  @override
  Widget build(BuildContext context) {
    return new Card(
      margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: ListTile(
        leading: CircularImage(size: MediaQuery.of(context).size.width*0.15, image: user.imageUrl, borderWidth: 3, color: Colors.red),
        trailing: Icon(Icons.east),
        title: Text(user.name!,style: TextStyle(fontSize: 20.0),),
        subtitle: Text("Admin Tool"),
        onTap: (){
        },
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
