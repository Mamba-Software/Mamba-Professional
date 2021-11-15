// Flutter Libs
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          Center(
            child: Container(
                width: 300,
                height: 300,
                child: Image.asset(Constants.notificationImage)
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Text("¡No tienes ninguna notificación!", style: Styles.purpleTextStyle.copyWith(color: Color(0xFF808080)), textAlign: TextAlign.center,),
            )
          ),
        ],
      );
  }
}
