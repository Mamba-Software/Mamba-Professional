import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DatabaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/Admin/AdminTool.dart';
import 'package:mamba_castelldefels/Screens/Admin/AdminFeedBack.dart';

import '../MainApp/Home/Perfil/PerfilModals/UserFeedBack.dart';


class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {

  // List strings
  List<String> Names = [
    'Usuaris','Errors','FeedBack'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Constants.logoExtended,
                  fit: BoxFit.contain,
                  height: 32,
                ),
                SizedBox(width: 15),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text("ADMIN", style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ],
            ),
            centerTitle: true,
            elevation: 10,
            automaticallyImplyLeading: false,
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
          ),
          backgroundColor: Colors.white,
          body: ListView.builder(
            itemCount: this.Names.length,
            itemBuilder: (context,int index) => EachList(this.Names[index], index),
          ),
      );
  }
}

class EachList extends StatelessWidget{
  final String name;
  final int index;
  EachList(this.name, this.index);
  @override
  Widget build(BuildContext context) {
    return new Card(
      margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25.0,
          child: new Text(name[0]),
          backgroundColor: Styles.mainColorTrans,
        ),
        trailing: Icon(Icons.east),
        title: Text(name,style: TextStyle(fontSize: 20.0),),
        subtitle: Text("Admin Tool"),
        onTap: (){
          this.returnPage(this.index, context);

        },
      ),
    );
  }

  returnPage(int index, BuildContext context)
  {
    switch(index)
    {
      case 0:
        Navigator.push(
            context,
            CupertinoPageRoute<Null>(
              builder: (context) => AdminTool(title: name),
              settings: RouteSettings(name: 'AdminTool'),
            )
        );
        break;

      case 1:

        break;

      case 2:
        Navigator.push(
            context,
            CupertinoPageRoute<Null>(
              builder: (context) => AdminFeedBack(title: name),
              settings: RouteSettings(name: 'AdminFeedBack'),
            )
        );
        break;

    }

  }
}