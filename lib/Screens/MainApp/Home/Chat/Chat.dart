// Flutter Libs
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingViewPurple(),
    );
  }
}
