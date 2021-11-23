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
    return Stack(
        children: <Widget>[
          Center(
            child: Container(
                height: MediaQuery.of(context).size.height*0.20,
                child: Image.asset(Constants.chatImage)
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.20),
              child: Text("¡No has empezado ningún chat!", style: Styles.purpleTextStyle.copyWith(color: Color(0xFF808080)), textAlign: TextAlign.center,),
            )
          ),
        ],
      );
  }
}
