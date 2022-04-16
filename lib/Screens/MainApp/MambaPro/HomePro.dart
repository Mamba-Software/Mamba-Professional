import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:graphic/graphic.dart';

class HomePro extends StatefulWidget {
  String brandId;
  int numClients;
  int numTrainers;

  HomePro({Key? key, required this.brandId, required this.numTrainers, required this.numClients}) : super(key: key);

  @override
  _HomePro createState() => _HomePro();
}

class _HomePro extends State<HomePro> {

  // Boolean Loading
  bool isLoading = true;

  var data = [
    {'category': 'Shirts', 'sales': 5},
    {'category': 'Cardigans', 'sales': 20},
    {'category': 'Chiffons', 'sales': 36},
    {'category': 'Pants', 'sales': 10},
    {'category': 'Heels', 'sales': 10},
    {'category': 'Socks', 'sales': 20},
  ];

  @override
  initState() {
    isLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.transparent,
          body:  Container(
              child: Chart(
                data: data,
                variables: {
                  'category': Variable(
                    accessor: (Map map) => map['category'] as String,
                  ),
                  'sales': Variable(
                    accessor: (Map map) => map['sales'] as num,
                  ),
                },
                elements: [IntervalElement()],
                axes: [
                  Defaults.horizontalAxis,
                  Defaults.verticalAxis,
                ],
              )
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
  }

}