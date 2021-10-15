// Flutter Libs
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
                width: 300,
                height: 300,
                child: Image.asset(Constants.chatImage)
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Text("¡No has empezado ningún chat!", style: Styles.purpleTextStyle.copyWith(color: Color(0xFF808080)), textAlign: TextAlign.center,),
            )
          ),
        ],
      ),
    );
  }
}
