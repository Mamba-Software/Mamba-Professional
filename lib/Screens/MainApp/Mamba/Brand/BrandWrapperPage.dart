import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPageClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPageTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandPage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/NoBrandPage.dart';

class BrandWrapperPage extends StatefulWidget {
  BrandWrapperPage({Key? key}) : super(key: key);

  @override
  _BrandWrapperPageState createState() => _BrandWrapperPageState();
}

class _BrandWrapperPageState extends State<BrandWrapperPage> {

  // init Widget state. Loading user info.
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentBrand.id == null ?
        NoBrandPage()
          :
        BrandPage();
  }
}
