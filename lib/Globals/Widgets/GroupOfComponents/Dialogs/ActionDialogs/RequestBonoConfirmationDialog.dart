import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';

class RequestBonoConfirmationDialog extends StatefulWidget {
  final String text;
  final String userId;
  const RequestBonoConfirmationDialog({Key? key, required this.text, required this.userId}) : super(key: key);

  @override
  _RequestBonoConfirmationDialogState createState() => _RequestBonoConfirmationDialogState();
}

class _RequestBonoConfirmationDialogState extends State<RequestBonoConfirmationDialog> {
  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  // Boolean Loading
  bool isLoading = false;
  // User Requesting
  Usuario user = Usuario();

  String paymentMethodSelected = paymentMethods[0].name!;

  //List of payment methods
  List<String> paymentMethodsLocale = [];

  int paymentMethod = 0;

  @override
  void initState() {
    isLoading = true;
    getUser();
    getPaymentMethod();
    super.initState();
  }

  // Gets the user info from firebase.
  void getUser() async {
    user = await _userDataService.getUserDetails(widget.userId);
    setState(() {
      isLoading = false;
    });
  }

  // Gets the paymentMethod info
  void getPaymentMethod() {
    for(int i = 0; i < paymentMethods.length; ++i)
      {
        paymentMethodsLocale.add(paymentMethods[i].name!);
      }
    setState(() {
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
              color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              LoadingView(),
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
              color: Theme.of(context).scaffoldBackgroundColor,
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
                          child: Text(widget.text, style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5),textAlign: TextAlign.center,),
                        ),

                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 24.0, right: 10, left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width * 0.06),
                                child: Text('Pagado con',
                                    style: Theme.of(context).textTheme.bodyText1,
                                    textAlign: TextAlign.center),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width * 0.02,
                                    right: MediaQuery.of(context).size.width * 0.01),
                                child: Container(
                                  height: MediaQuery.of(context).size.width * 0.10,
                                  padding:
                                  EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                        color: Colors.grey,
                                        style: BorderStyle.solid,
                                        width: 0.80),
                                  ),
                                  child: DropdownButton<String>(
                                    items: paymentMethodsLocale.map((String value) {
                                      return new DropdownMenuItem<String>(
                                        value: value,
                                        child: new Text(value),
                                      );
                                    }).toList(),
                                    hint: Text(paymentMethodSelected),
                                    onChanged: (newVal) {
                                      paymentMethodSelected = newVal!;
                                      for (int j = 0; j <= paymentMethods.length; ++j)
                                      {
                                        if(paymentMethods[j].name == paymentMethodSelected)
                                        {
                                          paymentMethod = j;
                                          break;
                                        }
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
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
                            backgroundColor: Colors.green,
                            fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.accept,
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          icon: Icon(Icons.check_circle_outline, size: MediaQuery.of(context).size.width*0.06, color: Colors.white,),
                          onPressed: () {
                            Navigator.pop(context, paymentMethod);
                          },
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width*0.01),
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
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          icon: Icon(Icons.cancel_outlined, size: MediaQuery.of(context).size.width*0.06,color: AppColors.white),
                          onPressed: () {
                            paymentMethod = -1;
                            Navigator.pop(context, paymentMethod);
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
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
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
                                  style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.bold),
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