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

  @override
  void initState() {
    super.initState();
  }

 /* Future<void> getUsersList() async {
    usersList = await _accessDatabase.getAllUsers();
    print(usersList.length);
    print(usersList);
  }*/

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
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
          ),
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
          ]
        ),
     );
  }

  List<Usuario> documentsToUsers(List<DocumentSnapshot> documents) {
    List<Usuario> users = [];
    for(int i = 0; i < documents.length; i++) {
      users.add(Usuario.fromObject(documents[i], documents[i].id));
    }
    print(usersList);
    return users;
  }

  void filterSearchResults(String query) {
    List<Usuario> usersFiltered = [];
    if(query.isNotEmpty) {
      usersList.forEach((item) {
        if (item.name!.contains(query)) {
          usersFiltered.add(item);
        }
      });

      /*setState(() {
        usersList.clear();
        usersList.addAll(usersFiltered);
        //print(usersList[1].name);
      });*/

      return;
    }
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

 */
