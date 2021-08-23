// Flutter Libs
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/AuthService.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';

class TuMarca extends StatefulWidget {
  const TuMarca({Key? key}) : super(key: key);

  @override
  _TuMarcaState createState() => _TuMarcaState();
}

class _TuMarcaState extends State<TuMarca> {
  // Authentication Service
  final AuthenticationService _authenticationService = AuthenticationService();
  // Loading Screen Boolean
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("TU MARCA",style: purpleTextStyle.copyWith(fontSize: 30, fontWeight: FontWeight.bold)),
          Container(
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                color: purpleColor, borderRadius: BorderRadius.circular(20)
            ),
            child: TextButton(
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                await _authenticationService.signOut();
              },
              child: Text(
                'Cerrar Sesión',
                style: whiteTextStyle.copyWith(fontSize: 17.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
