import 'package:flutter/material.dart';
import 'Chat/Chat.dart';
import 'Perfil/Perfil.dart';
import 'Marca/Marca.dart';

enum AvailableNumber { First, Second, Third}

class ChildWidget extends StatelessWidget {
  final AvailableNumber number;
  ChildWidget({Key? key, required this.number}) : super(key: key);
  // Navigation Index
  var _currentIndex;
  // Navigation Bar Tabs
  final navBarTabs = [
    Perfil(),
    Marca(),
    Chat(),
  ];

  @override
  Widget build(BuildContext context) {

    if (number == AvailableNumber.First) {
      _currentIndex = 0;
    } else if (number == AvailableNumber.Second) {
      _currentIndex = 1;
    } else if (number == AvailableNumber.Third) {
      _currentIndex = 2;
    }
    return SafeArea(
      child: navBarTabs[_currentIndex]
    );
  }
}