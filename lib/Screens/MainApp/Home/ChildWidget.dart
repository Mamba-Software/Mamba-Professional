import 'package:flutter/material.dart';

import 'CercaDeTi/CercaDeTi.dart';
import 'Chat/Chat.dart';
import 'Perfil/Perfil.dart';
import 'TuMarca/TuMarca.dart';

enum AvailableNumber { First, Second, Third, Fourth }

class ChildWidget extends StatelessWidget {
  final AvailableNumber number;
  ChildWidget({Key? key, required this.number}) : super(key: key);
  // Navigation Index
  var _currentIndex;
  // Navigation Bar Tabs
  final navBarTabs= [
    CercaDeTi(),
    TuMarca(),
    Chat(),
    Perfil(),
  ];

  @override
  Widget build(BuildContext context) {

    if (number == AvailableNumber.First) {
      _currentIndex = 0;
    } else if (number == AvailableNumber.Second) {
      _currentIndex = 1;
    } else if (number == AvailableNumber.Third) {
      _currentIndex = 2;
    } else if (number == AvailableNumber.Fourth) {
      _currentIndex = 3;
    }

    return SafeArea(
      child: navBarTabs[_currentIndex]
    );
  }
}