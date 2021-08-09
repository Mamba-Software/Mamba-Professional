import 'package:flutter/material.dart';
import 'features/login/Login.dart';

void main() {
  runApp(Mamba());
}

class Mamba extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}

