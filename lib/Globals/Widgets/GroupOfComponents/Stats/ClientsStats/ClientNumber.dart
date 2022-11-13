import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../Styles/AppColors/AppColors.dart';

class ClientNumber extends StatefulWidget {
  List<Usuario> users;
  List<Usuario> allUsers;
  List<Usuario> activeUsers;

  ClientNumber({
    required this.users,
    required this.allUsers,
    required this.activeUsers,
    Key? key,
  }) : super(key: key);

  @override
  ClientNumberState createState() => ClientNumberState();
}

class ClientNumberState extends State<ClientNumber> {
  bool isLoading = true;
  List <Usuario> filteredUsers = [], activeUsers = [];
  String clientsUpdated = '0';


  @override
  void initState() {
    filteredUsers = widget.users;
    activeUsers = widget.activeUsers;
    mountStat();
    isLoading = false;
    super.initState();
  }

  @override
  void didUpdateWidget(ClientNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredUsers = widget.users;
    activeUsers = widget.activeUsers;
    mountStat();
  }


  void mountStat()
  {
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? LoadingView() :   Column(
      children: [
        Column(
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*0.43,
                        height: MediaQuery.of(context).size.width*0.25,
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('+' + filteredUsers.length.toString(),
                              style: Theme.of(context).textTheme.headline4?.copyWith(color: AppColors.mainColor, fontSize: 30, fontWeight: FontWeight.normal),),
                            Text(AppLocalizations.of(context)!.newClient),
                            Text(AppLocalizations.of(context)!.clients.toLowerCase()),
                          ]
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.43,
                      height: MediaQuery.of(context).size.width*0.25,
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(activeUsers.length.toString(),
                              style: Theme.of(context).textTheme.headline4?.copyWith(color: AppColors.mainColor, fontSize: 30, fontWeight: FontWeight.normal),),
                            Text(AppLocalizations.of(context)!.actives),
                            Text(AppLocalizations.of(context)!.atThisMoment)
                          ]
                      ),
                    ),
                  ],
                ),
              SizedBox(height: MediaQuery.of(context).size.height*0.015),
              Container(
                width: MediaQuery.of(context).size.width*0.90,
                height: MediaQuery.of(context).size.width*0.15,
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.allUsers.length.toString() + ' ',
                        style: Theme.of(context).textTheme.headline4?.copyWith(color: AppColors.mainColor, fontSize: 30, fontWeight: FontWeight.normal),),
                      Text(AppLocalizations.of(context)!.clients + ' ' + AppLocalizations.of(context)!.totals),
                    ]
                ),
              ),
            ],
          ),


      ],
    );

  }

}
