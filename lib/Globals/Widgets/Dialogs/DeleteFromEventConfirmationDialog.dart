import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import '../../Styles.dart';
import '../CircularImage.dart';

class DeleteFromEventConfirmationDialog extends StatefulWidget {
  final String text;
  final String userId;
  const DeleteFromEventConfirmationDialog({Key? key, required this.text, required this.userId}) : super(key: key);

  @override
  _DeleteFromEventConfirmationDialogState createState() => _DeleteFromEventConfirmationDialogState();
}

class _DeleteFromEventConfirmationDialogState extends State<DeleteFromEventConfirmationDialog> {
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
          height: MediaQuery.of(context).size.height*0.4,
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
          height: MediaQuery.of(context).size.height*0.4,
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
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            elevation: 4.0,
                            backgroundColor: Colors.red,
                            fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.delete,
                            style: TextStyle(color: Colors.white),
                          ),
                          icon: Icon(Icons.delete_outline, size: MediaQuery.of(context).size.width*0.07, color: Colors.white,),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width*0.01),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            elevation: 4.0,
                            backgroundColor: Colors.black,
                            fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(color: Colors.white),
                          ),
                          icon: Icon(Icons.cancel_outlined, size: MediaQuery.of(context).size.width*0.07, color: Colors.white,),
                          onPressed: () {
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
                      SizedBox(height: MediaQuery.of(context).size.height*0.03),
                      Container(
                        width: MediaQuery.of(context).size.width*0.9,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  user.name!,
                                  style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 23),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
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