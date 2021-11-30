import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import '../../Styles.dart';
import '../CircularImage.dart';

class RequestConfirmationDialog extends StatefulWidget {
  final String text;
  final String userId;
  const RequestConfirmationDialog({Key? key, required this.text, required this.userId}) : super(key: key);

  @override
  _RequestConfirmationDialogState createState() => _RequestConfirmationDialogState();
}

class _RequestConfirmationDialogState extends State<RequestConfirmationDialog> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // User Requesting
  Usuario user = Usuario();

  @override
  void initState() {
    isLoading = true;
    getUser();
    super.initState();
  }

  // Gets the user info from firebase.
  void getUser() async {
    user = await _accessDatabase.getUserDetails(widget.userId);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          height: MediaQuery.of(context).size.height*0.3,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              LoadingViewPurple(),
            ],
          ),
        ),
      )
        :
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          padding: EdgeInsets.only(top: 80, bottom: 10, left: 10, right: 10),
          height: MediaQuery.of(context).size.height*0.3,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 24.0, right: 10, left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(widget.text, style: Styles.purpleTextStyle.copyWith(fontSize: 16, height: 1.5), textAlign: TextAlign.center,),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton.extended(
                          heroTag: "18",
                          label: Text(AppLocalizations.of(context)!.accept),
                          icon: Icon(Icons.check_circle_outline),
                          backgroundColor: Colors.green,
                          foregroundColor: Styles.white,
                          onPressed: () async {
                            Navigator.pop(context, true);
                          },
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width*0.01),
                        FloatingActionButton.extended(
                          heroTag: "19",
                          icon: Icon(Icons.cancel_outlined, size: 30,),
                          label: Text(AppLocalizations.of(context)!.reject),
                          backgroundColor: Colors.red,
                          foregroundColor: Styles.white,
                          onPressed: () async {
                            Navigator.pop(context, false);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                  bottom: 0,
                  top: -150,
                  child: Column(
                    children: <Widget>[
                      CircularImage(
                        size: MediaQuery.of(context).size.width*0.25,
                        image: user.imageUrl,
                        color: Theme.of(context).accentColor,
                        borderWidth: 2,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Expanded(
                        child: Text(
                          user.name!,
                          style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 23),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      );
  }
}