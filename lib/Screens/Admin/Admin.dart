import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/AdminService/ScriptsService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Screens/Admin/AdminTool.dart';
import 'package:mamba_castelldefels/Screens/Admin/AdminFeedBack.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  // List strings
  List<String> Names = ['Usuaris', 'Errors', 'FeedBack', 'Migration'];

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
            const SizedBox(width: 15),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text("ADMIN",
                  style: Styles.whiteTextStyle
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 10,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: Names.length,
        itemBuilder: (context, int index) => EachList(Names[index], index),
      ),
    );
  }
}

class EachList extends StatelessWidget {
  // Script Service
  final _script = ScriptsDatabaseService();
  final String name;
  final int index;
  EachList(this.name, this.index, {super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25.0,
          backgroundColor: Styles.mainColorTrans,
          child: Text(name[0]),
        ),
        trailing: const Icon(Icons.east),
        title: Text(
          name,
          style: const TextStyle(fontSize: 20.0),
        ),
        subtitle: const Text("Admin Tool"),
        onTap: () {
          returnPage(index, context);
        },
      ),
    );
  }

  returnPage(int index, BuildContext context) async {
    switch (index) {
      case 0:
        Navigator.push(
            context,
            CupertinoPageRoute<void>(
              builder: (context) => AdminTool(title: name),
              settings: const RouteSettings(name: 'AdminTool'),
            ));
        break;

      case 1:
        break;

      case 2:
        Navigator.push(
            context,
            CupertinoPageRoute<void>(
              builder: (context) => AdminFeedBack(title: name),
              settings: const RouteSettings(name: 'AdminFeedBack'),
            ));
        break;
      case 3:
        var result = await _script.getStatisticsSpecific();
        print("RESULT: $result");
        break;
    }
  }
}
