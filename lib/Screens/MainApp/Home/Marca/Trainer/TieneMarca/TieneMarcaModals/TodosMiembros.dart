import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';

class TodosMiembros extends StatefulWidget {
  const TodosMiembros({Key? key}) : super(key: key);

  @override
  _TodosMiembrosState createState() => _TodosMiembrosState();
}

class _TodosMiembrosState extends State<TodosMiembros> {

  @override
  Widget build(BuildContext context) {
    return Container(
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
              bottom: TabBar(
                unselectedLabelColor: Colors.redAccent,
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.record_voice_over, color: Styles.accent,),
                          SizedBox(width: 10,),
                          Text(AppLocalizations.of(context)!.trainer, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
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
                          Icon(Icons.directions_run, color: Styles.accent,),
                          SizedBox(width: 10,),
                          Text(AppLocalizations.of(context)!.client, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(AppLocalizations.of(context)!.members, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
              centerTitle: true,
              iconTheme: IconThemeData(
                color: Styles.accent, //change your color here
              ),
            ),
            backgroundColor: Colors.transparent,
            body: const TabBarView(
              children: [
                Icon(Icons.record_voice_over),
                Icon(Icons.directions_run),
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




