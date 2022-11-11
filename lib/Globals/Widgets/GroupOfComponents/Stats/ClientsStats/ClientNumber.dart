import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

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
                      width: MediaQuery.of(context).size.width*0.4,
                        height: MediaQuery.of(context).size.width*0.25,
                        decoration: BoxDecoration(
                          color: AppColors.darkGrey,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('+' + filteredUsers.length.toString(),
                              style: Theme.of(context).textTheme.headline4?.copyWith(color: AppColors.mainColor, fontSize: 30, fontWeight: FontWeight.normal),),
                            Text('Altas'),
                            Text('Clientes'),
                          ]
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      height: MediaQuery.of(context).size.width*0.25,
                      decoration: BoxDecoration(
                        color: AppColors.darkGrey,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('+' + activeUsers.length.toString(),
                              style: Theme.of(context).textTheme.headline4?.copyWith(color: AppColors.mainColor, fontSize: 30, fontWeight: FontWeight.normal),),
                            Text('Clientes'),
                            Text('Activos en estas fechas')
                          ]
                      ),
                    ),
                  ],
                ),
              SizedBox(height: MediaQuery.of(context).size.height*0.02),
              Container(
                width: MediaQuery.of(context).size.width*0.90,
                height: MediaQuery.of(context).size.width*0.15,
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.allUsers.length.toString() + ' ',
                        style: Theme.of(context).textTheme.headline4?.copyWith(color: AppColors.mainColor, fontSize: 30, fontWeight: FontWeight.normal),),
                      Text('Clientes totales'),
                    ]
                ),
              ),
            ],
          ),


      ],
    );

  }

}
