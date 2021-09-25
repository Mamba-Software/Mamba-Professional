import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';

class TieneMarcaTrainer extends StatefulWidget {
  const TieneMarcaTrainer({Key? key}) : super(key: key);

  @override
  _TieneMarcaTrainerState createState() => _TieneMarcaTrainerState();
}

class _TieneMarcaTrainerState extends State<TieneMarcaTrainer> {
  // Access To DataBase
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;

  // Get current BrandDetails
  void getCurrentBrandDetails() async {
    currentBrand = await _accessDatabase.getCurrentBrandDetails(currentBrand.id!);
    print(currentBrand);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    isLoading = true;
    getCurrentBrandDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
    LoadingView()
        :
    Center(
      child: Text(currentBrand.id!),
    );
  }
}
